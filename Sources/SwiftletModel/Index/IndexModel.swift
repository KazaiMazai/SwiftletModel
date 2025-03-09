//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 15/08/2024.
//

import Foundation
import BTree
import Collections

@EntityModel
struct IndexModel<Entity: EntityModelProtocol, Value: Comparable> {
    typealias IndexMap = Map<Value, OrderedSet<Entity.ID>>
    typealias UniqueIndexMap = Map<Value, Entity.ID>
    var id: String { name }
    
    let name: String
    let indexType: IndexType
    
    private var indexMap: IndexMap = [:]
    private var uniqueIndexMap: UniqueIndexMap = [:]
    private var indexValues: [Entity.ID: Value] = [:]
    
    init(name: String, indexType: IndexType) {
        self.name = name
        self.indexType = indexType
    }
    
    var sorted: [Entity.ID] { indexMap.flatMap { $0.1.elements } }
}

extension IndexModel {
    enum Errors: Error {
        case uniqueValueViolation(Value)
    }
}

extension IndexModel {
    mutating func add(_ entity: Entity, value: Value) throws {
        switch indexType {
        case .sort:
            addToSortIndex(entity, value: value)
        case .unique(let resolveDuplicates):
            try addToUniqueIndex(entity, value: value, resolveDuplicates: resolveDuplicates)
        }
    }
    
    mutating func remove(_ entity: Entity) {
        switch indexType {
        case .sort:
            removeFromSortIndex(entity)
        case .unique(let resolveDuplicates):
            removeFromUnique(entity)
        }
    }
}

private extension IndexModel {
    
    
    mutating func addToSortIndex(_ entity: Entity, value: Value) {
        let existingValue = indexValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = indexMap[existingValue] {
            ids.remove(entity.id)
            indexMap[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = indexMap[value] else {
            indexMap[value] = OrderedSet(arrayLiteral: entity.id)
            indexValues[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        indexMap[value] = ids
        indexValues[entity.id] = value
    }
    
    mutating func addToUniqueIndex(_ entity: Entity, value: Value, resolveDuplicates: ResolveDuplicates) throws {
        let existingValue = indexValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, let _ = uniqueIndexMap[existingValue] {
            uniqueIndexMap[existingValue] = nil
        }
        
        guard var existingId = uniqueIndexMap[value] else {
            uniqueIndexMap[value] = entity.id
            indexValues[entity.id] = value
            return
        }
        
        guard existingId == entity.id  || resolveDuplicates == .upsert else {
            throw Errors.uniqueValueViolation(value)
        }
        
        indexValues[existingId] = nil
        uniqueIndexMap[value] = entity.id
        indexValues[entity.id] = value
    }
    
    mutating func removeFromUnique(_ entity: Entity) {
        guard let value = indexValues[entity.id] else {
            return
        }
        
        guard var id = uniqueIndexMap[value] else {
            return
        }
        
        indexValues[entity.id] = nil
        uniqueIndexMap[value] = nil
    }
    
    
    mutating func removeFromSortIndex(_ entity: Entity) {
        guard let value = indexValues[entity.id],
            var ids = indexMap[value]
        else {
            return
        }
        
        indexValues[entity.id] = nil
        ids.remove(entity.id)
        indexMap[value] = ids
    }
}

extension IndexModel {
    func filter(_ value: Value) -> [Entity.ID] {
        indexMap[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        indexMap
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(indexMap.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
            
    }
}
