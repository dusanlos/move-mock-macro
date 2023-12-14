//
//  ReturnValueFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct ReturnValueFactory {
    // Generates a variable declaration for storing the return value.
    func variableDeclaration(
        variablePrefix: String,
        functionReturnType: TypeSyntax
    ) throws -> VariableDeclSyntax {
        // Determine the type annotation based on whether the return type is optional.
        let typeAnnotation: TypeAnnotationSyntax
        if functionReturnType.is(OptionalTypeSyntax.self) {
            typeAnnotation = TypeAnnotationSyntax(type: functionReturnType)
        } else {
            typeAnnotation = TypeAnnotationSyntax(
                type: ImplicitlyUnwrappedOptionalTypeSyntax(wrappedType: functionReturnType)
            )
        }

        // Create and return the variable declaration.
        return try VariableDeclSyntax(
            """
            var \(variableIdentifier(variablePrefix: variablePrefix))\(typeAnnotation)
            """
        )
    }

    // Generates a return statement using the stored return value variable.
    func returnStatement(variablePrefix: String) -> StmtSyntax {
        // Create and return the return statement.
        return StmtSyntax(
            """
            return \(variableIdentifier(variablePrefix: variablePrefix))
            """
        )
    }

    // Generates the variable identifier based on the variable prefix.
    private func variableIdentifier(variablePrefix: String) -> TokenSyntax {
        return TokenSyntax.identifier(variablePrefix + "ReturnValue")
    }
}
