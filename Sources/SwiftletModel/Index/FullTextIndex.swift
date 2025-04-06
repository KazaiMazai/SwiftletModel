//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct FullTextIndex<Entity: EntityModelProtocol>: Sendable, Codable {
   
    public var wrappedValue: FullTextIndex<Entity> {
        self
    }
    
    public init(_ keypaths: KeyPath<Entity, String>...) {
        
    }
}
