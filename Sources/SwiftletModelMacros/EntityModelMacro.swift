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
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
        
        let attributes = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { extractRelationPropertyWrappersAttributes(from: $0) }
            
        let optionalProperties = declaration.memberBlock.members
            .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            .compactMap { extractOptionalPropertyAttributes(from: $0) }
         
        let syntax = try ExtensionDeclSyntax(
        """
        extension \(raw: type): EntityModelProtocol {
            func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
                try willSave(to: &context)
                context.insert(self, options: options)
                \(raw: attributes
                    .map { "try save(\($0.keyPathAttributes.attribute), to: &context)" }
                    .joined(separator: "\n")
                )
                try didSave(to: &context)
            }
        
            func delete(from context: inout Context) throws {
                try willDelete(from: &context)
                context.remove(Self.self, id: id)
                \(raw: attributes
                    .map { "detach(\($0.keyPathAttributes.attribute), in: &context)" }
                    .joined(separator: "\n")
                )
                try didDelete(from: &context)
            }
        
            mutating func normalize() {
               \(raw: attributes
                    .map { "$\($0.propertyName).normalize()" }
                    .joined(separator: "\n")
                )
            }
        
            static func batchQuery(in context: Context) -> [Query<Self>]  {
                Self.query(in: context)
                   \(raw: attributes
                        .map { "\\.$\($0.propertyName)" }
                        .map { ".id(\($0))"}
                        .joined(separator: "\n")
                    )
            }
        
            static let patch: MergeStrategy<Self> = {
                MergeStrategy(
                    \(raw: optionalProperties
                        .map { ".patch(\\.\($0))"}
                        .joined(separator: ",\n")
                    )
                )
            }()
        }

        """
        )

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
    
    static func extractOptionalPropertyAttributes(from vars: VariableDeclSyntax) -> String? {
        for attribute in vars.attributes {
            
            if let customAttribute = attribute.as(AttributeSyntax.self),
               let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
               let wrapperType = RelationPropertyWrapperAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text) {
                return nil
            }
        }
        
        guard vars.modifiers.first?.name.text != "static" else {
            return nil
        }
         
        for binding in vars.bindings {
            guard let property = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let typeAnnotation = binding.typeAnnotation?.type else {
                continue
            }
            
            let isOptional = typeAnnotation.is(OptionalTypeSyntax.self)
            let hasInitializer = binding.initializer != nil
            
            guard isOptional else {
                continue
            }
            
            return property
            
        }
        return nil
    }
            
    static func extractOptionalPropertyAttributes1(from vars: VariableDeclSyntax) -> String? {
        
        for binding in vars.bindings {
            guard let property = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let typeAnnotation = binding.typeAnnotation?.type else {
                continue
            }
            
            let isOptional = typeAnnotation.is(OptionalTypeSyntax.self)
            let hasInitializer = binding.initializer != nil
            
            guard isOptional || hasInitializer else {
                continue
            }
            
            return property
            
        }
        return nil
    }
}


struct OptionalPropertyAttributes {
    let propertyName: String
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
        case relationship = "Relationship"
        
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
