//
//  Unique.ComparableValueIndex 2.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/03/2025.
//
import Foundation

extension Index {
    @EntityModel
    struct HashableValue<Value: Hashable & Sendable> {
        var id: String { name }

        let name: String

        private var index: [Value: Set<Entity.ID>] = [:]
        private var indexedValues: [Entity.ID: Value] = [:]

        init(name: String) {
            self.name = name
        }

        func asDeleted(in context: Context) -> Deleted<Self>? { nil }

        func saveMetadata(to context: inout Context) throws { }

        func deleteMetadata(from context: inout Context) throws { }
    }
}

extension Index.HashableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            in context: inout Context) throws {

        var index = Query(id: indexName).resolve(in: context) ?? Self(name: indexName)
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

    func find(_ value: Value) -> Set<Entity.ID> {
        index[value] ?? []
    }
}

private extension Index.HashableValue {

    mutating func update(_ entity: Entity,
                         value: Value) {
        let existingValue = indexedValues[entity.id]

        guard existingValue != value else {
            return
        }

        if let existingValue, index[existingValue] != nil {
            remove(entity)
        }

        var entities = index[value] ?? []
        entities.insert(entity.id)
        index[value] = entities
        indexedValues[entity.id] = value
    }

    
    mutating func remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              var ids = index[value]
        else {
            return
        }

        indexedValues[entity.id] = nil
        ids.remove(entity.id)
        index[value] = ids.isEmpty ? nil : ids
    }
}
