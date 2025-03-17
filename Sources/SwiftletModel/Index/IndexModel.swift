//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 15/08/2024.
//

import Foundation
import BTree
import Collections
 
//@EntityModel
//enum Index.ComparableValue<Entity: EntityModelProtocol, Value: Comparable>  {
//    case sort(Index.ComparableValue<Entity, Value>)
//    case unique(Unique.ComparableValueIndex<Entity, Value>)
//    
//    var id: String {
//        switch self {
//        case .sort(let index):
//            return index.id
//        case .unique(let index):
//            return index.id
//        }
//    }
//    
//    init(name: String, indexType: IndexType) where Value: Hashable {
//        switch indexType {
//        case .sort:
//            self = .sort(Index.ComparableValue<Entity, Value>(name: name))
//        case .unique:
//            self = .unique(Unique.ComparableValueIndex<Entity, Value>(name: name))
//        }
//    }
//}

/*
@EntityModel
struct Index.ComparableValue<Entity: EntityModelProtocol, Value: Comparable> {
    var id: String { name }
    
    let name: String
    let indexType: IndexType
    
    private var sortIndex: Map<Value, OrderedSet<Entity.ID>> = [:]
    private var uniqueIndex: any DictionaryProtocol<Value, Entity.ID>
    private var indexedValues: [Entity.ID: Value] = [:]
    
    init(name: String, indexType: IndexType) where Value: Hashable {
        self.name = name
        self.indexType = indexType
        self.uniqueIndex = Dictionary()
    }
    
    init(name: String, indexType: IndexType) where Value: Comparable {
        self.name = name
        self.indexType = indexType
        self.uniqueIndex = Map()
    }
    
    var sorted: [Entity.ID] { sortIndex.flatMap { $0.1.elements } }
}

extension Index.ComparableValue {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension Index.ComparableValue {
    mutating func add(_ entity: Entity, value: Value, in context: inout Context) throws {
        switch indexType {
        case .sort:
            addToIndex.ComparableValue(entity, value: value)
        case .unique(let resolveDuplicates):
            try addToUniqueIndex(entity, value: value, in: &context, resolveDuplicates: resolveDuplicates)
        }
    }
    
    mutating func remove(_ entity: Entity) {
        switch indexType {
        case .sort:
            removeFromIndex.ComparableValue(entity)
        case .unique:
            removeFromUnique(entity)
        }
    }
}

private extension Index.ComparableValue {
    mutating func addToIndex.ComparableValue(_ entity: Entity, value: Value) {
        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, var ids = sortIndex[existingValue] {
            ids.remove(entity.id)
            sortIndex[existingValue] = ids.isEmpty ? nil : ids
        }
        
        guard var ids = sortIndex[value] else {
            sortIndex[value] = OrderedSet(arrayLiteral: entity.id)
            indexedValues[entity.id] = value
            return
        }
        
        ids.append(entity.id)
        sortIndex[value] = ids
        indexedValues[entity.id] = value
    }
    
    mutating func addToUniqueIndex(_ entity: Entity,
                                   value: Value,
                                   in context: inout Context,
                                   resolveDuplicates: CollisionResolver<Entity>) throws {
        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, let _ = uniqueIndex[existingValue] {
            uniqueIndex[existingValue] = nil
        }
        
        guard let existingId = uniqueIndex[value] else {
            uniqueIndex[value] = entity.id
            indexedValues[entity.id] = value
            return
        }
        
        if existingId != entity.id {
            try resolveDuplicates.resolveCollision(id: existingId, in: &context)
        }
        
        indexedValues[existingId] = nil
        uniqueIndex[value] = entity.id
        indexedValues[entity.id] = value
    }
    
    mutating func removeFromUnique(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              let id = uniqueIndex[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        uniqueIndex[value] = nil
    }
    
    
    mutating func removeFromIndex.ComparableValue(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
            var ids = sortIndex[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        ids.remove(entity.id)
        sortIndex[value] = ids
    }
}

extension Index.ComparableValue {
    func filter(_ value: Value) -> [Entity.ID] {
        sortIndex[value]?.elements ?? []
    }
    
    func filter(range: Range<Value>) -> [Entity.ID] {
        sortIndex
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }
    
    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(sortIndex.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
            
    }
}
 
*/
