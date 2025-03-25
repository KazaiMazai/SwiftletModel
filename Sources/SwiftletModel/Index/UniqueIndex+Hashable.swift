//
//  Unique.ComparableValueIndex 2.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//

extension UniqueIndex {
    @EntityModel
    struct HashableValue<Value: Hashable> {
        var id: String { name }
        
        let name: String
        
        private var index: [Value: Entity.ID] = [:]
        private var indexedValues: [Entity.ID: Value] = [:]
        
        init(name: String) {
            self.name = name
        }
    }
}

extension UniqueIndex.HashableValue {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension UniqueIndex.HashableValue {
    
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

