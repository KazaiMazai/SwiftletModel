//
//  EntityModel+UniqueIndex.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

extension EntityModelProtocol {
    func addToUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T: Comparable {
        
        var index = context.index(keyPath) ??
        UniqueIndex<Self>.ComparableValue<T>(name: .indexName(keyPath))
        try index.add(
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolveCollisions
        )
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable  {
        
        var index = context.index(kp0, kp1) ??
        UniqueIndex<Self>.ComparableValue<Pair<T0, T1>>(name: .indexName(kp0, kp1))
        try index.add(
            self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        var index = context.index(kp0, kp1, kp2) ??
        UniqueIndex<Self>.ComparableValue<Triplet<T0, T1, T2>>(name: .indexName(kp0, kp1, kp2))
        try index.add(
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        var index = context.index(kp0, kp1, kp2, kp3) ??
        UniqueIndex<Self>.ComparableValue<Quadruple<T0, T1, T2, T3>>(name: .indexName(kp0, kp1, kp2, kp3))
        try index.add(
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolveCollisions
        )
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    
    where
    T: Comparable {
        
        guard var index: UniqueIndex<Self>.ComparableValue<T> = context.index(keyPath) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable {
        
        guard var index: UniqueIndex<Self>.ComparableValue<Pair<T0, T1>> = context.index(kp0, kp1) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        guard var index: UniqueIndex<Self>.ComparableValue<Triplet<T0, T1, T2>> = context.index(kp0, kp1, kp2) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        in context: inout Context) throws
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        guard var index: UniqueIndex<Self>.ComparableValue<Quadruple<T0, T1, T2, T3>> = context.index(kp0, kp1, kp2, kp3) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
}




