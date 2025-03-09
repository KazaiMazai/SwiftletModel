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
    let duplicates: DuplicatesAttribute
}

extension UniqueAttributes {
   
    enum WrapperType: String, CaseIterable {
        case unique = "Unique"
        
        var title: String {
            rawValue
        }
    }
    
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
    
    enum DuplicatesAttribute: String, CaseIterable {
        static let duplicates = "duplicates"
        
        case upsert
        case `throw`
        
        init?(_ expressionString: String) {
            let value = Self.allCases.first { expressionString.contains($0.rawValue) }
            guard let value else {
                return nil
            }
            
            self = value
        }
        
        init(labeledExprListSyntax: LabeledExprListSyntax) {
            self = labeledExprListSyntax
                .filter { $0.labelString?.contains(DuplicatesAttribute.duplicates) ?? false }
                .compactMap { DuplicatesAttribute($0.expressionString) }
                .first ?? .upsert
        }
    }
}
