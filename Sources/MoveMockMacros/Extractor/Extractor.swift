//
//  Extractor.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax

// Define a struct named Extractor.
struct Extractor {

  // Define a method to extract a ProtocolDeclSyntax from a DeclSyntaxProtocol.
  func extractProtocolDeclaration(
    from declaration: DeclSyntaxProtocol
  ) throws -> ProtocolDeclSyntax {

    // Attempt to cast the input declaration as ProtocolDeclSyntax.
    guard let protocolDeclaration = declaration.as(ProtocolDeclSyntax.self) else {

      // If the cast fails, throw the MoveMockDiagnostics.onlyApplicableToProtocol error.
      throw MoveMockDiagnostics.onlyApplicableToProtocol
    }

    // If the cast is successful, return the extracted ProtocolDeclSyntax.
    return protocolDeclaration
  }
}
