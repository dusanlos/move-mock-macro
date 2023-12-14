//
//  ReceivedArgumentsFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct ReceivedArgumentsFactory {
  // Generates a variable declaration for storing received arguments
  func variableDeclaration(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) throws -> VariableDeclSyntax {
    let identifier = variableIdentifier(
      variablePrefix: variablePrefix,
      parameterList: parameterList
    )
    let type = variableType(parameterList: parameterList)

    return try VariableDeclSyntax(
      """
      var \(identifier): \(type)
      """
    )
  }

  // Determines the variable type based on the function parameter list
  private func variableType(parameterList: FunctionParameterListSyntax) -> TypeSyntaxProtocol {
    let variableType: TypeSyntaxProtocol

    if parameterList.count == 1, var onlyParameterType = parameterList.first?.type {
      if let attributedType = onlyParameterType.as(AttributedTypeSyntax.self) {
        onlyParameterType = attributedType.baseType
      }

      if onlyParameterType.is(OptionalTypeSyntax.self) {
        variableType = onlyParameterType
      } else if onlyParameterType.is(FunctionTypeSyntax.self) {
        variableType = OptionalTypeSyntax(
          wrappedType: TupleTypeSyntax(
            elements: TupleTypeElementListSyntax {
              TupleTypeElementSyntax(type: onlyParameterType)
            }
          ),
          questionMark: .postfixQuestionMarkToken()
        )
      } else {
        variableType = OptionalTypeSyntax(
          wrappedType: onlyParameterType,
          questionMark: .postfixQuestionMarkToken()
        )
      }
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
      variableType = OptionalTypeSyntax(
        wrappedType: TupleTypeSyntax(elements: tupleElements),
        questionMark: .postfixQuestionMarkToken()
      )
    }

    return variableType
  }

  // Generates an expression to assign received arguments to the variable
  func assignValueToVariableExpression(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) -> ExprSyntax {
    let identifier = variableIdentifier(
      variablePrefix: variablePrefix,
      parameterList: parameterList
    )

    let tuple = TupleExprSyntax {
      for parameter in parameterList {
        LabeledExprSyntax(
          expression: DeclReferenceExprSyntax(
            baseName: parameter.secondName ?? parameter.firstName
          )
        )
      }
    }

    return ExprSyntax(
      """
      \(identifier) = \(tuple)
      """
    )
  }

  // Generates a variable identifier based on the variable prefix and parameter list
  private func variableIdentifier(
    variablePrefix: String,
    parameterList: FunctionParameterListSyntax
  ) -> TokenSyntax {
    if parameterList.count == 1, let onlyParameter = parameterList.first {
      let parameterNameToken = onlyParameter.secondName ?? onlyParameter.firstName
      let parameterNameText = parameterNameToken.text
      let capitalizedParameterName =
        parameterNameText.prefix(1).uppercased() + parameterNameText.dropFirst()

      return .identifier(variablePrefix + "Received" + capitalizedParameterName)
    } else {
      return .identifier(variablePrefix + "ReceivedArguments")
    }
  }
}
