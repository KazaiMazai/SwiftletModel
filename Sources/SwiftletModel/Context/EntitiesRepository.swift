//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct EntitiesRepository {
    typealias EntityID = String
    typealias EntityName = String
    typealias RelationName = String

    private var storages: [EntityName: [EntityID: any EntityModelProtocol]] = [:]
}

extension EntitiesRepository {
    func ids<T: EntityModelProtocol>(_ entityType: T.Type) -> [T.ID] {
        let entityName = String(reflecting: T.self)
        return storages[entityName]?.keys.compactMap { T.ID($0) } ?? []
    }

    func all<T: EntityModelProtocol>() -> [T] {
        let entityName = String(reflecting: T.self)
        return storages[entityName]?.compactMap { $0.value as? T } ?? []
    }

    func find<T: EntityModelProtocol>(_ id: T.ID) -> T? {
        let entityName = EntityName(reflecting: T.self)
        let storage = storages[entityName] ?? [:]
        return storage[id.description] as? T
    }

    func findAll<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T?] {
        ids.map { find($0) }
    }

    func findAllExisting<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T] {
        findAll(ids).compactMap { $0 }
    }
}

extension EntitiesRepository {
    mutating func remove<T: EntityModelProtocol>(_ entityType: T.Type, id: T.ID) {
        let key = EntityName(reflecting: T.self)
        var storage = storages[key] ?? [:]
        storage.removeValue(forKey: id.description)
        storages[key] = storage
    }

    mutating func removeAll<T: EntityModelProtocol>(_ entityType: T.Type, ids: [T.ID]) {
        ids.forEach { remove(T.self, id: $0) }
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T, options: MergeStrategy<T>) {
        let key = String(reflecting: T.self)
        var storage = storages[key] ?? [:]

        guard let existing: T = find(entity.id) else {
            storage[entity.id.description] = entity.normalized()
            storages[key] = storage
            return
        }

        let new = entity.normalized()
        let merged = options.merge(existing, new)

        storage[entity.id.description] = merged
        storages[key] = storage
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T?, options: MergeStrategy<T>) {
        guard let entity else {
            return
        }

        insert(entity, options: options)
    }

    mutating func insert<T: EntityModelProtocol>(_ entities: [T], options: MergeStrategy<T>) {
        entities.forEach { insert($0, options: options) }
    }
}

extension EntitiesRepository {
    func index<Entity, T>(_ keyPath: KeyPath<Entity, T>) -> IndexModel<Entity, T>? {
        find(.indexName(keyPath))
    }
    
    func index<Entity, T0, T1>(_ kp0: KeyPath<Entity, T0>,
                               _ kp1: KeyPath<Entity, T1>) -> IndexModel<Entity, Pair<T0, T1>>? {
        
        find(.indexName(kp0, kp1))
    }
    
    func index<Entity, T0, T1, T2>(_ kp0: KeyPath<Entity, T0>,
                                   _ kp1: KeyPath<Entity, T1>,
                                   _ kp2: KeyPath<Entity, T2>) -> IndexModel<Entity, Triplet<T0, T1, T2>>? {
        
        find(.indexName(kp0, kp1, kp2))
    }
    
    func index<Entity, T0, T1, T2, T3>(_ kp0: KeyPath<Entity, T0>,
                                       _ kp1: KeyPath<Entity, T1>,
                                       _ kp2: KeyPath<Entity, T2>,
                                       _ kp3: KeyPath<Entity, T3>) -> IndexModel<Entity, Quadruple<T0, T1, T2, T3>>? {
        
        find(.indexName(kp0, kp1, kp2, kp3))
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
