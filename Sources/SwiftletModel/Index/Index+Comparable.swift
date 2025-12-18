//
//  Index.ComparableValue.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/03/2025.
//

import Foundation
import BTree
import Collections
import os
/**
 Map is backed with CoW BTree storage.
 Should not blow up since index entities live inside Context and not accessible elsewhere.
*/
//extension Map: @unchecked @retroactive Sendable { }

extension Index {
    @EntityRefModel
    final class ComparableValue<Value: Comparable & Sendable>: @unchecked Sendable {
        typealias `Self` = Index.ComparableValue<Value>
        var id: String { name }

        let name: String
        private let lock = OSAllocatedUnfairLock()
        private var index: Map<Value, OrderedSet<Entity.ID>> = [:]
        private var indexedValues: [Entity.ID: Value] = [:]

        init(name: String) {
            self.name = name
        }

        var sorted: [Entity.ID] {
            index.flatMap { $0.1.elements }
        }

        func asDeleted(in context: Context) -> Deleted<Self>? { nil }

        func saveMetadata(to context: inout Context) throws { }

        func deleteMetadata(from context: inout Context) throws { }
    }
}

extension Index.ComparableValue {
    static func updateIndex(indexName: String,
                            _ entity: Entity,
                            value: Value,
                            in context: inout Context) throws {

        let index = Query(id: indexName).resolve(in: context) ?? Self(name: indexName)
        index.update(entity, value: value)
        try index.save(to: &context)
    }

    static func removeFromIndex(indexName: String,
                                _ entity: Entity,
                                in context: inout Context) throws {

        let index = Query<Self>(id: indexName).resolve(in: context)
        index?.remove(entity)
        try index?.save(to: &context)
    }
}

extension Index.ComparableValue {
    func filter(_ predicate: Predicate<Entity, Value>) -> [Entity.ID] {
        lock.withLock {
            _filter(predicate)
        }
    }

    func filter(range: Range<Value>) -> [Entity.ID] {
        lock.withLock {
            _filter(range: range)
        }
    }

    func filter(range: ClosedRange<Value>) -> [Entity.ID] {
        lock.withLock {
            _filter(range: range)
        }
    }

    func contains(id: Entity.ID?, in range: ClosedRange<Value>) -> Bool {
        lock.withLock {
            _contains(id: id, in: range)
        }
    }

    func grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        lock.withLock {
            _grouped()
        }
    }
}

private extension Index.ComparableValue {
    func _filter(_ predicate: Predicate<Entity, Value>) -> [Entity.ID] {
        switch predicate.method {
        case .equal:
            return index[predicate.value]?.elements ?? []
        case .lessThan:
            guard let first = index.keys.first else {
                return []
            }

            return index
                .submap(from: first, to: predicate.value)
                .flatMap { $1.elements }
        case .lessThanOrEqual:
            guard let first = index.keys.first else {
                return []
            }

            return index
                .submap(from: first, through: predicate.value)
                .flatMap { $1.elements }
        case .greaterThan:
            guard let last = index.keys.last else {
                return []
            }

            return index
                .submap(from: predicate.value, through: last)
                .excluding(SortedSet(arrayLiteral: predicate.value))
                .flatMap { $1.elements }
        case .greaterThanOrEqual:
            guard let last = index.keys.last else {
                return []
            }

            return index
                .submap(from: predicate.value, through: last)
                .flatMap { $1.elements }
        case .notEqual:
            return index
                .excluding(SortedSet(arrayLiteral: predicate.value))
                .flatMap { $1.elements }
        }
    }

    func _filter(range: Range<Value>) -> [Entity.ID] {
        index
            .submap(from: range.lowerBound, to: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }

    func _filter(range: ClosedRange<Value>) -> [Entity.ID] {
        index
            .submap(from: range.lowerBound, through: range.upperBound)
            .map { $1.elements }
            .flatMap { $0 }
    }

    func _contains(id: Entity.ID?, in range: ClosedRange<Value>) -> Bool {
        guard let id, let value = indexedValues[id] else {
            return false
        }

        return range.contains(value)
    }

    func _grouped() -> [Value: [Entity.ID]] where Value: Hashable {
        Dictionary(index.map { ($0, $1.elements) },
                   uniquingKeysWith: { $1 })
    }
}

private extension Index.ComparableValue {
    func update(_ entity: Entity, value: Value) {
        lock.withLock {
            _update(entity, value: value)
        }
    }
    
    func remove(_ entity: Entity) {
        lock.withLock {
            _remove(entity)
        }
    }
}

private extension Index.ComparableValue {
    func _update(_ entity: Entity, value: Value) {
        let existingValue = indexedValues[entity.id]

        guard existingValue != value else {
            return
        }

        if let existingValue, var ids = index[existingValue] {
            ids.remove(entity.id)
            index[existingValue] = ids.isEmpty ? nil : ids
        }

        guard var ids = index[value] else {
            index[value] = OrderedSet(arrayLiteral: entity.id)
            indexedValues[entity.id] = value
            return
        }

        ids.append(entity.id)
        index[value] = ids
        indexedValues[entity.id] = value
    }

    func _remove(_ entity: Entity) {
        guard let value = indexedValues[entity.id],
              var ids = index[value]
        else {
            return
        }

        indexedValues[entity.id] = nil
        ids.remove(entity.id)
        index[value] = ids
    }
}
