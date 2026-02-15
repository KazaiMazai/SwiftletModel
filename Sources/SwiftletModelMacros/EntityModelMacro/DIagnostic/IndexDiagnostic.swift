//
//  IndexDiagnostic.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 14/02/2026.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif

struct IndexDiagnostic: DiagnosticMessage {
    let message: String
    let diagnosticID: MessageID
    let severity: DiagnosticSeverity

    static var preferInstanceProperty: IndexDiagnostic {
        IndexDiagnostic(
            message: "Index should be declared as instance property",
            diagnosticID: MessageID(domain: "SwiftletModel", id: "staticIndexDeprecated"),
            severity: .warning
        )
    }
}
