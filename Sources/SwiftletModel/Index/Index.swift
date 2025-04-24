//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper @MainActor
public struct Index<Entity: EntityModelProtocol>: Sendable, Codable {
    public var wrappedValue: Index<Entity>.Type {
        Self.self
    }
     
    public init<T0>(_ kp0: KeyPath<Entity, T0>)
    where
    T0: Comparable {
         
    }
    
    public init<T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>)
    where
    T0: Comparable,
    T1: Comparable {
         
    }
    
    public init<T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
         
    }
    
    public init<T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
         
    }
}

