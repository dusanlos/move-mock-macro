//
//  ReceivedInvocationsFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct ReceivedInvocationsFactory {
  // Generates a variable declaration for storing received invocations.
  func variableDeclaration(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) throws -> VariableDeclSyntax {
    let identifier = variableIdentifier(variablePrefix: variablePrefix)
    let elementType = arrayElementType(parameterList: parameterList)

    return try VariableDeclSyntax(
      """
      var \(identifier): [\(elementType)] = []
      """
    )
  }

  // Determines the type of elements in the array based on the function parameters.
  private func arrayElementType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
    let arrayElementType: TypeSyntaxProtocol

    if parameterList.count == 1, var onlyParameterType = parameterList.first?.type {
      if let attributedType = onlyParameterType.as(AttributedTypeSyntax.self) {
        onlyParameterType = attributedType.baseType
      }
      arrayElementType = onlyParameterType
    } else {
      let tupleElements = TupleTypeElementListSyntax {
        for parameter in parameterList {
          TupleTypeElementSyntax(
            firstName: parameter.secondName ?? parameter.firstName,
            colon: .colonToken(),
            type: {
              if let attributedType = parameter.type.as(AttributedTypeSyntax.self) {
                return attributedType.baseType
              } else {
                return parameter.type
              }
            }()
          )
        }
      }
      arrayElementType = TupleTypeSyntax(elements: tupleElements)
    }

    return arrayElementType
  }

  // Generates an expression to append the received invocation to the array.
  func appendValueToVariableExpression(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) -> ExprSyntax {
    let identifier = variableIdentifier(variablePrefix: variablePrefix)
    let argument = appendArgumentExpression(parameterList: parameterList)

    return ExprSyntax(
      """
      \(identifier).append(\(argument))
      """
    )
  }

  // Generates an expression for the argument to be appended, considering tuple arguments.
  private func appendArgumentExpression(
    parameterList: FunctionParameterListSyntax
  ) -> LabeledExprListSyntax {
    let tupleArgument = TupleExprSyntax(
      elements: LabeledExprListSyntax(
        itemsBuilder: {
          for parameter in parameterList {
            LabeledExprSyntax(
              expression: DeclReferenceExprSyntax(
                baseName: parameter.secondName ?? parameter.firstName
              )
            )
          }
        }
      )
    )

    return LabeledExprListSyntax {
      LabeledExprSyntax(expression: tupleArgument)
    }
  }

  // Generates the variable identifier for received invocations.
  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "ReceivedInvocations")
  }
}
