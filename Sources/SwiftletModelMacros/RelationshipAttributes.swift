//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 10/08/2024.
//

import Foundation
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

#if !canImport(SwiftSyntax600)
  import SwiftSyntaxMacroExpansion
#endif

struct RelationshipAttributes {
    let relationWrapperType: WrapperType
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
}

extension RelationshipAttributes {
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
        
        init(propertyIdentifier: String,
             labeledExprListSyntax: LabeledExprListSyntax) {
            
            let keyPathAttributes = labeledExprListSyntax
                .filter(\.isKeyPath)
                .map {
                    
                    let label = $0.labelString.map { "\($0): "} ?? ""
                    let expression = $0.expressionString.replacingOccurrences(of: ".", with: ".$")
                    return "\(label)\(expression)"
                }
            
            guard !keyPathAttributes.isEmpty else {
                self = .init(propertyIdentifier: propertyIdentifier)
                return
            }
            
            let attributes = [["\\.$\(propertyIdentifier)"], keyPathAttributes]
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
}
