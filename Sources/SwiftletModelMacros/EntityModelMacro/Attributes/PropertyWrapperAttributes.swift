//
//  WrapperType.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 07/04/2025.
//

 enum PropertyWrapperAttributes: String, CaseIterable {
        case fullTextIndex = "FullTextIndex"
        case unique = "Unique"
        case index = "Index"
        case hashIndex = "HashIndex"
        case relationship = "Relationship"

         static var indexAttributes: [PropertyWrapperAttributes] {
             [.index, .hashIndex, .unique , .fullTextIndex]
         }
             
         
     
        var title: String {
            rawValue
        }
    }
