//
//  File.swift
//
//
//  Created by Sergey Kazakov on 16/08/2024.
//

import Foundation

extension EntityModelProtocol {
    func addToIndex<T>(_ keyPath: KeyPath<Self, T>,
                       in context: inout Context) throws
    
    where T: Comparable {
 
        var index = Self.index(keyPath, in: context) ?? IndexModel(name: .indexName(keyPath))

        index.add(self, value: self[keyPath: keyPath])
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1>(_ kp0: KeyPath<Self, T0>,
                            _ kp1: KeyPath<Self, T1>,
                            in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
 
        var index = Self.index(kp0, kp1, in: context) ?? IndexModel(name: .indexName(kp0, kp1))

        index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1])))
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1, T2>(_ kp0: KeyPath<Self, T0>,
                                _ kp1: KeyPath<Self, T1>,
                                _ kp2: KeyPath<Self, T2>,
                                in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {
 
        var index = Self.index(kp0, kp1, kp2, in: context) ?? IndexModel(name: .indexName(kp0, kp1, kp2))

        index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])))
        try index.save(to: &context)
    }
    
    func addToIndex<T0, T1, T2, T3>(_ kp0: KeyPath<Self, T0>,
                                    _ kp1: KeyPath<Self, T1>,
                                    _ kp2: KeyPath<Self, T2>,
                                    _ kp3: KeyPath<Self, T3>,
                                    in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable,
          T3: Comparable
    {

 
        var index = Self.index(kp0, kp1, kp2, kp3, in: context) ?? IndexModel(name: .indexName(kp0, kp1, kp2, kp3))

        index.add(self, value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])))
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    func removeFromIndex<T>(_ keyPath: KeyPath<Self, T>,
                            in context: inout Context) throws
    
    where T: Comparable {
        
        guard var index = Self.index(keyPath, in: context) else {
            return
        }
       
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1>(_ kp0: KeyPath<Self, T0>,
                                 _ kp1: KeyPath<Self, T1>,
                                 in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable
    {
 
        guard var index = Self.index(kp0, kp1, in: context) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1, T2>(_ kp0: KeyPath<Self, T0>,
                                     _ kp1: KeyPath<Self, T1>,
                                     _ kp2: KeyPath<Self, T2>,
                                     in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable
    {

        guard var index = Self.index(kp0, kp1, kp2, in: context) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
    
    func removeFromIndex<T0, T1, T2, T3>(_ kp0: KeyPath<Self, T0>,
                                         _ kp1: KeyPath<Self, T1>,
                                         _ kp2: KeyPath<Self, T2>,
                                         _ kp3: KeyPath<Self, T3>,
                                         in context: inout Context) throws
    where T0: Comparable,
          T1: Comparable,
          T2: Comparable,
          T3: Comparable
    {

        guard var index = Self.index(kp0, kp1, kp2, kp3, in: context) else {
            return
        }
        
        index.remove(self)
        try index.save(to: &context)
    }
}

extension EntityModelProtocol {
    static func index<T>(_ keyPath: KeyPath<Self, T>,
                         in context: Context) -> IndexModel<Self, T>? {
        IndexModel
            .query(.indexName(keyPath), in: context)
            .resolve()
    }
    
    static func index<T0, T1>(_ kp0: KeyPath<Self, T0>,
                              _ kp1: KeyPath<Self, T1>,
                              in context: Context) -> IndexModel<Self, Pair<T0, T1>>? {
        IndexModel
            .query(.indexName(kp0, kp1), in: context)
            .resolve()
    }
    
    static func index<T0, T1, T2>(_ kp0: KeyPath<Self, T0>,
                                  _ kp1: KeyPath<Self, T1>,
                                  _ kp2: KeyPath<Self, T2>,
                                  in context: Context) -> IndexModel<Self, Triplet<T0, T1, T2>>? {
        IndexModel
            .query(.indexName(kp0, kp1, kp2), in: context)
            .resolve()
    }
    
    static func index<T0, T1, T2, T3>(_ kp0: KeyPath<Self, T0>,
                                      _ kp1: KeyPath<Self, T1>,
                                      _ kp2: KeyPath<Self, T2>,
                                      _ kp3: KeyPath<Self, T3>,
                                      in context: Context) -> IndexModel<Self, Quadruple<T0, T1, T2, T3>>? {
        IndexModel
            .query(.indexName(kp0, kp1, kp2, kp3), in: context)
            .resolve()
    }
}

extension String {
    static func indexName<Entity, T>(_ keyPath: KeyPath<Entity, T>) -> String {
        keyPath.name
    }
    
    static func indexName<Entity, T0, T1>(_ kp0: KeyPath<Entity, T0>,
                                  _ kp1: KeyPath<Entity, T1>) -> String {
        [kp0, kp1]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2>(_ kp0: KeyPath<Entity, T0>,
                                      _ kp1: KeyPath<Entity, T1>,
                                      _ kp2: KeyPath<Entity, T2>) -> String {
        [kp0, kp1, kp2]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2, T3>(_ kp0: KeyPath<Entity, T0>,
                                          _ kp1: KeyPath<Entity, T1>,
                                          _ kp2: KeyPath<Entity, T2>,
                                          _ kp3: KeyPath<Entity, T3>) -> String {
        [kp0, kp1, kp2, kp3]
            .map { $0.name }
            .joined(separator: "-")
    }
}
