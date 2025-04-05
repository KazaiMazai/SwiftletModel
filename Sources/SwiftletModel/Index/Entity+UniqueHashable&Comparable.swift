//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 13/03/2025.
//

import Foundation


extension EntityModelProtocol {
    func updateIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T: Hashable & Comparable {
        try Unique.HashableValue<T>.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable {
        try Unique.HashableValue<Pair<T0, T1>>.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable {
        try Unique.HashableValue<Triplet<T0, T1, T2>>.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolver
        )
    }
    
    func updateIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable,
    T3: Hashable & Comparable {
        
        try Unique.HashableValue<Quadruple<T0, T1, T2, T3>>.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolver
        )
    }
}


extension EntityModelProtocol {
    func removeFromIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T: Hashable & Comparable {
        
        try Unique.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }
    
    func removeFromIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable {
        try Unique.HashableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }
    
    func removeFromIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable {
        try Unique.HashableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }
    
    func removeFromIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable,
    T3: Hashable & Comparable {
        try Unique.HashableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}
