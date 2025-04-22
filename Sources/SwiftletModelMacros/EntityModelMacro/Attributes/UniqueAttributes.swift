//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 09/03/2025.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif

struct UniqueAttributes {
    let propertyWrapper: PropertyWrapperAttributes
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
    let collisions: CollisionsResolverAttributes
}

extension UniqueAttributes {
   enum KeyPathAttributes {
        case labeledExpressionList(String)
        case propertyIdentifier(String)
        
        init(propertyIdentifier: String,
             labeledExprListSyntax: LabeledExprListSyntax) {
            
            let keyPathAttributes = labeledExprListSyntax
                .filter(\.isKeyPath)
                .map { $0.expressionString }
            
            guard !keyPathAttributes.isEmpty else {
                self = .init(propertyIdentifier: propertyIdentifier)
                return
            }
            
            let attributes = [keyPathAttributes]
                .flatMap { $0 }
                .joined(separator: ",")
            
            self = .labeledExpressionList(attributes)
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
    
    struct CollisionsResolverAttributes {
        static let collisions = "collisions"
        
        let attributes : String
        static let upsert: CollisionsResolverAttributes = {
            CollisionsResolverAttributes(attributes: ".upsert")
        }()
        
        init(attributes: String) {
            self.attributes = attributes
        }
        
        init?(_ expressionString: String) {
            attributes = expressionString
        }
        
        init(labeledExprListSyntax: LabeledExprListSyntax) {
            self = labeledExprListSyntax
                .filter { $0.labelString?.contains(CollisionsResolverAttributes.collisions) ?? false }
                .compactMap { CollisionsResolverAttributes($0.expressionString) }
                .first ?? .upsert
        }

//        //
//        init?(_ expressionString: String) {
//            let value = Self.allCases.first { expressionString.contains($0.rawValue) }
//            guard let value else {
//                return nil
//            }
//            
//            self = value
//        }
//        
//        init(labeledExprListSyntax: LabeledExprListSyntax) {
//            self = labeledExprListSyntax
//                .filter { $0.labelString?.contains(CollisionsResolverAttributes.collisions) ?? false }
//                .compactMap { CollisionsResolverAttributes($0.expressionString) }
//                .first ?? .upsert
//        }
    }
}
