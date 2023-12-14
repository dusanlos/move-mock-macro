//
//  ThrowableErrorFactoryTests.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import XCTest

@testable import MoveMockMacros

final class ThrowableErrorFactoryTests: XCTestCase {
  func testVariableDeclaration() throws {
    let variablePrefix = "functionName"

    let result = try ThrowableErrorFactory().variableDeclaration(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      var functionNameThrowableError: Error?
      """
    )
  }

  func testThrowErrorExpression() {
    let variablePrefix = "function_name"

    let result = ThrowableErrorFactory().throwErrorExpression(variablePrefix: variablePrefix)

    assertBuildResult(
      result,
      """
      if let function_nameThrowableError {
          throw function_nameThrowableError
      }
      """
    )
  }
}
