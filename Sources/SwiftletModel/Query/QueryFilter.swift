//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections

public extension Collection {
    static func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        Query.filter(predicate, in: context)
    }
     
    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            let filterResult = Set(index.filter(predicate))
            return filter( { filterResult.contains($0.id) })
        }
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        return self
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}

public extension Query {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {

        if let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
            .filter(predicate)
            .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable & Hashable {

        if predicate.method == .equal, let index = Index<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
                .find(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }

        if let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
                .filter(predicate)
                .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Hashable {

        if predicate.method == .equal, let index = Index<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {

            return index
            .find(predicate.value)
            .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Equatable {

        Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}

public extension Collection {
    func and<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        filter(predicate)
    }

    func and<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable {
        filter(predicate)
    }
    
    func and<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {
        filter(predicate)
    }

    func and<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable & Comparable  {
        filter(predicate)
    }
    
    func or<Entity>(_ query: @autoclosure () -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        [Array(self), query()].flatMap { $0 }
            .removingDuplicates(by: { $0.id })
    }
}
