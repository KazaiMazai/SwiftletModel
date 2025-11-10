//
//  Unique.ComparableValueIndex 2.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/03/2025.
//

import Foundation

extension Unique {
    @EntityModel
    struct HashableValue<Value: Hashable & Sendable> {
        var id: String { name }

        let name: String

        private var index: [Value: Entity.ID] = [:]
        private var indexedValues: [Entity.ID: Value] = [:]

        init(name: String) {
            self.name = name
        }

        func asDeleted(in context: Context) -> Deleted<Self>? { nil }

        func saveMetadata(to context: inout Context) throws { }

        func deleteMetadata(from context: inout Context) throws { }
    }
}

extension Unique.HashableValue {
    enum Errors: Error {
        case uniqueValueViolation(Entity.ID, Value)
    }
}

extension Unique.HashableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            in context: inout Context,
                            resolveCollisions resolver: CollisionResolver<Entity>) throws {

        var index = Query(id: indexName).resolve(in: context) ?? Self(name: indexName)
        try index.checkForCollisions(entity, value: value, in: &context, resolveCollisions: resolver)
        index = index.query().resolve(in: context) ?? index
        index.update(entity, value: value)
        try index.save(to: &context)
    }

    static func removeFromIndex(indexName: String,
                                _ entity: Entity,
                                in context: inout Context) throws {

        guard var index = Query<Self>(id: indexName).resolve(in: context) else {
            return
        }

        index.remove(entity)
        try index.save(to: &context)
    }
}

private extension Unique.HashableValue {
    func checkForCollisions(_ entity: Entity,
                            value: Value,
                            in context: inout Context,
                            resolveCollisions resolver: CollisionResolver<Entity>) throws {
        guard let existingId = index[value], existingId != entity.id else {
            return
        }

        try resolver.resolveCollision(existing: existingId, new: entity.id, indexName: name, in: &context)
    }

    mutating func update(_ entity: Entity,
                         value: Value) {
        let existingValue = indexedValues[entity.id]

        guard existingValue != value else {
            return
        }

        if let existingValue, index[existingValue] != nil {
            index[existingValue] = nil
        }

        index[value] = entity.id
        indexedValues[entity.id] = value
    }

    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              index[value] != nil
        else {
            return
        }

        indexedValues[entity.id] = nil
        index[value] = nil
    }
}
