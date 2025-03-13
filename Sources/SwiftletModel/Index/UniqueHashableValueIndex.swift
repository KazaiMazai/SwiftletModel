//
//  UniqueComparableValueIndex 2.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/03/2025.
//


@EntityModel
struct UniqueHashableValueIndex<Entity: EntityModelProtocol, Value: Hashable> {
    var id: String { name }
    
    let name: String
    
     
    private var uniqueIndex: [Value: Entity.ID] = [:]
    private var indexedValues: [Entity.ID: Value] = [:]
    
    init(name: String, indexType: IndexType) {
        self.name = name
    }
     
}

extension UniqueHashableValueIndex {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension UniqueHashableValueIndex {
     
    mutating func add(_ entity: Entity,
                                   value: Value,
                                   in context: inout Context,
                                   resolveCollisions resolver: CollisionResolver<Entity>) throws {
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
            try resolver.resolveCollision(id: existingId, in: &context)
        }
        
        indexedValues[existingId] = nil
        uniqueIndex[value] = entity.id
        indexedValues[entity.id] = value
    }
    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              let id = uniqueIndex[value]
        else {
            return
        }
        
        indexedValues[entity.id] = nil
        uniqueIndex[value] = nil
    }
}
 
