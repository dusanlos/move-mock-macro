//
//  MoveMockDiagnostics.swift
//
//
//  Created by Dusan Los on 01/12/2023.
//

import SwiftDiagnostics

// Define an enumeration MoveMockDiagnostics with a raw type of String,
// and it conforms to the protocols DiagnosticMessage and Error.
enum MoveMockDiagnostics: String, DiagnosticMessage, Error {

    // Define cases for different diagnostic messages related to '@Mock' attribute.
    case onlyApplicableToProtocol
    case variableDeclInProtocolWithNotSingleBinding
    case variableDeclInProtocolWithNotIdentifierPattern

    // Computed property that returns a descriptive message for each case.
    var message: String {
        switch self {
        case .onlyApplicableToProtocol:
            return "'@Mock' can only be applied to a 'protocol'"
        case .variableDeclInProtocolWithNotSingleBinding:
            return "Variable declaration in a 'protocol' with the '@Mock' attribute must have exactly one binding"
        case .variableDeclInProtocolWithNotIdentifierPattern:
            return "Variable declaration in a 'protocol' with the '@Mock' attribute must have identifier pattern"
        }
    }

    // Computed property that returns the severity level for each case.
    var severity: DiagnosticSeverity {
        switch self {
        case .onlyApplicableToProtocol,
                .variableDeclInProtocolWithNotSingleBinding,
                .variableDeclInProtocolWithNotIdentifierPattern:
            return .error
        }
    }

    // Computed property that returns a unique identifier for each diagnostic message.
    var diagnosticID: MessageID {
        return MessageID(domain: "MoveMockMacros", id: rawValue)
    }
}
