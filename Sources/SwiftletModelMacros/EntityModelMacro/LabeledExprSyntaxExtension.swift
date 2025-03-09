//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 10/08/2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif

extension LabeledExprSyntax {
    var labelString: String? {
        label.map { "\($0)" }
    }

    var expressionString: String {
        "\(expression)"
    }

    var isKeyPath: Bool {
        expressionString.isKeyPath
    }
}

fileprivate extension String {
    static var keyPathRegEx: String {
       #"^\\.*\..*$"#
    }

    var isKeyPath: Bool {
        range(of: String.keyPathRegEx, options: .regularExpression) != nil
    }
}


extension DeclModifierListSyntax {
    var isStatic: Bool {
        first?.name.text == "static"
    }
}
