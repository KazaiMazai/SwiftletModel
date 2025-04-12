//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryGroup<Entity>
    
    where
    T: Comparable {

        QueryGroup(context: context) {
            Query.filter(predicate, in: context)
        }
    }

    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryGroup<Entity>
    
    where
    T: Comparable & Hashable {

        QueryGroup(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryGroup<Entity>
    
    where
    T: Hashable {

        QueryGroup(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryGroup<Entity>
    
    where
    T: Equatable {

        QueryGroup(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> QueryGroup<Entity> {
        
        QueryGroup(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

//MARK: - Private Query Predicate Filter

private extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
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

//MARK: - Private Query StringPredicate Filter

private extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> [Query<Entity>] {
        
        if predicate.method.isMatching, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {
            
            return index
                .search(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
        }

         if predicate.method.isIncluding, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve() {
            
            return index
                .search(predicate.value)
                .map { Query<Entity>(context: context, id: $0) }
                .resolve()
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        return Entity
            .query(in: context)
            .resolve()
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}
 

