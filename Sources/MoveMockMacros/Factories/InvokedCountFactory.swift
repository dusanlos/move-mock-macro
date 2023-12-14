//
//  InvokedCountFactory.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct InvokedCountFactory {
  // This function generates a Swift code snippet for declaring a variable
  // that will be used to count how many times a certain task is invoked.
  func variableDeclaration(variablePrefix: String) throws -> VariableDeclSyntax {
    try VariableDeclSyntax(
      """
      var \(variableIdentifier(variablePrefix: variablePrefix)) = 0
      """
    )
  }

  // This function generates a Swift code snippet for incrementing
  // the count variable associated with a specific task.
  func incrementVariableExpression(variablePrefix: String) -> ExprSyntax {
    ExprSyntax(
      """
      \(variableIdentifier(variablePrefix: variablePrefix)) += 1
      """
    )
  }

  // This private function generates the unique variable name
  // based on the provided prefix for counting invocations.
  private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
    TokenSyntax.identifier(variablePrefix + "InvokedCount")
  }
}
