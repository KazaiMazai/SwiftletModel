//
//  EntityModel+UniqueIndex.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 12/03/2025.
//

public extension EntityModelProtocol {
    func updateUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws

    where
    T: Comparable & Sendable {

        try Unique.ComparableValue.updateIndex(
            indexName: .indexName(keyPath),
            self,
            value: self[keyPath: keyPath],
            in: &context,
            resolveCollisions: resolver
        )
    }

    func updateUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable {

        try Unique.ComparableValue.updateIndex(
            indexName: .indexName(kp0, kp1),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1])),
            in: &context,
            resolveCollisions: resolver
        )
    }

    func updateUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable,
    T2: Comparable & Sendable {

        try Unique.ComparableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2])),
            in: &context,
            resolveCollisions: resolver
        )
    }

    func updateUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        collisions resolver: CollisionResolver<Self>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable,
    T2: Comparable & Sendable,
    T3: Comparable & Sendable {

        try Unique.ComparableValue.updateIndex(
            indexName: .indexName(kp0, kp1, kp2, kp3),
            self,
            value: indexValue((self[keyPath: kp0], self[keyPath: kp1], self[keyPath: kp2], self[keyPath: kp3])),
            in: &context,
            resolveCollisions: resolver
        )
    }
}

public extension EntityModelProtocol {
    func removeFromUniqueIndex<T>(
        _ keyPath: KeyPath<Self, T>,
        in context: inout Context) throws

    where
    T: Comparable & Sendable {

        try Unique.ComparableValue<T>.removeFromIndex(indexName: .indexName(keyPath), self, in: &context)
    }

    func removeFromUniqueIndex<T0, T1>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable {

        try Unique.ComparableValue<Pair<T0, T1>>.removeFromIndex(indexName: .indexName(kp0, kp1), self, in: &context)
    }

    func removeFromUniqueIndex<T0, T1, T2>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable,
    T2: Comparable & Sendable {

        try Unique.ComparableValue<Triplet<T0, T1, T2>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2), self, in: &context)
    }

    func removeFromUniqueIndex<T0, T1, T2, T3>(
        _ kp0: KeyPath<Self, T0>,
        _ kp1: KeyPath<Self, T1>,
        _ kp2: KeyPath<Self, T2>,
        _ kp3: KeyPath<Self, T3>,
        in context: inout Context) throws

    where
    T0: Comparable & Sendable,
    T1: Comparable & Sendable,
    T2: Comparable & Sendable,
    T3: Comparable & Sendable {

        try Unique.ComparableValue<Quadruple<T0, T1, T2, T3>>.removeFromIndex(indexName: .indexName(kp0, kp1, kp2, kp3), self, in: &context)
    }
}
