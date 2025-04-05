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
    
    public init(_ kp0: KeyPath<Entity, String>) {
        
    }
    
    public init(
        _ kp0: KeyPath<Entity, String>,
        _ kp1: KeyPath<Entity, String>) {
    }
    
    public init(
        _ kp0: KeyPath<Entity, String>,
        _ kp1: KeyPath<Entity, String>,
        _ kp2: KeyPath<Entity, String>) {
    }
    
    public init(
        _ kp0: KeyPath<Entity, String>,
        _ kp1: KeyPath<Entity, String>,
        _ kp2: KeyPath<Entity, String>,
        _ kp3: KeyPath<Entity, String>) {
    }
}
