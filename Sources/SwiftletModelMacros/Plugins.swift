//
//  File.swift
//  
//
//  Created by Serge Kazakov on 03/08/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    EntityModelMacro.self, EntityRefModelMacro.self
  ]
}
