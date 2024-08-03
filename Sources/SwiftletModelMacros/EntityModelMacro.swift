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
        
        let attributes = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { extractRelationPropertyWrappersAttributes(from: $0) }
        
        let saveAll = attributes
            .map { "try save(\($0.keyPathAttributes.attribute), to: &context)" }
            .joined(separator: "\n")
        
        let normalizeAll = attributes
            .map { "$\($0.propertyName).normalize()" }
            .joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            func saveMe(to context: inout Context) throws {
                context.insert(self)
                \(raw: saveAll)
            }
        
            mutating func normalizeMe() {
               \(raw: normalizeAll)
            }
        }
        """)

        return [syntax]
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
    
    static func save(declaration: some SwiftSyntax.DeclGroupSyntax,
                     type: some SwiftSyntax.TypeSyntaxProtocol) throws -> SwiftSyntax.ExtensionDeclSyntax? {
        
        let attributes = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { extractRelationPropertyWrappersAttributes(from: $0) }
        
        let saveAll = attributes
            .map { "try save(\($0.keyPathAttributes.attribute), to: &context)" }
            .joined(separator: "\n")
        
        let normalizeAll = attributes
            .map { "$\($0.propertyName).normalize()" }
            .joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type) {
            func saveMe(to context: inout Context) throws {
                context.insert(self)
                \(raw: saveAll)
            }
        
            mutating func normalizeMe() {
               \(raw: normalizeAll)
            }
        }
        """)
        
        return syntax
    }
    
    static func extractRelationPropertyWrappersAttributes(from vars: VariableDeclSyntax) -> RelationPropertyWrapperAttributes? {
        for attribute in vars.attributes {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                let wrapperType = RelationPropertyWrapperAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text)
            else {
                continue
            }
            
            guard let binding = vars.bindings.first(where: { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text != nil }),
                  let property = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            
            guard let argumentList = customAttribute.arguments?.as(LabeledExprListSyntax.self) else {
                return RelationPropertyWrapperAttributes(
                    relationWrapperType: wrapperType,
                    propertyName: property,
                    keyPathAttributes: .init(property: property)
                )
            }
            
            return RelationPropertyWrapperAttributes(
                relationWrapperType: wrapperType,
                propertyName: property,
                keyPathAttributes: .init(mutual: argumentList.map { argument in
                    let label = argument.label.map { "\($0)" }
                    let expression = "\(argument.expression)"
                    return (label, expression)
                })
            )
        }
        return nil
    }
}


struct RelationPropertyWrapperAttributes {
    enum WrapperType: String, CaseIterable {
        case hasMany = "HasMany"
        case hasOne = "HasOne"
        case belongsTo = "BelongsTo"
        
        var title: String {
            rawValue
        }
        
        static let allCasesTitleSet: Set<String> = {
            Set(Self.allCases.map { $0.title })
        }()
    }
    
    enum KeyPathAttributes {
        case mutual(String)
        case oneWay(String)
        
        init(mutual: [(label: String?, expression: String)]) {
            let keyPathAttributes = mutual.map {
                let label = $0.label.map { "\($0): "} ?? ""
                let expression = "\($0.expression)".replacingOccurrences(of: "\\.", with: "\\.$")
                return "\(label)\(expression)"
            }
            .joined(separator: ",")
            
            self = .mutual(keyPathAttributes)
        }
        
        init(property: String) {
            self = .oneWay("\\.$\(property)")
        }
        
        var attribute: String {
            switch self {
            case .mutual(let value), .oneWay(let value):
                return value
            }
        }
        
    }
    
    let relationWrapperType: WrapperType
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
}
