//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 13/03/2025.
//

import Foundation

public extension EntityModelProtocol {
    func updateUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T: Hashable {
        
        try Unique.HashableValue.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable {
        
        try Unique.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable {
        
        try Unique.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable,
    T3: Hashable {
        
        try Unique.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolver
        )
    }
}


public extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    
    where
    T: Hashable {
        
        try Unique.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable {
        
        try Unique.HashableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable {
        
        try Unique.HashableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable,
    T3: Hashable {
        
        try Unique.HashableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}
