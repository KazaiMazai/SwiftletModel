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
            
            let attributes = declaration.memberBlock.members
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                .compactMap { extractRelationshipPropertyWrappersAttributes(from: $0) }
            
            let optionalProperties = declaration.memberBlock.members
                .compactMap { $0.decl.as(VariableDeclSyntax.self) }
                .compactMap { extractOptionalPropertiesAttributes(from: $0) }
            
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
                            .map { ".patch(\\.\($0.propertyName))"}
                            .joined(separator: ",\n")
                        )
                    )
                }()
            }
            """
            )
            
            return [syntax]
        }
}

private extension EntityModelMacro {
    
    static func extractRelationshipPropertyWrappersAttributes(from vars: VariableDeclSyntax) -> RelationshipAttributes? {
        for attribute in vars.attributes {
            guard let customAttribute = attribute.as(AttributeSyntax.self),
                let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
                let wrapperType = RelationshipAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text)
            else {
                continue
            }
            
            guard let binding = vars.bindings.first(where: { $0.pattern.as(IdentifierPatternSyntax.self)?.identifier.text != nil }),
                  let property = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
            else {
                return nil
            }
           
            guard let keyPathsExprList = customAttribute
                .arguments?
                .as(LabeledExprListSyntax.self)?
                .filter(\.isKeyPath), !keyPathsExprList.isEmpty
            else {
                
                return RelationshipAttributes(
                    relationWrapperType: wrapperType,
                    propertyName: property,
                    keyPathAttributes: .init(propertyIdentifier: property)
                )
            }
             
            return RelationshipAttributes(
                relationWrapperType: wrapperType,
                propertyName: property,
                keyPathAttributes: .init(propertyIdentifier: property,
                                         labeledKeyPathsList: keyPathsExprList)
            )
        }
        return nil
    }
    
    static func extractOptionalPropertiesAttributes(from vars: VariableDeclSyntax) -> PropertyAttributes? {
        for attribute in vars.attributes {
            
            if let customAttribute = attribute.as(AttributeSyntax.self),
               let identifierTypeSyntax = customAttribute.attributeName.as(IdentifierTypeSyntax.self),
               let _ = RelationshipAttributes.WrapperType(rawValue: identifierTypeSyntax.name.text) {
                return nil
            }
        }
        
        guard vars.modifiers.first?.name.text != "static" else {
            return nil
        }
         
        for binding in vars.bindings {
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

