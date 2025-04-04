//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 08/03/2025.
//

import Foundation

@propertyWrapper
public struct Index<Entity: EntityModelProtocol>: Sendable, Codable {
    let indexName: String
   
    public var wrappedValue: Index<Entity> {
        self
    }
    
    public init<T0>(_ kp0: KeyPath<Entity, T0>)
    where
    T0: Comparable {
        indexName = .indexName(kp0)
    }
    
    public init<T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>)
    where
    T0: Comparable,
    T1: Comparable {
        indexName = .indexName(kp0, kp1)
    }
    
    public init<T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        indexName = .indexName(kp0, kp1, kp2)
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
        indexName = .indexName(kp0, kp1, kp2, kp3)
    }
}

@propertyWrapper
public struct Unique<Entity: EntityModelProtocol>: Sendable, Codable {
    
    public var wrappedValue: Unique<Entity>.Type {
        Unique<Entity>.self
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
