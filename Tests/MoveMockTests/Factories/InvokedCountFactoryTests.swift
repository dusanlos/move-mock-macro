//
//  InvokedCountFactoryTests.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import XCTest

@testable import MoveMockMacros

final class InvokedCountFactoryTests: XCTestCase {
  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try InvokedCountFactory().variableDeclaration(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameInvokedCount = 0
      """
    )
  }

  func testIncrementVariableExpression() {
    let variablePrefix = "function_name"

    let result = InvokedCountFactory().incrementVariableExpression(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      function_nameInvokedCount += 1
      """
    )
  }
}

