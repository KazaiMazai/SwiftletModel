//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation

extension EntitiesRepository {
    func index<Entity, T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Entity, T>) -> SortIndex<Entity, T>? {
        
            find(.indexName(indexType, keyPath))
    }
    
    func index<Entity, T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> SortIndex<Entity, Pair<T0, T1>>? {
        
            find(.indexName(indexType, kp0, kp1))
    }
    
    func index<Entity, T0, T1, T2>(
        _ indexType: IndexType  ,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> SortIndex<Entity, Triplet<T0, T1, T2>>? {
        
            find(.indexName(indexType, kp0, kp1, kp2))
    }
    
    func index<Entity, T0, T1, T2, T3>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> SortIndex<Entity, Quadruple<T0, T1, T2, T3>>? {
        
        find(.indexName(indexType, kp0, kp1, kp2, kp3))
    }
}

extension EntitiesRepository {
    func uniqueIndex<Entity, T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Entity, T>) -> Unique.HashableValueIndex<Entity, T>? where T: Hashable {
        
            find(.indexName(indexType, keyPath))
    }
    
    func uniqueIndex<Entity, T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> Unique.HashableValueIndex<Entity, Pair<T0, T1>>? where T0: Hashable, T1: Hashable {
        
            find(.indexName(indexType, kp0, kp1))
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> Unique.HashableValueIndex<Entity, Triplet<T0, T1, T2>>? where T0: Hashable, T1: Hashable, T2: Hashable {
        
            find(.indexName(indexType, kp0, kp1, kp2))
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> Unique.HashableValueIndex<Entity, Quadruple<T0, T1, T2, T3>>? where T0: Hashable, T1: Hashable, T2: Hashable, T3: Hashable {
        
        find(.indexName(indexType, kp0, kp1, kp2, kp3))
    }
}

extension EntitiesRepository {
    func uniqueIndex<Entity, T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Entity, T>) -> Unique.ComparableValueIndex<Entity, T>? where T: Comparable {
        
            find(.indexName(indexType, keyPath))
    }
    
    func uniqueIndex<Entity, T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> Unique.ComparableValueIndex<Entity, Pair<T0, T1>>? where T0: Comparable, T1: Comparable {
        
            find(.indexName(indexType, kp0, kp1))
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> Unique.ComparableValueIndex<Entity, Triplet<T0, T1, T2>>? where T0: Comparable, T1: Comparable, T2: Comparable {
        
            find(.indexName(indexType, kp0, kp1, kp2))
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> Unique.ComparableValueIndex<Entity, Quadruple<T0, T1, T2, T3>>? where T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable {
        
        find(.indexName(indexType, kp0, kp1, kp2, kp3))
    }
}

extension String {
    static func indexName<Entity, T>(
        _ indexType: IndexType,
        _ keyPath: KeyPath<Entity, T>) -> String {
        "\(indexType.indexName)-\(keyPath.name)"
    }
    
    static func indexName<Entity, T0, T1>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> String {
        
        let keyPaths = [kp0, kp1]
            .map { $0.name }
            .joined(separator: "-")
            
        return "\(indexType.indexName)-\(keyPaths)"
    }
    
    static func indexName<Entity, T0, T1, T2>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> String {
        
        let keyPaths = [kp0, kp1, kp2]
            .map { $0.name }
            .joined(separator: "-")
            
        return "\(indexType.indexName)-\(keyPaths)"
    }
    
    static func indexName<Entity, T0, T1, T2, T3>(
        _ indexType: IndexType,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> String {
        
        let keyPaths = [kp0, kp1, kp2, kp3]
            .map { $0.name }
            .joined(separator: "-")

        return "\(indexType.indexName)-\(keyPaths)"
    }
}

extension IndexType {
    var indexName: String {
        switch self {
        case .sort:
            return "sort"
        case .unique:
            return "unique"
        }
    }
}
