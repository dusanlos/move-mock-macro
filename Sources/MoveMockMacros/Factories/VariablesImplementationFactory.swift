//
//  VariablesImplementationFactory.swift
//  
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct VariablesImplementationFactory {
    // Accessor removal visitor for removing getter and setter from optional variables.
    private let accessorRemovalVisitor = AccessorRemovalVisitor()

    // Builds a list of variable declarations for a protocol variable.
    @MemberBlockItemListBuilder
    func variablesDeclarations(
        protocolVariableDeclaration: VariableDeclSyntax
    ) throws -> MemberBlockItemListSyntax {
        // Check if there is exactly one binding in the variable declaration.
        if protocolVariableDeclaration.bindings.count == 1 {
            // Extract the single binding.
            let binding = protocolVariableDeclaration.bindings.first!

            // Check if the type is optional.
            if binding.typeAnnotation?.type.is(OptionalTypeSyntax.self) == true {
                // If optional, remove getter and setter accessors.
                accessorRemovalVisitor.visit(protocolVariableDeclaration)
            } else {
                // If not optional, generate declarations with getter, setter, and underlying variable.
                try protocolVariableDeclarationWithGetterAndSetter(binding: binding)
                try underlyingVariableDeclaration(binding: binding)
            }
        } else {
            // Throw an error if there is not a single binding.
            throw MoveMockDiagnostics.variableDeclInProtocolWithNotSingleBinding
        }
    }

    // Generates a variable declaration with getter and setter.
    private func protocolVariableDeclarationWithGetterAndSetter(
        binding: PatternBindingSyntax
    ) throws -> VariableDeclSyntax {
        try VariableDeclSyntax(
            """
            var \(binding.pattern.trimmed)\(binding.typeAnnotation!.trimmed) {
                get { \(raw: underlyingVariableName(binding: binding)) }
                set { \(raw: underlyingVariableName(binding: binding)) = newValue }
            }
            """
        )
    }

    // Generates an underlying variable declaration.
    private func underlyingVariableDeclaration(
        binding: PatternBindingListSyntax.Element
    ) throws -> VariableDeclSyntax {
        try VariableDeclSyntax(
            """
            var \(raw: underlyingVariableName(binding: binding)): (\(binding.typeAnnotation!.type.trimmed))!
            """
        )
    }

    // Generates the name for the underlying variable.
    private func underlyingVariableName(binding: PatternBindingListSyntax.Element) throws -> String {
        // Extract the identifier pattern.
        guard let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) else {
            throw MoveMockDiagnostics.variableDeclInProtocolWithNotIdentifierPattern
        }

        // Extract the identifier text.
        let identifierText = identifierPattern.identifier.text

        // Form the underlying variable name by prefixing with "underlying" and capitalizing the first letter.
        return "underlying" + identifierText.prefix(1).uppercased() + identifierText.dropFirst()
    }
}

// Visitor class to remove accessor blocks (getter and setter).
private class AccessorRemovalVisitor: SyntaxRewriter {
    // Overrides the visit function to remove accessor blocks.
    override func visit(_ node: PatternBindingSyntax) -> PatternBindingSyntax {
        // Call the super visit function and return the result with nil accessor block.
        let superResult = super.visit(node)
        return superResult.with(\.accessorBlock, nil)
    }
}
