//
//  File.swift
//
//
//  Created by Serge Kazakov on 16/08/2024.
//

import Foundation

public extension EntityModelProtocol {
    func updateIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    where
    T: Hashable & Sendable {

        try Index.HashableValue.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context
        )
    }

    func updateIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable {
        try Index.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context
        )
    }

    func updateIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable,
    T2: Hashable & Sendable {
        try Index.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context
        )
    }

    func updateIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable,
    T2: Hashable & Sendable,
    T3: Hashable & Sendable {
        try Index.HashableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context
        )
    }
}

public extension EntityModelProtocol {
    func removeFromIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws
    where
    T: Hashable & Sendable {
        try Index.HashableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }

    func removeFromIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable {
        try Index.HashableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }

    func removeFromIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable,
    T2: Hashable & Sendable {
        try Index.HashableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }

    func removeFromIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        in context: inout Context) throws
    where
    T0: Hashable & Sendable,
    T1: Hashable & Sendable,
    T2: Hashable & Sendable,
    T3: Hashable & Sendable {
        try Index.HashableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}
