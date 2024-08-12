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

}

public extension EntityModelMacro {
    static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
            
            let variableDeclarations = declaration
                .memberBlock
                .members
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            
            let relationshipAttributes = variableDeclarations
                .compactMap { $0.relationshipAttributes() }

            let optionalProperties = variableDeclarations
                .compactMap { $0.optionalPropertiesAttributes() }

            let syntax = try ExtensionDeclSyntax.entityModelProtocol(
                type: type,
                conformingTo: protocols,
                relationshipAttributes: relationshipAttributes,
                optionalProperties: optionalProperties
            )
            
            return  [syntax]
        }
}

extension ExtensionDeclSyntax {
    static func entityModelProtocol(type: some SwiftSyntax.TypeSyntaxProtocol,
                                               conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                               relationshipAttributes: [RelationshipAttributes],
                                               optionalProperties: [PropertyAttributes]
    ) throws -> ExtensionDeclSyntax {
        let protocolsString = protocols.map { "\($0)" }
            .joined(separator: ",")
            .trimmingCharacters(in: .whitespaces)
        
        return try ExtensionDeclSyntax(
        """
        extension \(raw: type): \(raw: protocolsString) {
            \(raw: FunctionDeclSyntax.save(relationshipAttributes))
            \(raw: FunctionDeclSyntax.delete(relationshipAttributes))
            \(raw: FunctionDeclSyntax.normalize(relationshipAttributes))
            \(raw: FunctionDeclSyntax.batchQuery(relationshipAttributes))
            \(raw: VariableDeclSyntax.patch(optionalProperties))
        }
        """
        )
    }
}

extension FunctionDeclSyntax {
    static func save(
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
         
        func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
            try willSave(to: &context)
            context.insert(self, options: options)
            \(raw: attributes
                .map { "try save(\($0.keyPathAttributes.attribute), to: &context)" }
                .joined(separator: "\n")
            )
            try didSave(to: &context)
        }
        """
        )
    }
    
    static func delete(
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        func delete(from context: inout Context) throws {
            try willDelete(from: &context)
            context.remove(Self.self, id: id)
            \(raw: attributes
                .map {
                    switch $0.deleteRule {
                    case .nullify:
                        "detach(\($0.keyPathAttributes.attribute), in: &context)"
                    case .cascade:
                        "try delete(\($0.keyPathAttributes.attribute), from: &context)"
                    }
                }
                .joined(separator: "\n")
            )
            try didDelete(from: &context)
        }
        """
        )
    }
    
    static func normalize(
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        mutating func normalize() {
           \(raw: attributes
                .map { "$\($0.propertyName).normalize()" }
                .joined(separator: "\n")
            )
        }
        """
        )
    }
    
    static func batchQuery(
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        static func batchQuery(in context: Context) -> [Query<Self>] {
            Self.query(in: context)
               \(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".id(\($0))"}
                    .joined(separator: "\n")
                )
        }
        """
        )
    }
}

extension VariableDeclSyntax {
    
    static func patch(
        _ attributes: [PropertyAttributes]
    ) throws -> VariableDeclSyntax {
        
        try VariableDeclSyntax(
        """
        
        static var patch: MergeStrategy<Self> {
            MergeStrategy(
                \(raw: attributes
                    .map { ".patch(\\.\($0.propertyName))"}
                    .joined(separator: ",\n")
                )
            )
        }
        """
        )
    }
}

private extension VariableDeclSyntax {

    func relationshipAttributes() -> RelationshipAttributes? {
        for attribute in self.attributes {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                let wrapperType = RelationshipAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text)
            else {
                continue
            }

            guard let binding = bindings.first(where: { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text != nil }),
                  let property = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
            
            guard let keyPathsExprList = customAttribute
                .arguments?
                .as(LabeledExprListSyntax.self) else {
                
                return RelationshipAttributes(
                    relationWrapperType: wrapperType,
                    propertyName: property,
                    keyPathAttributes: RelationshipAttributes.KeyPathAttributes(
                        propertyIdentifier: property
                    ), 
                    deleteRule: .nullify
                )
            }
            
            return RelationshipAttributes(
                relationWrapperType: wrapperType,
                propertyName: property,
                keyPathAttributes: RelationshipAttributes.KeyPathAttributes(
                    propertyIdentifier: property,
                    labeledExprListSyntax: keyPathsExprList
                ),
                deleteRule: RelationshipAttributes.DeleteRuleAttribute(labeledExprListSyntax: keyPathsExprList)
            )
        }
        return nil
    }
    
    func optionalPropertiesAttributes() -> PropertyAttributes? {
        for attribute in attributes {

            if let customAttribute = attribute.as(AttributeSyntax.self),
               let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
               let _ = RelationshipAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text) {
                return nil
            }
        }

        guard modifiers.first?.name.text != "static" else {
            return nil
        }

        for binding in bindings {
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let typeAnnotation = binding.typeAnnotation?.type else {
                continue
            }

            let isOptional = typeAnnotation.is(OptionalTypeSyntax.self)
            guard isOptional else {
                continue
            }

            return PropertyAttributes(propertyName: propertyName)

        }
        return nil
    }
}
