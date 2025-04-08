//
//  QueryAndFilters.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 06/04/2025.
//

extension Collection {
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

public extension LazyQuery where QueryResult == [Query<Entity>], Metadata == Void {
    func and<T>(
        _ predicate: Predicate<Entity, T>) -> Queries<Entity>
    where
    T: Comparable {
        whenResolved {
            $0.and(predicate)
        }
    }

    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> Queries<Entity>
    where
    T: Hashable {
        
        whenResolved {
            $0.and(predicate)
        }
    }
    
    func and<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> Queries<Entity>
    where
    T: Equatable {
        whenResolved {
            $0.and(predicate)
        }
    }

    func and<T>(
        _ predicate: Predicate<Entity, T>) -> Queries<Entity>
    where
    T: Hashable & Comparable  {
        whenResolved {
            $0.and(predicate)
        }
    }
    
    func or(_ query: @escaping @autoclosure () -> Queries<Entity>) -> Queries<Entity>{
        whenResolved {
            [$0, query().resolveQueries()].flatMap { $0 }
                 .removingDuplicates(by: { $0.id })
        }
    }
}
