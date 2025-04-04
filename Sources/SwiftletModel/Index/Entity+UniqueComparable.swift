//
//  EntityModel+UniqueIndex.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

extension EntityModelProtocol {
    func updateIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T: Comparable {
        
        try UniqueIndex.ComparableValue.updateIndex(
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
    T0: Comparable,
    T1: Comparable  {
        
        try UniqueIndex.ComparableValue.updateIndex(
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
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        try UniqueIndex.ComparableValue.updateIndex(
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
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        try UniqueIndex.ComparableValue.updateIndex(
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
    T: Comparable {
        
        try UniqueIndex.ComparableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }
    
    func removeFromIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable {
        
        try UniqueIndex.ComparableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }
    
    func removeFromIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        try UniqueIndex.ComparableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }
    
    func removeFromIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        try UniqueIndex.ComparableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}




