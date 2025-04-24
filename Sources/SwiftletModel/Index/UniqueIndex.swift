//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 05/04/2025.
//

import Foundation

@MainActor
@propertyWrapper 
public struct Unique<Entity: EntityModelProtocol>: Sendable, Codable {
    
    public var wrappedValue: Unique<Entity> {
        self
    }
 
    public init<T0>(
         _ kp0: KeyPath<Entity, T0>,
         collisions: CollisionResolver<Entity> = .upsert)
    where
    T0: Comparable {
        
    }
    
    public init<T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        collisions: CollisionResolver<Entity> = .upsert)
    where
    T0: Comparable,
    T1: Comparable {
        
    }
    
    public init<T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        collisions: CollisionResolver<Entity> = .upsert)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
    }
    
    public init<T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>,
        collisions: CollisionResolver<Entity> = .upsert)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
    }
 
    public init<T0>(
        _ kp0: KeyPath<Entity, T0>,
        collisions: CollisionResolver<Entity> = .upsert)
    where
    T0: Equatable {
        
    }
    
    public init<T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        collisions: CollisionResolver<Entity> = .upsert)
    where
    T0: Equatable,
    T1: Equatable {
        
    }
    
    public init<T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        collisions: CollisionResolver<Entity> = .upsert)
    
    where
    T0: Equatable,
    T1: Equatable,
    T2: Equatable {
        
    }
    
    public init<T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>,
        collisions: CollisionResolver<Entity> = .upsert)
    
    where
    T0: Equatable,
    T1: Equatable,
    T2: Equatable,
    T3: Equatable {
        
    }
}
