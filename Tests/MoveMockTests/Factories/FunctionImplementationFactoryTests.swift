//
//  FunctionImplementationFactoryTests.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import XCTest

@testable import MoveMockMacros

final class FunctionImplementationFactoryTests: XCTestCase {
  func testDeclaration() throws {
    let variablePrefix = "functionName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo()"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() {
          functionNameInvokedCount += 1
          functionNameClosure?()
      }
      """
    )
  }

  func testDeclarationArguments() throws {
    let variablePrefix = "func_name"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo(text: String, count: Int)"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo(text: String, count: Int) {
          func_nameInvokedCount += 1
          func_nameReceivedArguments = (text, count)
          func_nameReceivedInvocations.append((text, count))
          func_nameClosure?(text, count)
      }
      """
    )
  }

  func testDeclarationReturnValue() throws {
    let variablePrefix = "funcName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo() -> (text: String, tuple: (count: Int?, Date))"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() -> (text: String, tuple: (count: Int?, Date)) {
          funcNameInvokedCount += 1
          if funcNameClosure != nil {
              return funcNameClosure!()
          } else {
              return funcNameReturnValue
          }
      }
      """
    )
  }

  func testDeclarationReturnValueAsyncThrows() async throws {
    let variablePrefix = "foo"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date))"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo(_ bar: String) async throws -> (text: String, tuple: (count: Int?, Date)) {
          fooInvokedCount += 1
          fooReceivedBar = (bar)
          fooReceivedInvocations.append((bar))
          if let fooThrowableError {
              throw fooThrowableError
          }
          if fooClosure != nil {
              return try await fooClosure!(bar)
          } else {
              return fooReturnValue
          }
      }
      """
    )
  }

  func testDeclarationWithMutatingKeyword() throws {
    let variablePrefix = "functionName"

    let protocolFunctionDeclaration = try FunctionDeclSyntax(
      "mutating func foo()"
    ) {}

    let result = FunctionImplementationFactory().declaration(
      variablePrefix: variablePrefix,
      protocolFunctionDeclaration: protocolFunctionDeclaration
    )

    assertBuildResult(
      result,
      """
      func foo() {
          functionNameInvokedCount += 1
          functionNameClosure?()
      }
      """
    )
  }
}
