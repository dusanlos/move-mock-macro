//
//  InvokedFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct InvokedFactory {
  // This function generates a Swift code snippet for declaring a variable
  // that represents whether a certain task or function has been invoked.
  func variableDeclaration(variablePrefix: String) throws -> VariableDeclSyntax {
    try VariableDeclSyntax(
      """
      var \(raw: variablePrefix)Invoked: Bool {
          return \(raw: variablePrefix)InvokedCount > 0
      }
      """
    )
  }
}
