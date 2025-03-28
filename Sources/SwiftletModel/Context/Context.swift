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
//
//extension Context {
//    func index<Entity, T, Index>(
//        _ keyPath: KeyPath<Entity, T>) -> Index?
//    where
//    Index: EntityModelProtocol,
//    Index.ID == String {
//        entitiesRepository.find(.indexName(keyPath))
//    }
//    
//    func index<Entity, T0, T1, Index>(
//        _ kp0: KeyPath<Entity, T0>,
//        _ kp1: KeyPath<Entity, T1>) -> Index?
//    where
//    Index: EntityModelProtocol,
//    Index.ID == String {
//        entitiesRepository.find(.indexName(kp0, kp1))
//    }
//    
//    func index<Entity, T0, T1, T2, Index>(
//        _ kp0: KeyPath<Entity, T0>,
//        _ kp1: KeyPath<Entity, T1>,
//        _ kp2: KeyPath<Entity, T2>) -> Index?
//    where
//     Index: EntityModelProtocol,
//    Index.ID == String {
//        entitiesRepository.find(.indexName(kp0, kp1, kp2))
//    }
//    
//    func index<Entity, T0, T1, T2, T3, Index>(
//        _ kp0: KeyPath<Entity, T0>,
//        _ kp1: KeyPath<Entity, T1>,
//        _ kp2: KeyPath<Entity, T2>,
//        _ kp3: KeyPath<Entity, T3>) -> Index?
//    where
//     Index: EntityModelProtocol,
//    Index.ID == String {
//        entitiesRepository.find(.indexName(kp0, kp1, kp2, kp3))
//    }
//}
