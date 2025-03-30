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
    
    static func batchQuery(with nested: Nested..., in context: Context) -> [Query<Self>]
         
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
    
    static func query(_ ids: [ID], in context: Context) -> [Query<Self>] {
        context.query(ids)
    }
    
    static func query(in context: Context) -> [Query<Self>] {
        context.query()
    }
    
    static func batchQuery(with nested: Nested..., in context: Context) -> [Query<Self>] {
        Self.query(in: context)
            .with(nested)
    }
}

public extension Collection {
    func query<Entity>(in context: Context) -> [Query<Entity>] where Element == Entity, Entity: EntityModelProtocol {
        map { $0.query(in: context) }
    }
}

public extension EntityModelProtocol {

    static func query<T>(where keyPath: KeyPath<Self, T>,
                         equals value: T,
                         in context: Context) -> [Self] where T: Comparable {
        
        guard let index = SortIndex<Self>.ComparableValue<T>
            .query(.indexName(keyPath), in: context)
            .resolve()
        else {
            return query(in: context)
                .resolve()
                .filter { $0[keyPath: keyPath] == value }
        }
        
        return query(index.filter(value), in: context)
            .resolve()
    }
    
    static func query<T>(where keyPath: KeyPath<Self, T>,
                         in range: Range<T>,
                         in context: Context) -> [Self] where T: Comparable {
        
        guard let index = SortIndex<Self>.ComparableValue<T>
            .query(.indexName(keyPath), in: context)
            .resolve()
        else {
            return query(in: context)
                .resolve()
                .filter { range.contains($0[keyPath: keyPath]) }
        }
        
        return query(index.filter(range: range), in: context)
            .resolve()
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
