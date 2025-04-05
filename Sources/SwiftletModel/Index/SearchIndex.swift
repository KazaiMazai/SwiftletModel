//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct SearchIndex<Entity: EntityModelProtocol>: Sendable, Codable {
    public var wrappedValue: SearchIndex<Entity> {
        self
    }
    
    public init(_ keypath: KeyPath<Entity, String>) {
        
    }
}
