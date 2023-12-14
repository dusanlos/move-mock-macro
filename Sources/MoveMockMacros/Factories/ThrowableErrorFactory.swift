//
//  ThrowableErrorFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct ThrowableErrorFactory {
    // Generates a variable declaration for storing a throwable error.
    func variableDeclaration(variablePrefix: String) throws -> VariableDeclSyntax {
        // Create and return the variable declaration with the Error type.
        try VariableDeclSyntax(
            """
            var \(variableIdentifier(variablePrefix: variablePrefix)): Error?
            """
        )
    }

    // Generates an expression to throw the stored throwable error if it exists.
    func throwErrorExpression(variablePrefix: String) -> ExprSyntax {
        // Create and return the conditional expression to throw the error.
        return ExprSyntax(
            """
            if let \(variableIdentifier(variablePrefix: variablePrefix)) {
                throw \(variableIdentifier(variablePrefix: variablePrefix))
            }
            """
        )
    }

    // Generates the variable identifier based on the variable prefix.
    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        return TokenSyntax.identifier(variablePrefix + "ThrowableError")
    }
}
