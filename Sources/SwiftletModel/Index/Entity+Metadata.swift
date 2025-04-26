//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 21/04/2025.
//

import Foundation

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
