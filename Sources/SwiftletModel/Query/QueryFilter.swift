//
//  QueryFilter.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

import Collections

public enum FilterGroup {
    case or
    case and
}

public extension Collection {
    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .filter { predicate.isIncluded($0) }
                .query(in: context)
        }
        
        let filterResult = OrderedSet(index.filter(with: predicate))
        return filter { filterResult.contains($0.id) }
    }
    
    func group<Entity>(_ filterGroup: FilterGroup,
                       query: (Self) -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        
        return switch filterGroup {
        case .and:
            query(self)
        case .or:
            or(query: query)
        }
    }
}

public extension Query {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    
    where
    T: Comparable {
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve()
        else {
            return Entity
                .query(in: context)
                .resolve()
                .filter { predicate.isIncluded($0) }
                .query(in: context)
        }
        
        return index
            .filter(with: predicate)
            .map { Query<Entity>(context: context, id: $0) }
    }
}

//MARK: - Private Filtering

extension Collection {
    func or<Entity>(query: (Self) -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        
        guard let context = first?.context else {
            return query(self)
        }
        
        let current = map { $0.id }
        let result = query(self).map { $0.id }
        return OrderedSet(
            [current, result]
            .flatMap { $0 })
            .map { Query(context: context, id: $0) }
    }
    
    func and<Entity>(query: (Self) -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        query(self)
    }
     
}


