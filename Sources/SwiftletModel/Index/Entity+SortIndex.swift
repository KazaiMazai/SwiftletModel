//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/08/2024.
//

import Foundation

extension EntityModelProtocol {
    func addToIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    where T: Comparable {
        var index = context.index(keyPath) ??
             SortIndex<Self>.ComparableValue(name: .indexName(keyPath))
        try index.add(self, value: self[keyPath: keyPath], in: &context)
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
        var index = context.index(kp0, kp1) ??
            SortIndex<Self>.ComparableValue(name: .indexName(kp0, kp1))
         try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
         in: &context
        )
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {
        var index = context.index(kp0, kp1, kp2) ??
            SortIndex<Self>.ComparableValue(name: .indexName(kp0, kp1, kp2))
        try index.add(self,
                value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])), 
                in: &context
        )
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1, T2, T3>(
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
        var index = context.index(kp0, kp1, kp2, kp3) ??
                SortIndex<Self>.ComparableValue(name: .indexName(kp0, kp1, kp2, kp3))
        try index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])), in: &context)
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    func removeFromIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    where T: Comparable {
        guard var index = context.index(keyPath) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
        guard var index = context.index(kp0, kp1) else {
            return
        }
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {
        guard var index = context.index(kp0, kp1, kp2) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1, T2, T3>(
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
        guard var index = context.index(kp0, kp1, kp2, kp3) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
}
