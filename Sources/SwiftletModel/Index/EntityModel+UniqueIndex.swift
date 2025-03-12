//
//  EntityModel+UniqueIndex.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

extension EntityModelProtocol {
    func addToUniqueIndex<T>(
        _ indexType: IndexType<Self>,
        _ keyPath: KeyPath<Self, T>,
        resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    
    where T: Comparable {
        var index = context.uniqueIndex(indexType, keyPath) ??
            UniqueComparableValueIndex(name: .indexName(indexType, keyPath), indexType: indexType)
        try index.add(self, value: self[keyPath: keyPath], in: &context, resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1>(
        _ indexType: IndexType<Self>,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1) ??
            UniqueComparableValueIndex(name: .indexName(indexType, kp0, kp1), indexType: indexType)
         try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
                      in: &context,
                      resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2>(_ indexType: IndexType<Self>,
                                _ kp0: KeyPath<Self, T0>,
                                _ kp1: KeyPath<Self, T1>,
                                _ kp2: KeyPath<Self, T2>,
                                resolveCollisions: CollisionResolver<Self>,
                                in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1, kp2) ??
            UniqueComparableValueIndex(name: .indexName(indexType, kp0, kp1, kp2), indexType: indexType)
        try index.add(self,
                value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
                in: &context,
                resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2, T3>(_ indexType: IndexType<Self>,
                                    _ kp0: KeyPath<Self, T0>,
                                    _ kp1: KeyPath<Self, T1>,
                                    _ kp2: KeyPath<Self, T2>,
                                    _ kp3: KeyPath<Self, T3>,
                                    resolveCollisions: CollisionResolver<Self>,
                                    in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable,
          T3: Comparable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1, kp2, kp3) ??
            UniqueComparableValueIndex(name: .indexName(indexType, kp0, kp1, kp2, kp3), indexType: indexType)
        try index.add(self, 
                     value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])), 
                     in: &context,
                     resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ indexType: IndexType<Self>,
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    
    where T: Comparable {
        guard var index = context.uniqueIndex(indexType, keyPath) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ indexType: IndexType<Self>,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2>(_ indexType: IndexType<Self>,
                                     _ kp0: KeyPath<Self, T0>,
                                     _ kp1: KeyPath<Self, T1>,
                                     _ kp2: KeyPath<Self, T2>,
                                     in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1, kp2) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2, T3>(_ indexType: IndexType<Self>,
                                         _ kp0: KeyPath<Self, T0>,
                                         _ kp1: KeyPath<Self, T1>,
                                         _ kp2: KeyPath<Self, T2>,
                                         _ kp3: KeyPath<Self, T3>,
                                         in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable,
          T3: Comparable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1, kp2, kp3) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
}

