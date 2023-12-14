//
//  VariablePrefixFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct VariablePrefixFactory {
    // Generates a variable prefix based on the function declaration.
    func text(for functionDeclaration: FunctionDeclSyntax) -> String {
        // Initialize an array to store parts of the variable prefix.
        var parts: [String] = [functionDeclaration.name.text]

        // Extract the parameter list from the function declaration.
        let parameterList = functionDeclaration.signature.parameterClause.parameters

        // Extract and filter parameter names, excluding placeholders ("_").
        let parameters =
            parameterList
            .map { $0.firstName.text }
            .filter { $0 != "_" }
            .map { $0.capitalizingFirstLetter() }

        // Append the non-placeholder parameter names to the parts array.
        parts.append(contentsOf: parameters)

        // Join the parts to form the final variable prefix.
        return parts.joined()
    }
}

// String extension to capitalize the first letter.
extension String {
    // Capitalizes the first letter of a string.
    fileprivate func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}
