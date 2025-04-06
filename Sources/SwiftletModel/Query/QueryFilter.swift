//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections


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

public extension Query {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> [Query<Entity>] {
        
        if predicate.method == .matches,
            let index = FullTextIndex<Entity>
            .HashableValue<String>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve() {
            
            return index
                .search(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}
