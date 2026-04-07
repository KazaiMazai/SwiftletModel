//
//  QueryAndFilters.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 06/04/2025.
//

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable {
        filter(predicate)
    }

    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Hashable {
        filter(predicate)
    }

    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Equatable {
        filter(predicate)
    }

    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Hashable & Comparable {
        filter(predicate)
    }
    
    func and(_ queryList: @escaping @autoclosure () -> QueryList<Entity>) -> QueryList<Entity> {
        then { context, queries in
            let ids = queryList()
                .queries(context)
                .map { query in query.id(context) }
            
            let set = Set(ids)
            return queries
                .filter { query in set.contains(query.id(context)) }
        }
    }

    func or(_ queryList: @escaping @autoclosure () -> QueryList<Entity>) -> QueryList<Entity> {
        then { context, queries in
            [queries, queryList().queries(context)]
                .flatMap { $0 }
                .distinct(by: { $0.id(context) })
        }
    }
}
