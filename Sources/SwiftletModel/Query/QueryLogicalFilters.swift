//
//  QueryAndFilters.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 06/04/2025.
//
 
public extension Lazy where Result == [Query<Entity>], Key == Void {
    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Comparable {
        filter(predicate)
    }

    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Hashable {
        filter(predicate)
    }
    
    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Equatable {
        filter(predicate)
    }

    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Hashable & Comparable  {
        filter(predicate)
    }
    
    func or(_ queryGroup: @escaping @autoclosure () -> QueryGroup<Entity>) -> QueryGroup<Entity>{
        whenResolved { queries in
            [queries, queryGroup().resolveQueries()]
                .flatMap { $0 }
                .removingDuplicates(by: { $0.id })
        }
    }
}
