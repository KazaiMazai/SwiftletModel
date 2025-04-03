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
    static func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        Query.filter(predicate, in: context)
    }
    
    func and<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        filter(predicate)
    }
    
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
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        let filterResult = Set(index.filter(with: predicate))
        return filter( { filterResult.contains($0.id) })
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
                .filter(predicate.isIncluded)
                .query(in: context)
        }
        
        return index
            .filter(with: predicate)
            .map { Query<Entity>(context: context, id: $0) }
    }
}

//MARK: - Private Filtering

extension Collection {
   
    func or<Entity>(query: () -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        [Array(self), query()].flatMap { $0 }
            .removingDuplicates(by: { $0.id })
    }
  
    func or<Entity>(_ query: @autoclosure () -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        or(query: query)
    }
}

extension Array {
    func removingDuplicates<Key: Hashable>(by key: (Element) -> Key) -> [Element] {
        var addedDict = [Key: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: key($0)) == nil
        }
    }
}
