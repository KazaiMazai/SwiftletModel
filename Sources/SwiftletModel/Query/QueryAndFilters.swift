//
//  QueryAndFilters.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 06/04/2025.
//

public extension Collection {
    func and<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        filter(predicate)
    }

    func and<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable {
        filter(predicate)
    }
    
    func and<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {
        filter(predicate)
    }

    func and<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable & Comparable  {
        filter(predicate)
    }
    
    func or<Entity>(_ query: @autoclosure () -> [Query<Entity>]) -> [Query<Entity>]
    where
    Element == Query<Entity> {
        [Array(self), query()].flatMap { $0 }
            .removingDuplicates(by: { $0.id })
    }
}
