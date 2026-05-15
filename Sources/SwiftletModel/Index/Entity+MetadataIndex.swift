//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 21/04/2025.
//

import Foundation

public extension EntityModelProtocol {
    private static func updatedAtIndex(in context: Context) -> SortIndex<Self>.ComparableValue<Date>? {
        SortIndex<Self>.ComparableValue<Date>
            .query(Metadata.updatedAt.indexName)
            .resolve(in: context)
    }

    static func lastUpdatedAt(in context: Context) -> Date? {
        updatedAtIndex(in: context)?.lastValue
    }

    func updatedAt(in context: Context) -> Date? {
        Self.updatedAtIndex(in: context)?.valueFor(id)
    }
    
    func lastUpdatedAt<E: EntityModelProtocol>(_ keypath: KeyPath<Self, E?>, in context: Context) -> Date? {
        self[keyPath: keypath]?.lastUpdatedAt(in: context)
    }
    
    func lastUpdatedAt<E: EntityModelProtocol>(_ keypath: KeyPath<Self, [E]?>, in context: Context) -> Date? {
        self[keyPath: keypath]?.map { $0.lastUpdatedAt(in: context) }.compactMap { $0 }.max()
    }
}

public extension EntityModelProtocol {
    func updateMetadata<Value>(
        _ metadata: Metadata,
        value: Value,
        in context: inout Context) throws
    where
    Value: Comparable & Sendable {

        try Index.ComparableValue.updateIndex(
            indexName: metadata.indexName,
            self,
            value: value,
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromMetadata<Value>(
        _ metadata: Metadata,
        valueType: Value.Type,
        in context: inout Context) throws
    where
    Value: Comparable & Sendable {

        try Index.ComparableValue<Value>.removeFromIndex(
            indexName: metadata.indexName,
            self, in: &context)
    }
}

public extension EntityModelProtocol {
    func updateMetadata<Value>(
        _ metadata: Metadata,
        value: Value,
        in context: inout Context) throws
    where
    Value: Hashable & Sendable {

        try Index.HashableValue.updateIndex(
            indexName: metadata.indexName,
            self,
            value: value,
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromMetadata<Value>(
        _ metadata: Metadata,
        valueType: Value.Type,
        in context: inout Context) throws
    where
    Value: Hashable & Sendable {

        try Index.HashableValue<Value>.removeFromIndex(
            indexName: metadata.indexName,
            self, in: &context)
    }
}

public extension EntityModelProtocol {
    func updateMetadata<Value>(
        _ metadata: Metadata,
        value: Value,
        in context: inout Context) throws
    where
    Value: Hashable & Comparable & Sendable {

        try Index.HashableValue.updateIndex(
            indexName: metadata.indexName,
            self,
            value: value,
            in: &context
        )

        try Index.ComparableValue.updateIndex(
            indexName: metadata.indexName,
            self,
            value: value,
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromMetadata<Value>(
        _ metadata: Metadata,
        valueType: Value.Type,
        in context: inout Context) throws
    where
    Value: Hashable & Comparable & Sendable {

        try Index.HashableValue<Value>.removeFromIndex(
            indexName: metadata.indexName,
            self, in: &context)

        try Index.ComparableValue<Value>.removeFromIndex(
            indexName: metadata.indexName,
            self, in: &context)
    }
}
