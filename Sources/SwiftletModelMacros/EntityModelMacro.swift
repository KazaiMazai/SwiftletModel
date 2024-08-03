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


public struct EntityModelMacro: ExtensionMacro {
    public static func expansion(of node: SwiftSyntax.AttributeSyntax, attachedTo declaration: some SwiftSyntax.DeclGroupSyntax, providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol, conformingTo protocols: [SwiftSyntax.TypeSyntax], in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        let attributes = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { extractRelationPropertyWrappersAttributes(from: $0) }
        
        let saveAll = attributes
            .map { "try save(\($0.keyPathAttributes.attribute), to: &context)" }
            .joined(separator: "\n")
        
        let detachAll = attributes
            .map { "detach(\($0.keyPathAttributes.attribute), in: &context)" }
            .joined(separator: "\n")
        
        let normalizeAll = attributes
            .map { "$\($0.propertyName).normalize()" }
            .joined(separator: "\n")
        
        let syntax = try ExtensionDeclSyntax("""
        extension \(raw: type): EntityModelProtocol {
            func save(to context: inout Context) throws {
                try willSave(to: &context)
                context.insert(self, options: Self.mergeStrategy)
                \(raw: saveAll)
            }
        
            func delete(from context: inout Context) throws {
                try willDelete(from: &context)
                context.remove(Self.self, id: id)
                \(raw: detachAll)
            }
        
            mutating func normalize() {
               \(raw: normalizeAll)
            }
        }
        """)

        return [syntax]
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
                    keyPathAttributes: .init(propertyIdentifier: property)
                )
            }
            
            return RelationPropertyWrapperAttributes(
                relationWrapperType: wrapperType,
                propertyName: property,
                keyPathAttributes: .init(labeledExpressionList: argumentList.map { argument in
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
    let relationWrapperType: WrapperType
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
}

extension RelationPropertyWrapperAttributes {
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
        case labeledExpressionList(String)
        case propertyIdentifier(String)
        
        init(labeledExpressionList: [(label: String?, expression: String)]) {
            let keyPathAttributes = labeledExpressionList.map {
                let label = $0.label.map { "\($0): "} ?? ""
                let expression = "\($0.expression)"
                return "\(label)\(expression)"
            }
            .joined(separator: ",")
            .replacingOccurrences(of: "\\.", with: "\\.$")
            
            self = .labeledExpressionList(keyPathAttributes)
        }
        
        init(propertyIdentifier: String) {
            self = .propertyIdentifier("\\.$\(propertyIdentifier)")
        }
        
        var attribute: String {
            switch self {
            case .labeledExpressionList(let value), .propertyIdentifier(let value):
                return value
            }
        }
        
    }
}
