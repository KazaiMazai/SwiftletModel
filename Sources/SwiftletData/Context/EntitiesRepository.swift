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
    
    private var storages: [EntityName: [EntityID: any EntityModel]] = [:]
}

extension EntitiesRepository {
    func all<T>() -> [T] {
        let entityName = String(reflecting: T.self)
        return storages[entityName]?.compactMap { $0.value as? T } ?? []
    }
    
    func find<T: EntityModel>(_ id: T.ID) -> T? {
        let entityName = EntityName(reflecting: T.self)
        let storage = storages[entityName] ?? [:]
        return storage[id.description] as? T
    }
    
    func findAll<T: EntityModel>(_ ids: [T.ID]) -> [T?] {
        ids.map { find($0) }
    }
    
    func findAllExisting<T: EntityModel>(_ ids: [T.ID]) -> [T] {
        findAll(ids).compactMap { $0 }
    }
}

extension EntitiesRepository {
    mutating func remove<T: EntityModel>(_ entityType: T.Type, id: T.ID) {
        let key = EntityName(reflecting: T.self)
        var storage = storages[key] ?? [:]
        storage.removeValue(forKey: id.description)
        storages[key] = storage
    }
    
    mutating func removeAll<T: EntityModel>(_ entityType: T.Type, ids: [T.ID]) {
        ids.forEach { remove(T.self, id: $0) }
    }
    
    mutating func insert<T: EntityModel>(_ entity: T, options: MergeStrategy<T>) {
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
    
    mutating func insert<T: EntityModel>(_ entity: T?,
                                       options: MergeStrategy<T>) {
        guard let entity else {
            return
        }
        
        insert(entity, options: options)
    }
    
    mutating func insert<T: EntityModel>(_ entities: [T],
                                       options: MergeStrategy<T>) {
        
        entities.forEach { insert($0, options: options) }
    }
}
