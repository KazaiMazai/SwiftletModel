//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 10/03/2025.
//

import Foundation
import BTree

enum UniqueIndex<Entity: EntityModelProtocol> {
    
}

extension UniqueIndex {
    @EntityModel
    struct ComparableValueIndex<Value: Comparable> {
        var id: String { name }
        
        let name: String
        
        private var index: Map<Value, Entity.ID> = [:]
        private var indexedValues: [Entity.ID: Value] = [:]
        
        init(name: String, indexType: IndexType) {
            self.name = name
        }
    }
}

extension UniqueIndex.ComparableValueIndex {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension UniqueIndex.ComparableValueIndex {
     
    mutating func add(_ entity: Entity,
                                   value: Value,
                                   in context: inout Context,
                                   resolveCollisions resolver: CollisionResolver<Entity>) throws {
        let existingValue = indexedValues[entity.id]
        
        guard existingValue != value else {
            return
        }
        
        if let existingValue, let _ = index[existingValue] {
            index[existingValue] = nil
        }
        
        guard let existingId = index[value] else {
            index[value] = entity.id
            indexedValues[entity.id] = value
            return
        }
        
        if existingId != entity.id {
            try resolver.resolveCollision(id: existingId, in: &context)
        }
        
        indexedValues[existingId] = nil
        index[value] = entity.id
        indexedValues[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              let id = index[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        index[value] = nil
    }
}
 
