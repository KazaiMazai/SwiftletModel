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
        let key = String(reflecting: T.self)
        return storages[key]?.compactMap { $0.value as? T } ?? []
    }
    
    func find<T: EntityModel>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        let storage = storages[key] ?? [:]
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
    
    @discardableResult
    mutating func remove<T: EntityModel>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        var storage = storages[key] ?? [:]
        let value = storage[id.description] as? T
        storage.removeValue(forKey: id.description)
        storages[key] = storage
        return value
    }
    
    @discardableResult
    mutating func removeAll<T: EntityModel>(_ ids: [T.ID]) -> [T?] {
        ids.map { remove($0) }
    }
    
    mutating func save<T: EntityModel>(_ entity: T, options: MergeStrategy<T>) {
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
    
    mutating func save<T: EntityModel>(_ entity: T?,
                                       options: MergeStrategy<T>) {
        guard let entity else {
            return
        }
        
        save(entity, options: options)
    }
    
    mutating func save<T: EntityModel>(_ entities: [T],
                                       options: MergeStrategy<T>) {
        
        entities.forEach { save($0, options: options) }
    }
}
