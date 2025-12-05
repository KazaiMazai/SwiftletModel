//
//  VariableDeclSyntax+Properties.swift
//  Crocodil
//
//  Created by Serge Kazakov on 30/06/2025.
//
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

extension VariableDeclSyntax {
    func propertiesAttributes() -> PropertyAttributes? {
        guard !modifiers.contains(where: { $0.name == "static" }) else {
            return nil
        }

        var propertyInferredType: TypeSyntax?
        if let firstBinding = bindings.first,
           let typeAnnotation = firstBinding.typeAnnotation {
            propertyInferredType = typeAnnotation.type
        }

        for binding in bindings {
            guard let propertyName = binding.pattern.as(IdentifierPatternSyntax.self)?.identifier.text,
                  let initializer = binding.initializer
            else {
                continue
            }

            return PropertyAttributes(
                propertyName: propertyName,
                propertyType: binding.typeAnnotation?.type,
                propertyInferredType: propertyInferredType,
                initializerClauseSyntax: initializer,
                accessAttribute: accessAttribute()
            )
        }
        return nil
    }

    func accessAttribute() -> AccessAttribute {
        modifiers
            .compactMap { $0.name.text }
            .compactMap { AccessAttribute(rawValue: $0) }
            .first ?? .missingAttribute
    }
}
