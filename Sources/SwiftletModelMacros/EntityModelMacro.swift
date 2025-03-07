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
            
            return try ExtensionDeclSyntax.entityModelMacro(
                of: node,
                attachedTo: declaration,
                providingExtensionsOf: type,
                conformingTo: protocols,
                in: context
            )
        }
}
 
extension SwiftSyntax.ExtensionDeclSyntax {
    static func entityModelMacro(
        of node: SwiftSyntax.AttributeSyntax,
        attachedTo declaration: some SwiftSyntax.DeclGroupSyntax,
        providingExtensionsOf type: some SwiftSyntax.TypeSyntaxProtocol,
        conformingTo protocols: [SwiftSyntax.TypeSyntax],
        in context: some SwiftSyntaxMacros.MacroExpansionContext) throws -> [SwiftSyntax.ExtensionDeclSyntax] {
            
            let accessAttribute = declaration.accessAttribute()
            
            let variableDeclarations = declaration
                .memberBlock
                .members
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
            
            let relationshipAttributes = variableDeclarations
                .compactMap { $0.relationshipAttributes() }

            let optionalProperties = variableDeclarations
                .compactMap { $0.optionalPropertiesAttributes() }

            let entityModelProtocol = try ExtensionDeclSyntax.entityModelProtocol(
                type: type,
                conformingTo: protocols,
                relationshipAttributes: relationshipAttributes,
                optionalProperties: optionalProperties,
                accessAttribute: accessAttribute
            )
            
//            let queryExtension = try ExtensionDeclSyntax.queryExtension(
//                type: type,
//                conformingTo: protocols,
//                relationshipAttributes: relationshipAttributes,
//                optionalProperties: optionalProperties,
//                accessAttribute: accessAttribute
//            )
//            
//            let collectionExtension = try ExtensionDeclSyntax.collectionExtension(
//                type: type,
//                conformingTo: protocols,
//                relationshipAttributes: relationshipAttributes,
//                optionalProperties: optionalProperties,
//                accessAttribute: accessAttribute
//            )
            
            return [entityModelProtocol]
        }
}

extension ExtensionDeclSyntax {
    static func entityModelProtocol(type: some SwiftSyntax.TypeSyntaxProtocol,
                                    conformingTo protocols: [SwiftSyntax.TypeSyntax],
                                    relationshipAttributes: [RelationshipAttributes],
                                    optionalProperties: [PropertyAttributes],
                                    accessAttribute: AccessAttribute
                                            
    ) throws -> ExtensionDeclSyntax {
        let protocolsString = protocols.map { "\($0)" }
            .joined(separator: ",")
            .trimmingCharacters(in: .whitespaces)
        
        return try ExtensionDeclSyntax(
        """
        extension \(raw: type): \(raw: protocolsString) {
            \(raw: FunctionDeclSyntax.save(accessAttribute, relationshipAttributes))
            \(raw: FunctionDeclSyntax.delete(accessAttribute, relationshipAttributes))
            \(raw: FunctionDeclSyntax.normalize(accessAttribute, relationshipAttributes))
            \(raw: FunctionDeclSyntax.batchQuery(accessAttribute, relationshipAttributes))
            \(raw: FunctionDeclSyntax.nestedQuery(accessAttribute, relationshipAttributes))
            \(raw: VariableDeclSyntax.patch(accessAttribute, optionalProperties))
         
        }
        """
        )
    }
//    
//    static func queryExtension(type: some SwiftSyntax.TypeSyntaxProtocol,
//                                    conformingTo protocols: [SwiftSyntax.TypeSyntax],
//                                    relationshipAttributes: [RelationshipAttributes],
//                                    optionalProperties: [PropertyAttributes],
//                                    accessAttribute: AccessAttribute
//                                            
//    ) throws -> ExtensionDeclSyntax {
//        return try ExtensionDeclSyntax(
//        """
//        extension Query where Entity == \(raw: type) {
//            \(raw: FunctionDeclSyntax.nestedQuery(type, accessAttribute, relationshipAttributes))
//        }
//        """
//        )
//    }
//    
//    static func collectionExtension(type: some SwiftSyntax.TypeSyntaxProtocol,
//                                    conformingTo protocols: [SwiftSyntax.TypeSyntax],
//                                    relationshipAttributes: [RelationshipAttributes],
//                                    optionalProperties: [PropertyAttributes],
//                                    accessAttribute: AccessAttribute
//                                            
//    ) throws -> ExtensionDeclSyntax {
//        return try ExtensionDeclSyntax(
//        """
//        extension Collection {
//            \(raw: FunctionDeclSyntax.nestedQueryCollection(type, accessAttribute, relationshipAttributes))
//        }
//        """
//        )
//    }
}

extension FunctionDeclSyntax {
    static func save(
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
         
        \(raw: accessAttributes.name) func save(to context: inout Context, options: MergeStrategy<Self> = .default) throws {
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
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        \(raw: accessAttributes.name) func delete(from context: inout Context) throws {
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
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        \(raw: accessAttributes.name) mutating func normalize() {
           \(raw: attributes
                .map { "$\($0.propertyName).normalize()" }
                .joined(separator: "\n")
            )
        }
        """
        )
    }
    
    static func batchQuery(
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
        
        \(raw: accessAttributes.name) static func batchQuery(in context: Context) -> [Query<Self>] {
            Self.query(in: context)
                .with(.ids)
        }
        """
        )
    }
    
    static func nestedQuery(
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
            
        \(raw: accessAttributes.name) static func nested(_ nested: Nested, query: Query<Self>) -> Query<Self> {
            return switch nested {
            case .none:
                query
            case .ids:
                query\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".id(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .fragments:
                query\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".fragment(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .entities:
                query\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".with(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .nested:
                query\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".with(\($0)) { $0.with(nested.next) }"}
                    .joined(separator: "\n    ")
                )
            }
        }
        """
        )
    }
    
    
    static func nestedQueryCollection(
        _ type: some SwiftSyntax.TypeSyntaxProtocol,
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        try FunctionDeclSyntax(
        """
        \(raw: accessAttributes.name) func with(_ nested: Nested)) -> [Query<Entity>] where Element == Query<Entity> {
            map { $0.with(nested) }
        }
        """
        )
    }
    
    static func nestedQuery1(
        _ type: some SwiftSyntax.TypeSyntaxProtocol,
        _ accessAttributes: AccessAttribute,
        _ attributes: [RelationshipAttributes]
    ) throws -> FunctionDeclSyntax {
        
        try FunctionDeclSyntax(
        """
            
        \(raw: accessAttributes.name) func with(_ nested: Nested) -> Query<\(raw: type)> {
            return switch nested {
            case .none:
                self
            case .ids:
                self\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".id(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .fragments:
                self\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".fragment(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .entities:
                self\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".with(\($0))"}
                    .joined(separator: "\n    ")
                )
            case .nested:
                self\(raw: attributes
                    .map { "\\.$\($0.propertyName)" }
                    .map { ".with(\($0)) { $0.with(nested.next) }"}
                    .joined(separator: "\n    ")
                )
            }
        }
        """
        )
    }
}



extension VariableDeclSyntax {
    
    static func patch(
        _ accessAttributes: AccessAttribute,
        _ attributes: [PropertyAttributes]
    ) throws -> VariableDeclSyntax {
        
        try VariableDeclSyntax(
        """
        
        \(raw: accessAttributes.name) static var patch: MergeStrategy<Self> {
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

private extension DeclGroupSyntax {
    func accessAttribute() -> AccessAttribute {
        modifiers
            .compactMap { $0.name.text }
            .compactMap { AccessAttribute(rawValue: $0) }
            .first ?? .missingAttribute
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
