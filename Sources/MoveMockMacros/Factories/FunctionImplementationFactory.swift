//
//  FunctionImplementationFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct FunctionImplementationFactory {
  // Factory instances for various functionalities
  private let invokedCountFactory = InvokedCountFactory()
  private let receivedArgumentsFactory = ReceivedArgumentsFactory()
  private let receivedInvocationsFactory = ReceivedInvocationsFactory()
  private let throwableErrorFactory = ThrowableErrorFactory()
  private let closureFactory = ClosureFactory()
  private let returnValueFactory = ReturnValueFactory()

  // Generates the implementation of a protocol function
  func declaration(
    variablePrefix: String,
    protocolFunctionDeclaration: FunctionDeclSyntax
  ) -> FunctionDeclSyntax {
    // Create a copy of the original declaration
    var mockFunctionDeclaration = protocolFunctionDeclaration

    // Remove the 'mutating' keyword if present in modifiers
    mockFunctionDeclaration.modifiers = protocolFunctionDeclaration.modifiers.removingMutatingKeyword

    // Build the body of the function using a CodeBlockSyntax
    mockFunctionDeclaration.body = CodeBlockSyntax {
      // Obtain the list of parameters from the function signature
      let parameterList = protocolFunctionDeclaration.signature.parameterClause.parameters

      // Increment the call count for the associated variable
      invokedCountFactory.incrementVariableExpression(variablePrefix: variablePrefix)

      // Handle received arguments if any
      if !parameterList.isEmpty {
        receivedArgumentsFactory.assignValueToVariableExpression(
          variablePrefix: variablePrefix,
          parameterList: parameterList
        )
        receivedInvocationsFactory.appendValueToVariableExpression(
          variablePrefix: variablePrefix,
          parameterList: parameterList
        )
      }

      // Handle exceptions (throws) if any
      if protocolFunctionDeclaration.signature.effectSpecifiers?.throwsSpecifier != nil {
        throwableErrorFactory.throwErrorExpression(variablePrefix: variablePrefix)
      }

      // If the function has no return type, generate a call expression
      if protocolFunctionDeclaration.signature.returnClause == nil {
        closureFactory.callExpression(
          variablePrefix: variablePrefix,
          functionSignature: protocolFunctionDeclaration.signature
        )
      } else {
        // Otherwise, generate a conditional return expression
        returnExpression(
          variablePrefix: variablePrefix,
          protocolFunctionDeclaration: protocolFunctionDeclaration
        )
      }
    }

    // Return the modified declaration
    return mockFunctionDeclaration
  }

  // Generates a conditional return expression based on closure existence
  private func returnExpression(
    variablePrefix: String,
    protocolFunctionDeclaration: FunctionDeclSyntax
  ) -> IfExprSyntax {
    // Construct a conditional expression
    IfExprSyntax(
      conditions: ConditionElementListSyntax {
        ConditionElementSyntax(
          condition: .expression(
            ExprSyntax(
              SequenceExprSyntax {
                // Check if the associated closure is not nil
                DeclReferenceExprSyntax(baseName: .identifier(variablePrefix + "Closure"))
                BinaryOperatorExprSyntax(operator: .binaryOperator("!="))
                NilLiteralExprSyntax()
              }
            )
          )
        )
      },
      // If the closure is not nil, return its result
      elseKeyword: .keyword(.else),
      elseBody: .codeBlock(
        CodeBlockSyntax {
          returnValueFactory.returnStatement(variablePrefix: variablePrefix)
        }
      ),
      // If the closure is nil, return the result of calling the closure
      bodyBuilder: {
        ReturnStmtSyntax(
          expression: closureFactory.callExpression(
            variablePrefix: variablePrefix,
            functionSignature: protocolFunctionDeclaration.signature
          )
        )
      }
    )
  }
}

// Extension to remove the 'mutating' keyword from modifiers
extension DeclModifierListSyntax {
  fileprivate var removingMutatingKeyword: Self {
    filter { $0.name.text != TokenSyntax.keyword(.mutating).text }
  }
}
