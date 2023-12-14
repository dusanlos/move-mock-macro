//
//  MockFactory.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct MockFactory {
  // Instances of various factories used to generate code elements
  private let associatedtypeFactory = AssociatedtypeFactory()
  private let variablePrefixFactory = VariablePrefixFactory()
  private let variablesImplementationFactory = VariablesImplementationFactory()
  private let callsCountFactory = InvokedCountFactory()
  private let calledFactory = InvokedFactory()
  private let receivedArgumentsFactory = ReceivedArgumentsFactory()
  private let receivedInvocationsFactory = ReceivedInvocationsFactory()
  private let throwableErrorFactory = ThrowableErrorFactory()
  private let returnValueFactory = ReturnValueFactory()
  private let closureFactory = ClosureFactory()
  private let functionImplementationFactory = FunctionImplementationFactory()

  // Generates a Swift class declaration based on a given protocol declaration
  func classDeclaration(for protocolDeclaration: ProtocolDeclSyntax) throws -> ClassDeclSyntax {
    // Extracts the protocol name to use for the mock class
    let identifier = TokenSyntax.identifier(protocolDeclaration.name.text + "Mock")

    // Extracts associated type declarations from the protocol
    let associatedtypeDeclarations = protocolDeclaration.memberBlock.members.compactMap {
      $0.decl.as(AssociatedTypeDeclSyntax.self)
    }

    // Constructs the generic parameter clause for the mock class
    let genericParameterClause = associatedtypeFactory.constructGenericParameterClause(
      associatedtypeDeclList: associatedtypeDeclarations
    )

    // Extracts variable and function declarations from the protocol
    let variableDeclarations = protocolDeclaration.memberBlock.members
      .compactMap { $0.decl.as(VariableDeclSyntax.self) }

    let functionDeclarations = protocolDeclaration.memberBlock.members
      .compactMap { $0.decl.as(FunctionDeclSyntax.self) }

    // Constructs and returns the mock class declaration
    return try ClassDeclSyntax(
      name: identifier,
      genericParameterClause: genericParameterClause,
      inheritanceClause: InheritanceClauseSyntax {
        InheritedTypeSyntax(
          type: IdentifierTypeSyntax(name: protocolDeclaration.name)
        )
      },
      memberBlockBuilder: {
        // Generates code for each variable in the protocol
        for variableDeclaration in variableDeclarations {
          try variablesImplementationFactory.variablesDeclarations(
            protocolVariableDeclaration: variableDeclaration
          )
        }

        // Generates code for each function in the protocol
        for functionDeclaration in functionDeclarations {
          let variablePrefix = variablePrefixFactory.text(for: functionDeclaration)
          let parameterList = functionDeclaration.signature.parameterClause.parameters

          try callsCountFactory.variableDeclaration(variablePrefix: variablePrefix)
          try calledFactory.variableDeclaration(variablePrefix: variablePrefix)

          if !parameterList.isEmpty {
            try receivedArgumentsFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              parameterList: parameterList
            )
            try receivedInvocationsFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              parameterList: parameterList
            )
          }

          if functionDeclaration.signature.effectSpecifiers?.throwsSpecifier != nil {
            try throwableErrorFactory.variableDeclaration(variablePrefix: variablePrefix)
          }

          if let returnType = functionDeclaration.signature.returnClause?.type {
            try returnValueFactory.variableDeclaration(
              variablePrefix: variablePrefix,
              functionReturnType: returnType
            )
          }

          try closureFactory.variableDeclaration(
            variablePrefix: variablePrefix,
            functionSignature: functionDeclaration.signature
          )

          // Generates the implementation for each function
          functionImplementationFactory.declaration(
            variablePrefix: variablePrefix,
            protocolFunctionDeclaration: functionDeclaration
          )
        }
      }
    )
  }
}
