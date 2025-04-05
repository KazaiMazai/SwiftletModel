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
        
        guard let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        let filterResult = Set(index.filter(predicate))
        return filter( { filterResult.contains($0.id) })
    }
}

public extension Query {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {
        
        guard let index = Index<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        return index
            .filter(predicate)
            .map { Query<Entity>(context: context, id: $0) }
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
    
    func or<Entity>(_ query: @autoclosure () -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        [Array(self), query()].flatMap { $0 }
            .removingDuplicates(by: { $0.id })
    }
}
