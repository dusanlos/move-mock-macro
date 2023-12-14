//
//  InvokedFactoryTests.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import XCTest

@testable import MoveMockMacros

final class InvokedFactoryTests: XCTestCase {
  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try InvokedFactory().variableDeclaration(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameInvoked: Bool {
          return functionNameInvokedCount > 0
      }
      """
    )
  }
}

