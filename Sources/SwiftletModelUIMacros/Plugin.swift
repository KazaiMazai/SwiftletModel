//
//  Plugin.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 05/12/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FetchMacro.self
    ]
}
