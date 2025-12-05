//
//  PropertyAttributes.swift
//  Crocodil
//
//  Created by Serge Kazakov on 30/06/2025.
//
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros

struct PropertyAttributes {
    let propertyName: String
    let propertyType: TypeSyntax?
    let propertyInferredType: TypeSyntax?
    let initializerClauseSyntax: InitializerClauseSyntax
    let accessAttribute: AccessAttribute

    var initializerClause: String {
        propertyType.map { ":\($0) \(initializerClauseSyntax)" } ?? "\(initializerClauseSyntax)"
    }

    var keyName: String { "\(propertyName.capitalized)Key" }
}
