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
     
    private var storages: [EntityName: [EntityID: any IdentifiableEntity]] = [:]
    
}

extension EntitiesRepository {
    func all<T>() -> [T] {
        let key = String(reflecting: T.self)
        return storages[key]?.compactMap { $0.value as? T } ?? []
    }
    
    func find<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        let storage = storages[key] ?? [:]
        return storage[id.description] as? T
    }
    
    func findAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        ids.map { find($0) }
    }
    
    func findAllExisting<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T] {
        findAll(ids).compactMap { $0 }
    }
}

extension EntitiesRepository {
    
    @discardableResult
    mutating func remove<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        var storage = storages[key] ?? [:]
        let value = storage[id.description] as? T
        storage.removeValue(forKey: id.description)
        storages[key] = storage
        return value
    }
    
    @discardableResult
    mutating func removeAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        ids.map { remove($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T) {
        let key = String(reflecting: T.self)
        var storage = storages[key] ?? [:]
        var normalizedCopy = entity
        normalizedCopy.normalize()
        storage[entity.id.description] = normalizedCopy
        storages[key] = storage
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T?) {
        guard let entity else {
            return
        }
        
        save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entities: [T]) {
        entities.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: Relation<T>) {
        save(relation.entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<Relation<T>>) {
        relations.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<Relation<T>>)?) {
        guard let relations else {
            return
        }
        
        save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: BiRelation<T>) {
        save(relation.entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<BiRelation<T>>) {
        relations.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<BiRelation<T>>)?) {
        guard let relations else {
            return
        }
        
        save(relations)
    }
}
