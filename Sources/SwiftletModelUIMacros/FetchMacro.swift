//
//  FetchMacro.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 05/12/2025.
//

import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

public struct FetchMacro: ExpressionMacro {
    public static func expansion(of node: some SwiftSyntax.FreestandingMacroExpansionSyntax, in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> SwiftSyntax.ExprSyntax {
        
        guard let argument = node.arguments.first?.expression else {
              fatalError("compiler bug: the macro does not have any arguments")
        }

        return "@State @Fetch(\(argument))"
    }
    
//    public static func expansion(
//        of node: AttributeSyntax,
//        providingAccessorsOf declaration: some DeclSyntaxProtocol,
//        in context: some MacroExpansionContext
//    ) throws -> [AccessorDeclSyntax] {
//        guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
//              let propertiesAttributes = variableDeclaration.propertiesAttributes()
//        else {
//            return []
//        }
//
//        return [
//          """
//          get { self._\(raw: propertiesAttributes.keyName).value }
//          """
//        ]
//    }
    /*
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.DeclSyntax] {
            guard let variableDeclaration = declaration.as(VariableDeclSyntax.self),
                  let propertiesAttributes = variableDeclaration.propertiesAttributes()
            else {
                return []
            }

            let updateAtomically = try FunctionDeclSyntax.updateAtomically(propertiesAttributes)
            let dependencyKeyEnum = try SwiftSyntax.DeclSyntax.dependencyKeyEnum(propertiesAttributes)

            return [
                """
                \(updateAtomically)
                """,

                """
                \(dependencyKeyEnum)
                """
            ]
        }
     */
}

extension SwiftSyntax.DeclSyntax {
    static func dependencyKeyEnum(_ propertyAttributes: PropertyAttributes) throws -> SwiftSyntax.DeclSyntax {
        SwiftSyntax.DeclSyntax(
            """
            private enum _\(raw: propertyAttributes.keyName): DependencyKey {
                nonisolated(unsafe) static var instance \(raw: propertyAttributes.initializerClause)
            }
            """
        )
    }
}

extension FunctionDeclSyntax {
    static func updateAtomically(_ propertyAttributes: PropertyAttributes
    ) throws -> FunctionDeclSyntax? {

        guard let propertyType = propertyAttributes.propertyInferredType else {
            return nil
        }

        return try FunctionDeclSyntax(
        """
        \(raw: propertyAttributes.accessAttribute.name) static func update(
        \(raw: propertyAttributes.propertyName) atomically: @Sendable @escaping (inout \(raw: propertyType)) -> Void) {
            update(_\(raw: propertyAttributes.keyName).self, atomically: atomically)
        }
        """
        )
    }
}
