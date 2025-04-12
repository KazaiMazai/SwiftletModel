//
//  QueryAndFilters.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 06/04/2025.
//
 
public extension Lazy where Result == [Query<Entity>], Metadata == Void {
    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Comparable {
        whenResolved { $0.filter(predicate) }
    }

    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Hashable {
        whenResolved { $0.filter(predicate) }
    }
    
    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Equatable {
        whenResolved { $0.filter(predicate) }
    }

    func and<T>(
        _ predicate: Predicate<Entity, T>) -> QueryGroup<Entity>
    where
    T: Hashable & Comparable  {
        whenResolved { $0.filter(predicate) }
    }
    
    func or(_ query: @escaping @autoclosure () -> QueryGroup<Entity>) -> QueryGroup<Entity>{
        whenResolved {
            [$0, query().resolveQueries()]
                .flatMap { $0 }
                .removingDuplicates(by: { $0.id })
        }
    }
}
