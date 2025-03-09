//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation

@propertyWrapper
public struct Unique<Entity>: Sendable, Codable {
    public enum Value<T> { }
    
    public enum ResolveDuplicates {
        case upsert
        case `throw`
    }
    
    public var wrappedValue: Value<Entity>.Type {
        Value<Entity>.self
    }
    
    public init<T0>(
        resolveDuplicates: ResolveDuplicates = .upsert,
        _ kp0: KeyPath<Entity, T0>)
    where
    T0: Comparable {
        
    }
    
    public init<T0, T1>(
        resolveDuplicates: ResolveDuplicates = .upsert,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>)
    where
    T0: Comparable,
    T1: Comparable {
        
    }
    
    public init<T0, T1, T2>(
        resolveDuplicates: ResolveDuplicates = .upsert,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>)
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
    }
    
    public init<T0, T1, T2, T3>(
        resolveDuplicates: ResolveDuplicates = .upsert,
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
