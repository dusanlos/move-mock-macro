//
//  MoveMockMacro.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//


import SwiftSyntax
import SwiftSyntaxMacros


// Enum representing macros related to MoveMock with a PeerMacro conformance.
public enum MoveMockMacros: PeerMacro {
    // Private static instances of Extractor and MockFactory for internal use.
    private static let extractor = Extractor()
    private static let mockFactory = MockFactory()

    // Macro expansion function conforming to the PeerMacro protocol.
    public static func expansion(
        of _: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Try to extract the protocol declaration using the extractor.
        let protocolDeclaration = try extractor.extractProtocolDeclaration(from: declaration)

        // Generate the mock class declaration using the MockFactory.
        let mockClassDeclaration = try mockFactory.classDeclaration(for: protocolDeclaration)

        // Check if there is a preprocessor flag in the declaration.
        if let flag = declaration.preprocessorFlag {
            // If a flag exists, generate an #if block with the specified flag condition.
            return [
                DeclSyntax(
                    IfConfigDeclSyntax(
                        clauses: IfConfigClauseListSyntax {
                            IfConfigClauseSyntax(
                                poundKeyword: .poundIfToken(),
                                condition: ExprSyntax(stringLiteral: flag),
                                elements: .statements(
                                    CodeBlockItemListSyntax {
                                        // Include the mock class declaration within the #if block.
                                        DeclSyntax(mockClassDeclaration)
                                    }
                                )
                            )
                        }
                    )
                )
            ]
        } else {
            // If no flag exists, return an array containing only the mock class declaration.
            return [DeclSyntax(mockClassDeclaration)]
        }
    }
}

// Extension to DeclSyntaxProtocol to extract the preprocessor flag from a protocol declaration.
extension DeclSyntaxProtocol {
    // Computed property to get the preprocessor flag.
    fileprivate var preprocessorFlag: String? {
        // Try to extract the preprocessor flag from the attributes of the protocol declaration.
        self.as(ProtocolDeclSyntax.self)?.attributes.first?
            .as(AttributeSyntax.self)?.arguments?
            .as(LabeledExprListSyntax.self)?.first {
                $0.label?.text == "behindPreprocessorFlag"
            }?
            .as(LabeledExprSyntax.self)?.expression
            .as(StringLiteralExprSyntax.self)?.segments.first?
            .as(StringSegmentSyntax.self)?.content.text
    }
}
