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


struct IndexAttributes {
    let relationWrapperType: WrapperType
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
}

extension IndexAttributes {
   
//    enum WrapperType: String, CaseIterable {
//        case relationship = "Index"
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
}
