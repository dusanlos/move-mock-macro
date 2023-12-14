//
//  MoveMockMacroTests.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

@testable import MoveMockMacros

final class MoveMockMacroTests: XCTestCase {
  private let sut = ["Mock": MoveMockMacros.self]

  func testMacro() {
    let protocolDeclaration = """
      public protocol ServiceProtocol {
          var name: String {
              get
          }
          var anyProtocol: any Codable {
              get
              set
          }
          var secondName: String? {
              get
          }
          var added: () -> Void {
              get
              set
          }
          var removed: (() -> Void)? {
              get
              set
          }

          mutating func logout()
          func initialize(name: String, secondName: String?)
          func fetchConfig() async throws -> [String: String]
          func fetchData(_ name: (String, count: Int)) async -> (() -> Void)
      }
      """

    assertMacroExpansion(
      """
      @Mock
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        class ServiceProtocolMock: ServiceProtocol {
            var name: String {
                get {
                    underlyingName
                }
                set {
                    underlyingName = newValue
                }
            }
            var underlyingName: (String)!
            var anyProtocol: any Codable {
                get {
                    underlyingAnyProtocol
                }
                set {
                    underlyingAnyProtocol = newValue
                }
            }
            var underlyingAnyProtocol: (any Codable)!
                var secondName: String?
            var added: () -> Void {
                get {
                    underlyingAdded
                }
                set {
                    underlyingAdded = newValue
                }
            }
            var underlyingAdded: (() -> Void)!
                var removed: (() -> Void)?
            var logoutInvokedCount = 0
            var logoutInvoked: Bool {
                return logoutInvokedCount > 0
            }
            var logoutClosure: (() -> Void)?
            func logout() {
                logoutInvokedCount += 1
                logoutClosure?()
            }
            var initializeNameSecondNameInvokedCount = 0
            var initializeNameSecondNameInvoked: Bool {
                return initializeNameSecondNameInvokedCount > 0
            }
            var initializeNameSecondNameReceivedArguments: (name: String, secondName: String?)?
            var initializeNameSecondNameReceivedInvocations: [(name: String, secondName: String?)] = []
            var initializeNameSecondNameClosure: ((String, String?) -> Void)?
                func initialize(name: String, secondName: String?) {
                initializeNameSecondNameInvokedCount += 1
                initializeNameSecondNameReceivedArguments = (name, secondName)
                initializeNameSecondNameReceivedInvocations.append((name, secondName))
                initializeNameSecondNameClosure?(name, secondName)
            }
            var fetchConfigInvokedCount = 0
            var fetchConfigInvoked: Bool {
                return fetchConfigInvokedCount > 0
            }
            var fetchConfigThrowableError: Error?
            var fetchConfigReturnValue: [String: String]!
            var fetchConfigClosure: (() async throws -> [String: String])?
                func fetchConfig() async throws -> [String: String] {
                fetchConfigInvokedCount += 1
                if let fetchConfigThrowableError {
                    throw fetchConfigThrowableError
                }
                if fetchConfigClosure != nil {
                    return try await fetchConfigClosure!()
                } else {
                    return fetchConfigReturnValue
                }
            }
            var fetchDataInvokedCount = 0
            var fetchDataInvoked: Bool {
                return fetchDataInvokedCount > 0
            }
            var fetchDataReceivedName: (String, count: Int)?
            var fetchDataReceivedInvocations: [(String, count: Int)] = []
            var fetchDataReturnValue: (() -> Void)!
            var fetchDataClosure: (((String, count: Int)) async -> (() -> Void))?
                func fetchData(_ name: (String, count: Int)) async -> (() -> Void) {
                fetchDataInvokedCount += 1
                fetchDataReceivedName = (name)
                fetchDataReceivedInvocations.append((name))
                if fetchDataClosure != nil {
                    return await fetchDataClosure!(name)
                } else {
                    return fetchDataReturnValue
                }
            }
        }
        """,
      macros: sut
    )
  }

  func testMacroWithFlag() {
    let protocolDeclaration = """
      public protocol ServiceProtocol {
          var variable: Bool? { get set }
      }
      """
    assertMacroExpansion(
      """
      @Mock(behindPreprocessorFlag: "CUSTOM")
      \(protocolDeclaration)
      """,
      expandedSource: """

        \(protocolDeclaration)

        #if CUSTOM
        class ServiceProtocolMock: ServiceProtocol {
            var variable: Bool?
        }
        #endif
        """,
      macros: sut
    )
  }
}
