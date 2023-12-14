//
//  ClosureFactory.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct ClosureFactory {
  // Function to create a variable declaration for a closure
  func variableDeclaration(
    variablePrefix: String,
    functionSignature: FunctionSignatureSyntax
  ) throws -> VariableDeclSyntax {
    // Create a list of TupleTypeElementSyntax representing the closure type
    let elements = TupleTypeElementListSyntax {
      TupleTypeElementSyntax(
        type: FunctionTypeSyntax(
          parameters: TupleTypeElementListSyntax {
            // Iterate through function parameters and add them to the closure type
            for parameter in functionSignature.parameterClause.parameters {
              TupleTypeElementSyntax(type: parameter.type)
            }
          },
          effectSpecifiers: TypeEffectSpecifiersSyntax(
            asyncSpecifier: functionSignature.effectSpecifiers?.asyncSpecifier,
            throwsSpecifier: functionSignature.effectSpecifiers?.throwsSpecifier
          ),
          returnClause: functionSignature.returnClause
            ?? ReturnClauseSyntax(
              type: IdentifierTypeSyntax(
                name: .identifier("Void")
              )
            )
        )
      )
    }

    // Create a variable declaration using the gathered information
    return try VariableDeclSyntax(
      """
      var \(variableIdentifier(variablePrefix: variablePrefix)): (\(elements))?
      """
    )
  }

  // Function to create a call expression for the closure
  func callExpression(
    variablePrefix: String,
    functionSignature: FunctionSignatureSyntax
  ) -> ExprSyntaxProtocol {
    var calledExpression: ExprSyntaxProtocol

    // Check if the closure returns void or not
    if functionSignature.returnClause == nil {
      // If the closure returns void, use optional chaining
      calledExpression = OptionalChainingExprSyntax(
        expression: DeclReferenceExprSyntax(
          baseName: variableIdentifier(variablePrefix: variablePrefix)
        )
      )
    } else {
      // If the closure returns a value, use force unwrap
      calledExpression = ForceUnwrapExprSyntax(
        expression: DeclReferenceExprSyntax(
          baseName: variableIdentifier(variablePrefix: variablePrefix)
        )
      )
    }

    // Create a function call expression using the gathered information
    var expression: ExprSyntaxProtocol = FunctionCallExprSyntax(
      calledExpression: calledExpression,
      leftParen: .leftParenToken(),
      arguments: LabeledExprListSyntax {
        // Iterate through function parameters and add them to the function call
        for parameter in functionSignature.parameterClause.parameters {
          LabeledExprSyntax(
            expression: DeclReferenceExprSyntax(
              baseName: parameter.secondName ?? parameter.firstName
            )
          )
        }
      },
      rightParen: .rightParenToken()
    )

    // Check for async and throws specifiers and modify the expression accordingly
    if functionSignature.effectSpecifiers?.asyncSpecifier != nil {
      expression = AwaitExprSyntax(expression: expression)
    }

    if functionSignature.effectSpecifiers?.throwsSpecifier != nil {
      expression = TryExprSyntax(expression: expression)
    }

    return expression
  }

  // Helper function to generate a variable identifier token
  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "Closure")
  }
}
