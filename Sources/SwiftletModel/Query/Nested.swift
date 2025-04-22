//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

public enum Nested {
    case ids
    case entities(MetadataPredicate?, schemaQuery: Bool)
    case fragments(MetadataPredicate?, schemaQuery: Bool)
}

public extension Nested {
    static var entities: Nested {
        .entities(nil, schemaQuery: false)
    }
    
    static var fragments: Nested {
        .fragments(nil, schemaQuery: false)
    }
    
    static func entities(filter: MetadataPredicate) -> Nested {
        .entities(filter, schemaQuery: false)
    }
    
    static func fragments(filter: MetadataPredicate) -> Nested {
        .entities(filter, schemaQuery: false)
    }
    
    static func schemaEntities(filter: MetadataPredicate) -> Nested {
        .entities(filter, schemaQuery: true)
    }
    
    static func schemaFragments(filter: MetadataPredicate) -> Nested {
        .entities(filter, schemaQuery: true)
    }
}
