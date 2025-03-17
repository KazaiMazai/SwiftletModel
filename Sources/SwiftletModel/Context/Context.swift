//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
import Collections

public struct Context {
    private var entitiesRepository = EntitiesRepository()
    private var relationsRepository = RelationsRepository()

    public init() { }
}

public extension Context {
    func ids<T: EntityModelProtocol>(_ entityType: T.Type) -> [T.ID] {
        entitiesRepository.ids(T.self)
    }

    func all<T: EntityModelProtocol>() -> [T] {
        entitiesRepository.all()
    }

    func find<T: EntityModelProtocol>(_ id: T.ID) -> T? {
        entitiesRepository.find(id)
    }

    func findAll<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.findAll(ids)
    }

    func findAllExisting<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T] {
        entitiesRepository.findAllExisting(ids)
    }
}

public extension Context {

    mutating func remove<T: EntityModelProtocol>(_ entityType: T.Type, id: T.ID) {
        entitiesRepository.remove(T.self, id: id)
    }

    mutating func removeAll<T: EntityModelProtocol>(_ entityType: T.Type, ids: [T.ID]) {
        entitiesRepository.removeAll(T.self, ids: ids)
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T,
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entity, options: options)
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T?,
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entity, options: options)
    }

    mutating func insert<T: EntityModelProtocol>(_ entities: [T],
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entities, options: options)
    }
}

extension Context {
    mutating func updateLinks<Parent: EntityModelProtocol, Child: EntityModelProtocol>(_ links: Links<Parent, Child>) {
        relationsRepository.updateLinks(links)
    }
}

extension Context {
    func getChildren<T: EntityModelProtocol>(for type: T.Type, relationName: String, id: T.ID) -> OrderedSet<String> {
        relationsRepository.getChildren(for: type, relationName: relationName, id: id)
    }
}

extension Context {
    func index<Entity, T>(_ indexType: IndexType,
                          _ keyPath: KeyPath<Entity, T>) -> Index.ComparableValue<Entity, T>? {
        entitiesRepository.index(indexType, keyPath)
    }
    
    func index<Entity, T0, T1>(_ indexType: IndexType,
                              _ kp0: KeyPath<Entity, T0>,
                              _ kp1: KeyPath<Entity, T1>) -> Index.ComparableValue<Entity, Pair<T0, T1>>? {
        
        entitiesRepository.index(indexType, kp0, kp1)
    }
    
    func index<Entity, T0, T1, T2>(_ indexType: IndexType,
                                  _ kp0: KeyPath<Entity, T0>,
                                  _ kp1: KeyPath<Entity, T1>,
                                  _ kp2: KeyPath<Entity, T2>) -> Index.ComparableValue<Entity, Triplet<T0, T1, T2>>? {
       
        entitiesRepository.index(indexType, kp0, kp1, kp2)
    }
    
    func index<Entity, T0, T1, T2, T3>(_ indexType: IndexType,
                                      _ kp0: KeyPath<Entity, T0>,
                                      _ kp1: KeyPath<Entity, T1>,
                                      _ kp2: KeyPath<Entity, T2>,
                                      _ kp3: KeyPath<Entity, T3>) -> Index.ComparableValue<Entity, Quadruple<T0, T1, T2, T3>>? {
        
        entitiesRepository.index(indexType, kp0, kp1, kp2, kp3)
    }
}

extension Context {
    func uniqueIndex<Entity, T>(_ indexType: IndexType,
                          _ keyPath: KeyPath<Entity, T>) -> Unique.ComparableValueIndex<Entity, T>? 
                          where T: Comparable {
        entitiesRepository.uniqueIndex(indexType, keyPath)
    }
    
    func uniqueIndex<Entity, T0, T1>(_ indexType: IndexType,
                              _ kp0: KeyPath<Entity, T0>,
                              _ kp1: KeyPath<Entity, T1>) -> Unique.ComparableValueIndex<Entity, Pair<T0, T1>>? 
                              where T0: Comparable, T1: Comparable {
        
        entitiesRepository.uniqueIndex(indexType, kp0, kp1)
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(_ indexType: IndexType,
                                  _ kp0: KeyPath<Entity, T0>,
                                  _ kp1: KeyPath<Entity, T1>,
                                  _ kp2: KeyPath<Entity, T2>) -> Unique.ComparableValueIndex<Entity, Triplet<T0, T1, T2>>? 
                                  where T0: Comparable, T1: Comparable, T2: Comparable {
       
        entitiesRepository.uniqueIndex(indexType, kp0, kp1, kp2)
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(_ indexType: IndexType,
                                      _ kp0: KeyPath<Entity, T0>,
                                      _ kp1: KeyPath<Entity, T1>,
                                      _ kp2: KeyPath<Entity, T2>,
                                      _ kp3: KeyPath<Entity, T3>) -> Unique.ComparableValueIndex<Entity, Quadruple<T0, T1, T2, T3>>? 
                                      where T0: Comparable, T1: Comparable, T2: Comparable, T3: Comparable {
        
        entitiesRepository.uniqueIndex(indexType, kp0, kp1, kp2, kp3)
    }
}

extension Context {
    func uniqueIndex<Entity, T>(_ indexType: IndexType,
                          _ keyPath: KeyPath<Entity, T>) -> Unique.HashableValueIndex<Entity, T>? 
                          where T: Hashable {
        entitiesRepository.uniqueIndex(indexType, keyPath)
    }
    
    func uniqueIndex<Entity, T0, T1>(_ indexType: IndexType,
                              _ kp0: KeyPath<Entity, T0>,
                              _ kp1: KeyPath<Entity, T1>) -> Unique.HashableValueIndex<Entity, Pair<T0, T1>>? 
                              where T0: Hashable, T1: Hashable {
        
        entitiesRepository.uniqueIndex(indexType, kp0, kp1)
    }
    
    func uniqueIndex<Entity, T0, T1, T2>(_ indexType: IndexType,
                                  _ kp0: KeyPath<Entity, T0>,
                                  _ kp1: KeyPath<Entity, T1>,
                                  _ kp2: KeyPath<Entity, T2>) -> Unique.HashableValueIndex<Entity, Triplet<T0, T1, T2>>? 
                                  where T0: Hashable, T1: Hashable, T2: Hashable {
       
        entitiesRepository.uniqueIndex(indexType, kp0, kp1, kp2)
    }
    
    func uniqueIndex<Entity, T0, T1, T2, T3>(_ indexType: IndexType,
                                      _ kp0: KeyPath<Entity, T0>,
                                      _ kp1: KeyPath<Entity, T1>,
                                      _ kp2: KeyPath<Entity, T2>,
                                      _ kp3: KeyPath<Entity, T3>) -> Unique.HashableValueIndex<Entity, Quadruple<T0, T1, T2, T3>>? 
                                      where T0: Hashable, T1: Hashable, T2: Hashable, T3: Hashable {
        
        entitiesRepository.uniqueIndex(indexType, kp0, kp1, kp2, kp3)
    }
}
