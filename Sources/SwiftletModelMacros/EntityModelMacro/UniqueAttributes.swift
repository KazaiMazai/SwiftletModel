//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
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
    let relationWrapperType: WrapperType
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
    let collisions: CollisionsResolverAttribute
}

extension UniqueAttributes {
   
//    enum WrapperType: String, CaseIterable {
//        case unique = "Unique"
//        
//        var title: String {
//            rawValue
//        }
//    }
    
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
    
    struct CollisionsResolverAttribute {
        static let collisions = "collisions"
       
        let attributes: String

        static let upsert: CollisionsResolverAttribute = {
            CollisionsResolverAttribute(attributes: ".upsert")
        }()
        
        init(attributes: String) {
            self.attributes = attributes
        }
        
        init?(_ expressionString: String) {
            attributes = expressionString
        }
        
        init(labeledExprListSyntax: LabeledExprListSyntax) {
            self = labeledExprListSyntax
                .filter { $0.labelString?.contains(CollisionsResolverAttribute.collisions) ?? false }
                .compactMap { CollisionsResolverAttribute($0.expressionString) }
                .first ?? .upsert
        }
    }
}
