//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/08/2024.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
  let providingMacros: [Macro.Type] = [
    StorableEntityMacro.self
  ]
}
