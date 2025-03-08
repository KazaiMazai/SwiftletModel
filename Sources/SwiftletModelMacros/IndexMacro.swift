//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Implementation of the `stringify` macro, which takes an expression
/// of any type and produces a tuple containing the value of that expression
/// and the source code that produced the value. For example
///
///     #stringify(x + y)
///
///  will expand to
///
///     (x + y, "x + y")
//public enum StringifyMacro: ExpressionMacro {
//  public static func expansion(
//    of node: some FreestandingMacroExpansionSyntax,
//    in context: some MacroExpansionContext
//  ) -> ExprSyntax {
//    guard let argument = node.arguments.first?.expression else {
//      fatalError("compiler bug: the macro does not have any arguments")
//    }
//
//    return "(\(argument), \(literal: argument.description))"
//  }
//}
