//
//  QuerySorted.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//
import Foundation

typealias SortIndex = Index

private extension Collection {
    func sorted<Entity, T>(
        by keyPath: KeyPath<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(keyPath), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted { lhs, rhs in
                    lhs[keyPath: keyPath] < rhs[keyPath: keyPath]
                }
                .query(in: context)
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1>(by kp0: KeyPath<Entity, T0>,
                                _ kp1: KeyPath<Entity, T1>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<Pair<T0, T1>>
            .query(.indexName(kp0, kp1), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted { lhs, rhs in
                    (lhs[keyPath: kp0], lhs[keyPath: kp1]) <
                    (rhs[keyPath: kp0], rhs[keyPath: kp1])
                }
                .query(in: context)
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1, T2>(by kp0: KeyPath<Entity, T0>,
                                    _ kp1: KeyPath<Entity, T1>,
                                    _ kp2: KeyPath<Entity, T2>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<Triplet<T0, T1, T2>>
            .query(.indexName(kp0, kp1, kp2), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted { lhs, rhs in
                    (lhs[keyPath: kp0], lhs[keyPath: kp1], lhs[keyPath: kp2]) <
                    (rhs[keyPath: kp0], rhs[keyPath: kp1], rhs[keyPath: kp2])
                }
                .query(in: context)
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1, T2, T3>(by kp0: KeyPath<Entity, T0>,
                                        _ kp1: KeyPath<Entity, T1>,
                                        _ kp2: KeyPath<Entity, T2>,
                                        _ kp3: KeyPath<Entity, T3>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        guard let index = SortIndex<Entity>.ComparableValue<Quadruple<T0, T1, T2, T3>>
            .query(.indexName(kp0, kp1, kp2, kp3), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted { lhs, rhs in
                    (lhs[keyPath: kp0], lhs[keyPath: kp1], lhs[keyPath: kp2], lhs[keyPath: kp3]) <
                    (rhs[keyPath: kp0], rhs[keyPath: kp1], rhs[keyPath: kp2], rhs[keyPath: kp3])
                }
                .query(in: context)
        }
        
        return sorted(using: index)
    }
}

//MARK: - Private Sorting

private extension Collection {

    func sorted<Entity, T>(using index: SortIndex<Entity>.ComparableValue<T>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T: Comparable {
        
        let queries = Dictionary(map { query in (query.id, query) }, uniquingKeysWith: { $1 })
        return index
            .sorted
            .compactMap { queries[$0] }
    }
}

private extension LazyQuery where QueryResult == [Query<Entity>], Metadata == Void {

    func sorted<T>(using index: SortIndex<Entity>.ComparableValue<T>) -> Queries<Entity>
    
    where
    T: Comparable {
        
        whenResolved {
            $0.sorted(using: index)
        }
    }
}

public extension LazyQuery where QueryResult == [Query<Entity>], Metadata == Void {
    func sorted<T>(
        by keyPath: KeyPath<Entity, T>) -> Queries<Entity>
    where
    T: Comparable {
        whenResolved {
            $0.sorted(by: keyPath)
        }
    }
    
    func sorted<T0, T1>(by kp0: KeyPath<Entity, T0>,
                        _ kp1: KeyPath<Entity, T1>) -> Queries<Entity>
    
    where
    T0: Comparable,
    T1: Comparable {

        whenResolved {
            $0.sorted(by: kp0, kp1)
        }
    }
    
    func sorted<T0, T1, T2>(by kp0: KeyPath<Entity, T0>,
                            _ kp1: KeyPath<Entity, T1>,
                            _ kp2: KeyPath<Entity, T2>) -> Queries<Entity>
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        whenResolved {
            $0.sorted(by: kp0, kp1, kp2)
        }
    }
    
    func sorted<T0, T1, T2, T3>(by kp0: KeyPath<Entity, T0>,
                                _ kp1: KeyPath<Entity, T1>,
                                _ kp2: KeyPath<Entity, T2>,
                                _ kp3: KeyPath<Entity, T3>) -> Queries<Entity>
    
    where
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        whenResolved {
            $0.sorted(by: kp0, kp1, kp2, kp3)
        }
    }
}
