//
//  AssociatedtypeFactory.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftSyntax
import SwiftSyntaxBuilder

struct AssociatedtypeFactory {
  func constructGenericParameterClause(associatedtypeDeclList: [AssociatedTypeDeclSyntax])
    -> GenericParameterClauseSyntax?
  {
    // Check if the associatedtypeDeclList is not empty
    guard !associatedtypeDeclList.isEmpty else { return nil }

    // Create an empty list to store our GenericParameterSyntax objects
    var genericParameterList = [GenericParameterSyntax]()

    // Iterate through each associatedtype declaration in the list
    for (i, associatedtypeDecl) in associatedtypeDeclList.enumerated() {
      // Get the name of the associatedtype
      let associatedtypeName = associatedtypeDecl.name

      // Get the inheritance clause of the associatedtype
      let typeInheritance: InheritanceClauseSyntax? = associatedtypeDecl.inheritanceClause

      // Get the inherited type from the inheritance clause
      let inheritedType = typeInheritance?.inheritedTypes.first?.type

      // Check if this is the last associatedtype declaration in the list
      let hasTrailingComma: Bool = i < associatedtypeDeclList.count - 1

      // Create a GenericParameterSyntax object using the gathered information
      let genericParameter = GenericParameterSyntax(
        name: associatedtypeName,
        colon: inheritedType != nil ? typeInheritance?.colon : nil,
        inheritedType: inheritedType,
        trailingComma: hasTrailingComma ? .commaToken() : nil
      )

      // Append the created GenericParameterSyntax object to the list
      genericParameterList.append(genericParameter)
    }

    // Create a GenericParameterClauseSyntax using the list of GenericParameterSyntax objects
    return GenericParameterClauseSyntax(
      parameters: GenericParameterListSyntax(genericParameterList)
    )
  }
}
