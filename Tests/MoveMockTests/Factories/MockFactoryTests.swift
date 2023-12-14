//
//  MockFactoryTests.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder
import XCTest

@testable import MoveMockMacros

final class MockFactoryTests: XCTestCase {
  func testDeclarationEmptyProtocol() throws {
    let declaration = DeclSyntax(
      """
      protocol Foo {}
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class FooMock: Foo {
      }
      """
    )
  }

  func testDeclaration() throws {
    let declaration = DeclSyntax(
      """
      protocol Service {
      func fetch()
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceMock: Service {
          var fetchInvokedCount = 0
          var fetchInvoked: Bool {
              return fetchInvokedCount > 0
          }
          var fetchClosure: (() -> Void)?
          func fetch() {
              fetchInvokedCount += 1
              fetchClosure?()
          }
      }
      """
    )
  }

  func testDeclarationArguments() throws {
    let declaration = DeclSyntax(
      """
      protocol ViewModelProtocol {
      func foo(text: String, count: Int)
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ViewModelProtocolMock: ViewModelProtocol {
          var fooTextCountInvokedCount = 0
          var fooTextCountInvoked: Bool {
              return fooTextCountInvokedCount > 0
          }
          var fooTextCountReceivedArguments: (text: String, count: Int)?
          var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
          var fooTextCountClosure: ((String, Int) -> Void)?
          func foo(text: String, count: Int) {
              fooTextCountInvokedCount += 1
              fooTextCountReceivedArguments = (text, count)
              fooTextCountReceivedInvocations.append((text, count))
              fooTextCountClosure?(text, count)
          }
      }
      """
    )
  }

  func testDeclarationReturnValue() throws {
    let declaration = DeclSyntax(
      """
      protocol Bar {
      func print() -> (text: String, tuple: (count: Int?, Date))
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class BarMock: Bar {
          var printInvokedCount = 0
          var printInvoked: Bool {
              return printInvokedCount > 0
          }
          var printReturnValue: (text: String, tuple: (count: Int?, Date))!
          var printClosure: (() -> (text: String, tuple: (count: Int?, Date)))?
          func print() -> (text: String, tuple: (count: Int?, Date)) {
              printInvokedCount += 1
              if printClosure != nil {
                  return printClosure!()
              } else {
                  return printReturnValue
              }
          }
      }
      """
    )
  }

  func testDeclarationAsync() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
      func foo(text: String, count: Int) async -> Decimal
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceProtocolMock: ServiceProtocol {
          var fooTextCountInvokedCount = 0
          var fooTextCountInvoked: Bool {
              return fooTextCountInvokedCount > 0
          }
          var fooTextCountReceivedArguments: (text: String, count: Int)?
          var fooTextCountReceivedInvocations: [(text: String, count: Int)] = []
          var fooTextCountReturnValue: Decimal!
          var fooTextCountClosure: ((String, Int) async -> Decimal)?
          func foo(text: String, count: Int) async -> Decimal {
              fooTextCountInvokedCount += 1
              fooTextCountReceivedArguments = (text, count)
              fooTextCountReceivedInvocations.append((text, count))
              if fooTextCountClosure != nil {
                  return await fooTextCountClosure!(text, count)
              } else {
                  return fooTextCountReturnValue
              }
          }
      }
      """
    )
  }

  func testDeclarationThrows() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
      func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)?
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceProtocolMock: ServiceProtocol {
          var fooInvokedCount = 0
          var fooInvoked: Bool {
              return fooInvokedCount > 0
          }
          var fooReceivedAdded: ((text: String) -> Void)?
          var fooReceivedInvocations: [((text: String) -> Void)?] = []
          var fooThrowableError: Error?
          var fooReturnValue: (() -> Int)?
          var fooClosure: ((((text: String) -> Void)?) throws -> (() -> Int)?)?
          func foo(_ added: ((text: String) -> Void)?) throws -> (() -> Int)? {
              fooInvokedCount += 1
              fooReceivedAdded = (added)
              fooReceivedInvocations.append((added))
              if let fooThrowableError {
                  throw fooThrowableError
              }
              if fooClosure != nil {
                  return try fooClosure!(added)
              } else {
                  return fooReturnValue
              }
          }
      }
      """
    )
  }

  func testDeclarationVariable() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
          var data: Data { get }
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceProtocolMock: ServiceProtocol {
          var data: Data {
              get {
                  underlyingData
              }
              set {
                  underlyingData = newValue
              }
          }
          var underlyingData: (Data)!
      }
      """
    )
  }

  func testDeclarationOptionalVariable() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
          var data: Data? { get set }
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceProtocolMock: ServiceProtocol {
          var data: Data?
      }
      """
    )
  }

  func testDeclarationClosureVariable() throws {
    let declaration = DeclSyntax(
      """
      protocol ServiceProtocol {
          var completion: () -> Void { get set }
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class ServiceProtocolMock: ServiceProtocol {
          var completion: () -> Void {
              get {
                  underlyingCompletion
              }
              set {
                  underlyingCompletion = newValue
              }
          }
          var underlyingCompletion: (() -> Void)!
      }
      """
    )
  }
}

// - MARK: Handle Protocol Associated types

extension MockFactoryTests {
  func testDeclarationAssociatedtype() throws {
    let declaration = DeclSyntax(
      """
      protocol Foo {
          associatedtype Key: Hashable
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class FooMock<Key: Hashable>: Foo {
      }
      """
    )
  }

  func testDeclarationAssociatedtypeKeyValue() throws {
    let declaration = DeclSyntax(
      """
      protocol Foo {
          associatedtype Key: Hashable
          associatedtype Value
      }
      """
    )
    let protocolDeclaration = try XCTUnwrap(ProtocolDeclSyntax(declaration))

    let result = try MockFactory().classDeclaration(for: protocolDeclaration)

    assertBuildResult(
      result,
      """
      class FooMock<Key: Hashable, Value>: Foo {
      }
      """
    )
  }
}
