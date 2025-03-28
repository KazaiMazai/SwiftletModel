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
    struct ComparableValue<Value: Comparable> {
        var id: String { name }
        
        let name: String
        
        private var index: Map<Value, Entity.ID> = [:]
        private var indexedValues: [Entity.ID: Value] = [:]
        
        init(name: String) {
            self.name = name
        }
    }
}

extension UniqueIndex.ComparableValue {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

private extension UniqueIndex.ComparableValue {
    mutating func resolveCollisions(_ entity: Entity,
                                    value: Value,
                                    in context: inout Context,
                                    resolveCollisions resolver: CollisionResolver<Entity>) throws {
        guard let existingId = index[value], existingId != entity.id else {
            return
        }
        
        try resolver.resolveCollision(id: existingId, in: &context)
    }
    
    mutating func update(_ entity: Entity,
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
        
        index[value] = entity.id
        indexedValues[entity.id] = value
    }
    
    mutating func add(_ entity: Entity,
                      value: Value,
                      in context: inout Context,
                      resolveCollisions resolver: CollisionResolver<Entity>) throws {
        
        try resolveCollisions(entity, value: value, in: &context, resolveCollisions: resolver)
        self = query(in: context).resolve() ?? self
        try update(entity, value: value, in: &context, resolveCollisions: resolver)
        try save(to: &context)
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

extension UniqueIndex.ComparableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            in context: inout Context,
                            resolveCollisions resolver: CollisionResolver<Entity>) throws {
        
        var index = Query(context: context, id: indexName).resolve() ?? Self(name: indexName)
        try index.resolveCollisions(entity, value: value, in: &context, resolveCollisions: resolver)
        index = index.query(in: context).resolve() ?? index
        try index.update(entity, value: value, in: &context, resolveCollisions: resolver)
        try index.save(to: &context)
    }
    
    static func removeFromIndex(indexName: String,
                                _ entity: Entity,
                                in context: inout Context) throws {
        
        guard var index = Query<Self>(context: context, id: indexName).resolve() else {
            return
        }
         
        index.remove(entity)
        try index.save(to: &context)
    }
}

