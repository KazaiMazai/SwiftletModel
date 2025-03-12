//
//  EntityModel+UniqueIndex.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

extension EntitiesRepository {
    func uniqueIndex<Entity, T>(
        _ indexType: IndexType<Entity>,
        _ keyPath: KeyPath<Entity, T>) -> UniqueComparableValueIndex<Entity, T>? {
        
            find(.indexName(indexType, keyPath))
    }
    
    func uniqueIndex<Entity, T0, T1>(
        _ indexType: IndexType<Entity>,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>) -> UniqueComparableValueIndex<Entity, Pair<T0, T1>>? {
        
            find(.indexName(indexType, kp0, kp1))
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(
        _ indexType: IndexType<Entity>  ,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>) -> UniqueComparableValueIndex<Entity, Triplet<T0, T1, T2>>? {
        
            find(.indexName(indexType, kp0, kp1, kp2))
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(
        _ indexType: IndexType<Entity>,
        _ kp0: KeyPath<Entity, T0>,
        _ kp1: KeyPath<Entity, T1>,
        _ kp2: KeyPath<Entity, T2>,
        _ kp3: KeyPath<Entity, T3>) -> UniqueComparableValueIndex<Entity, Quadruple<T0, T1, T2, T3>>? {
        
        find(.indexName(indexType, kp0, kp1, kp2, kp3))
    }
}
 
