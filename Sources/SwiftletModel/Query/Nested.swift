//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

public enum Nested {
    case ids
    case entities(MetadataPredicate?)
    case fragments(MetadataPredicate?)
}

public extension Nested {
    static var entities: Nested {
        .entities(nil)
    }
    
    static var fragments: Nested {
        .fragments(nil)
    }
    
    static func entities(filter: MetadataPredicate) -> Nested {
        .entities(filter)
    }
    
    static func fragments(filter: MetadataPredicate) -> Nested {
        .entities(filter)
    }
}
