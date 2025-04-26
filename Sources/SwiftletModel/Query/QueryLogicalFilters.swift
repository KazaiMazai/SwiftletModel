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

    func or(_ queryList: @escaping @autoclosure () -> QueryList<Entity>) -> QueryList<Entity> {
        whenResolved { queries in
            [queries, queryList().resolveQueries()]
                .flatMap { $0 }
                .removingDuplicates(by: { $0.id })
        }
    }
}
