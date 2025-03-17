//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 13/03/2025.
//

import Foundation

extension EntityModelProtocol {
    func addToUniqueIndex<T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Self, T>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where T: Hashable {
        var index = context.uniqueIndex(indexType, keyPath) ??
            Unique.HashableValueIndex(name: .indexName(indexType, keyPath), indexType: indexType)
        try index.add(self, value: self[keyPath: keyPath], in: &context, resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1) ??
            Unique.HashableValueIndex(name: .indexName(indexType, kp0, kp1), indexType: indexType)
        try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
                     in: &context,
                     resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable,
          T2: Hashable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1, kp2) ??
            Unique.HashableValueIndex(name: .indexName(indexType, kp0, kp1, kp2), indexType: indexType)
        try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
                     in: &context,
                     resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
    
    func addToUniqueIndex<T0, T1, T2, T3>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        _ resolveCollisions: CollisionResolver<Self>,
        in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable,
          T2: Hashable,
          T3: Hashable
    {
        var index = context.uniqueIndex(indexType, kp0, kp1, kp2, kp3) ??
            Unique.HashableValueIndex(name: .indexName(indexType, kp0, kp1, kp2, kp3), indexType: indexType)
        try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
                     in: &context,
                     resolveCollisions: resolveCollisions)
        try index.save(to: &context)
    }
}


extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    
    where T: Hashable {
        guard var index = context.uniqueIndex(indexType, keyPath) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2>(_ indexType: IndexType,
                                     _ kp0: KeyPath<Self, T0>,
                                     _ kp1: KeyPath<Self, T1>,
                                     _ kp2: KeyPath<Self, T2>,
                                     in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable,
          T2: Hashable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1, kp2) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromUniqueIndex<T0, T1, T2, T3>(_ indexType: IndexType,
                                         _ kp0: KeyPath<Self, T0>,
                                         _ kp1: KeyPath<Self, T1>,
                                         _ kp2: KeyPath<Self, T2>,
                                         _ kp3: KeyPath<Self, T3>,
                                         in context: inout Context) throws
    where T0: Hashable,
          T1: Hashable,
          T2: Hashable,
          T3: Hashable
    {
        guard var index = context.uniqueIndex(indexType, kp0, kp1, kp2, kp3) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
}
