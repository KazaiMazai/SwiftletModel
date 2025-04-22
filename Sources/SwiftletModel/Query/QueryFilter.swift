//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import Collections
import Foundation

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Comparable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }

    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Comparable & Hashable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Hashable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
    
    static func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    
    where
    T: Equatable {

        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> QueryList<Entity> {
        
        QueryList(context: context) {
            Query.filter(predicate, in: context)
        }
    }
}

//MARK: - Metadata Predicate Filter

public extension ContextQuery {
    func filter(
        _ predicate: MetadataPredicate) -> Query<Entity>
    where
    Result == Optional<Entity>,
    Key == Entity.ID {

        whenResolved { entity in
            switch predicate {
            case let .updated(within: range):
                if let index = SortIndex<Entity>.ComparableValue<Date>
                    .query(predicate.indexName, in: context)
                    .resolve() {
                     
                    return index.contains(id: entity.id, in: range) ? entity : nil
                }
            }
            
            return nil
        }
    }
    
    static func filter(
        _ predicate: MetadataPredicate,
        in context: Context) -> QueryList<Entity>
    where
    Result == Optional<Entity>,
    Key == Entity.ID {
        
        QueryList(context: context) {
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
    
    static func filter(
        _ predicate: MetadataPredicate,
        in context: Context) -> [Query<Entity>] {

        switch predicate {
        case let .updated(within: range):
            if let index = SortIndex<Entity>.ComparableValue<Date>
                .query(predicate.indexName, in: context)
                .resolve() {
                
                return index
                    .filter(range: range)
                    .map { Query<Entity>(context: context, id: $0) }
            }
        }
        
        return []
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
 

