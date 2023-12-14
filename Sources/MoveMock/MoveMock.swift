//
//  MoveMock.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

// The macro is attached to a peer and uses the names suffixed with "Mock".
@attached(peer, names: suffixed(Mock))

// This macro is named "Mock" and takes an optional parameter behindPreprocessorFlag.
public macro Mock(behindPreprocessorFlag: String? = nil) =

// The macro body includes an #externalMacro that references another macro in the "MoveMockMacros" module.
  #externalMacro(
    module: "MoveMockMacros",
    type: "MoveMockMacros"
  )
