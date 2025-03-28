//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 13/03/2025.
//

import Foundation

extension EntityModelProtocol {
    func updateUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T: Hashable {
        
        try UniqueIndex.HashableValue.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable {
        
        try UniqueIndex.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable {
        
        try UniqueIndex.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable,
    T3: Hashable {
        
        try UniqueIndex.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
}


extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    
    where
    T: Hashable {
        
        try UniqueIndex.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    
    where
    T0: Hashable,
    T1: Hashable {
        
        try UniqueIndex.HashableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
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
        
        try UniqueIndex.HashableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
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
        
        try UniqueIndex.HashableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}

extension EntityModelProtocol {
    func updateUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T: Hashable & Comparable {
        try UniqueIndex.HashableValue<T>.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable {
        try UniqueIndex.HashableValue<Pair<T0, T1>>.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable {
        try UniqueIndex.HashableValue<Triplet<T0, T1, T2>>.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
    
    func updateUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable,
    T3: Hashable & Comparable {
        
        try UniqueIndex.HashableValue<Quadruple<T0, T1, T2, T3>>.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
    }
}


extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T: Hashable & Comparable {
        
        try UniqueIndex.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable {
        try UniqueIndex.HashableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable {
        try UniqueIndex.HashableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where
    T0: Hashable & Comparable,
    T1: Hashable & Comparable,
    T2: Hashable & Comparable,
    T3: Hashable & Comparable {
        try UniqueIndex.HashableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}
