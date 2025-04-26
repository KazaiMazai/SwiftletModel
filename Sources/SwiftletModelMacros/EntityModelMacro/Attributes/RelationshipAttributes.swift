//
//  File.swift
//  
//
//  Created by Serge Kazakov on 10/08/2024.
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
    let propertyWrapperType: PropertyWrapperAttributes
    let propertyName: String
    let keyPathAttributes: KeyPathAttributes
    let deleteRule: DeleteRuleAttribute
}

extension RelationshipAttributes {
   enum DeleteRuleAttribute: String, CaseIterable {
         static let deleteRule = "deleteRule"

         case cascade
         case nullify

         init?(_ expressionString: String) {
             let value = Self.allCases.first { expressionString.contains($0.rawValue) }
             guard let value else {
                 return nil
             }

             self = value
         }

         init(labeledExprListSyntax: LabeledExprListSyntax) {
             self = labeledExprListSyntax
                 .filter { $0.labelString?.contains(DeleteRuleAttribute.deleteRule) ?? false }
                 .compactMap { DeleteRuleAttribute($0.expressionString) }
                 .first ?? .nullify
         }
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
