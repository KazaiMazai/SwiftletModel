//
//  WrapperType.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

 enum WrapperType: String, CaseIterable {
        case fullTextIndex = "FullTextIndex"
        case unique = "Unique"
        case index = "Index"
        case relationship = "Relationship"
        
        var title: String {
            rawValue
        }
    }
