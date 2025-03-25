//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation

extension EntitiesRepository {
    func index<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> SortIndex<Entity>.ComparableValue<T>? {

            find(.indexName(keyPath))
    }
    
    func index<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> SortIndex<Entity>.ComparableValue<Pair<T0, T1>>? {
        
            find(.indexName(kp0, kp1))
    }
    
    func index<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> SortIndex<Entity>.ComparableValue<Triplet<T0, T1, T2>>? {
        
            find(.indexName(kp0, kp1, kp2))
    }
    
    func index<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> SortIndex<Entity>.ComparableValue<Quadruple<T0, T1, T2, T3>>? {
        
        find(.indexName(kp0, kp1, kp2, kp3))
    }
}

extension EntitiesRepository {
    func uniqueIndex<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> UniqueIndex<Entity>.HashableValue<T>?
    where
    T: Hashable {
        
        find(.indexName(keyPath))
    }
    
    func uniqueIndex<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> UniqueIndex<Entity>.HashableValue<Pair<T0, T1>>?
    where
    T0: Hashable,
    T1: Hashable {
        
        find(.indexName(kp0, kp1))
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> UniqueIndex<Entity>.HashableValue<Triplet<T0, T1, T2>>?
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable {
        
            find(.indexName(kp0, kp1, kp2))
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> UniqueIndex<Entity>.HashableValue<Quadruple<T0, T1, T2, T3>>?
    where
    T0: Hashable,
    T1: Hashable,
    T2: Hashable,
    T3: Hashable {
        
        find(.indexName(kp0, kp1, kp2, kp3))
    }
}

extension EntitiesRepository {
    func uniqueIndex<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> UniqueIndex<Entity>.ComparableValue<T>?
    where
    T: Comparable {
        
        find(.indexName(keyPath))
    }
    
    func uniqueIndex<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> UniqueIndex<Entity>.ComparableValue<Pair<T0, T1>>?
    where
    T0: Comparable,
    T1: Comparable {
        
        find(.indexName(kp0, kp1))
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> UniqueIndex<Entity>.ComparableValue<Triplet<T0, T1, T2>>?
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
            
        find(.indexName(kp0, kp1, kp2))
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> UniqueIndex<Entity>.ComparableValue<Quadruple<T0, T1, T2, T3>>?
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        find(.indexName(kp0, kp1, kp2, kp3))
    }
}

extension String {
    static func indexName<Entity, T>(
        _ keyPath: KeyPath<Entity, T>) -> String {
        keyPath.name
    }
    
    static func indexName<Entity, T0, T1>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> String {
        
        return [kp0, kp1]
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> String {
        
        return [kp0, kp1, kp2]  
            .map { $0.name }
            .joined(separator: "-")
    }
    
    static func indexName<Entity, T0, T1, T2, T3>(
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> String {
        
        return [kp0, kp1, kp2, kp3]
            .map { $0.name }
            .joined(separator: "-")
    }
}
