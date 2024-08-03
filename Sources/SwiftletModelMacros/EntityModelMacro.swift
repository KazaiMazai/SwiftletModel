//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/08/2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif


public struct StorableEntityMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        

        let normalize = try normalizeMe(declaration: declaration, type: type)
        let save = try saveMe(declaration: declaration, type: type)
        return [normalize, save].compactMap { $0 }
    }
     
    static func relationAttribute(from list: AttributeListSyntax) -> Bool {
        for attribute in list {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let name = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                  name.name.text == "HasMany" || 
                    name.name.text == "HasOne" ||
                    name.name.text == "BelongsTo" else {
                continue
            }
            return true
        }
        return false
    }
    
    
    static func atts(from vars: VariableDeclSyntax) -> String? {
        for attribute in vars.attributes {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let name = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                (name.name.text == "HasMany" ||
                    name.name.text == "HasOne" ||
                    name.name.text == "BelongsTo") else {
                continue
            }
            
            if let argumentList = customAttribute.arguments?.as(LabeledExprListSyntax.self) {
                return argumentList.map {
                    let label = $0.label.map { "\($0): "} ?? ""
                    let expression = "\($0.expression)".replacingOccurrences(of: "\\.", with: "\\.$")
                                  
                    return "\(label)\(expression)"
                }
                .joined(separator: ",")
                 
            }
            
            if let text = vars.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text {
                return "\\.$\(text)"
            }
                
        }
        return nil
    }
    
    
    static func normalizeMe(declaration: some SwiftSyntax.DeclGroupSyntax,
                            type: some SwiftSyntax.TypeSyntaxProtocol) throws -> SwiftSyntax.ExtensionDeclSyntax? {
        
        let variables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .filter { relationAttribute(from: $0.attributes) }
            .filter { $0.modifiers.first?.name.text != "static" }
        
        let varNames = variables.compactMap {
            $0.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
       
        }.map {
            "$\($0).normalize()"
        }
        
        let body = varNames.joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            mutating func normalizeMe() {
               \(raw: body)
            }
        }
        """)
        
        return syntax
    }
    
    static func saveMe(declaration: some SwiftSyntax.DeclGroupSyntax,
                            type: some SwiftSyntax.TypeSyntaxProtocol) throws -> SwiftSyntax.ExtensionDeclSyntax? {
        
        let variables = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { atts(from: $0) }
            .map {
                "try save(\($0), to: &context)"
            }
        
        let body = variables.joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            func saveMe(to context: inout Context) throws {
                context.insert(self)
                \(raw: body)
            }
        }
        """)
        
        return syntax
    }
     
    
}
