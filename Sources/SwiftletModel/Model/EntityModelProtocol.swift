//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public protocol EntityModelProtocol {
    // swiftlint:disable:next type_name
    associatedtype ID: Hashable, LosslessStringConvertible

    var id: ID { get }

    func save(to context: inout Context, options: MergeStrategy<Self>) throws

    func willSave(to context: inout Context) throws

    func didSave(to context: inout Context) throws

    func delete(from context: inout Context) throws

    func willDelete(from context: inout Context) throws

    func didDelete(from context: inout Context) throws
  
    mutating func normalize()

    static var defaultMergeStrategy: MergeStrategy<Self> { get }

    static var fragmentMergeStrategy: MergeStrategy<Self> { get }

    static var patch: MergeStrategy<Self> { get }
    
    static func batchQuery(with nested: Nested..., in context: Context) -> QueryGroup<Self>
         
    static func nestedQueryModifier(_ query: Query<Self>, nested: [Nested]) -> Query<Self>
}

public extension EntityModelProtocol {
    
    static var defaultMergeStrategy: MergeStrategy<Self> { .replace }

    static var fragmentMergeStrategy: MergeStrategy<Self> { Self.patch }

    func willDelete(from context: inout Context) throws { }

    func willSave(to context: inout Context) throws { }

    func didDelete(from context: inout Context) throws { }

    func didSave(to context: inout Context) throws { }
}

public extension MergeStrategy where T: EntityModelProtocol {
    static var `default`: MergeStrategy<T> {
        T.defaultMergeStrategy
    }

    static var fragment: MergeStrategy<T> {
        T.fragmentMergeStrategy
    }
}

public extension EntityModelProtocol {
    static func delete(id: ID, from context: inout Context) throws {
        try Self.query(id, in: context)
            .resolve()?
            .delete(from: &context)
    }
}

public extension EntityModelProtocol {
    func query(in context: Context) -> Query<Self> {
        Self.query(id, in: context)
    }
    
    static func query(_ id: ID, in context: Context) -> Query<Self> {
        context.query(id)
    }
     
    static func query(_ ids: [ID], in context: Context) -> QueryGroup<Self> {
        context.query(ids)
    }
     
    static func query(in context: Context) -> QueryGroup<Self> {
        context.query()
    }
   
    static func batchQuery(with nested: Nested..., in context: Context) -> QueryGroup<Self> {
        Self.query(in: context)
            .with(nested)
    }
}

// MARK: - Filter Query

public extension EntityModelProtocol {
    static func filter<T>(
        _ predicate: Predicate<Self, T>,
        in context: Context) -> QueryGroup<Self>
    where
    T: Comparable {
        Query<Self>.filter(predicate, in: context)
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Self, T>,
        in context: Context) -> QueryGroup<Self>
    where
    T: Hashable {
        Query<Self>.filter(predicate, in: context)
    }
    
    static func filter<T>(
        _ predicate: Predicate<Self, T>,
        in context: Context) -> QueryGroup<Self>
    where
    T: Hashable & Comparable {
        Query<Self>.filter(predicate, in: context)
    }
    
    static func filter(
        _ predicate: StringPredicate<Self>,
        in context: Context) -> QueryGroup<Self> {
        Query<Self>.filter(predicate, in: context)
    }
}

extension EntityModelProtocol {
    func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
}

extension PartialKeyPath {
    var name: String {
        String(describing: self)
    }
}

extension EntityModelProtocol {
    func relationIds<Child, Direction, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, Relation<Child, Direction, Cardinality, Constraint>>
    ) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }

    func relation<Child, Direction, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, Relation<Child, Direction, Cardinality, Constraint>>
    ) -> Relation<Child, Direction, Cardinality, Constraint> {
        self[keyPath: keyPath]
    }
}
