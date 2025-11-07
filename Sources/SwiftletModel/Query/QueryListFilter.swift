//
//  QueryCollectionFilter.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 06/04/2025.
//
import Foundation

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> QueryList<Entity>
    where
    T: Comparable {

        Query.filter(predicate, in: context)
    }

    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable {
        whenResolved { $0.filter(predicate) }
    }

    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable & Hashable {
        whenResolved { $0.filter(predicate) }
    }

    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Hashable {
        whenResolved { $0.filter(predicate) }
    }

    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Equatable {
        whenResolved { $0.filter(predicate) }
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func filter( _ predicate: StringPredicate<Entity>) -> QueryList<Entity> {
        whenResolved { $0.filter(predicate) }
    }

    static func filter(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> QueryList<Entity> {

            Query.filter(predicate, in: context)
    }
}

// MARK: - Metadata Predicate Filter

public extension ContextQuery {

    func filter(_ predicate: MetadataPredicate) -> QueryList<Entity>
    where
    Result == [Query<Entity>],
    Key == Void {
        whenResolved { $0.filter(predicate) }
    }
}

// MARK: - Private Collection Predicate Filter

private extension Collection {

    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {

        guard let context = first?.context else {
            return Array(self)
        }

        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.filter(predicate))
            return filter({ filterResult.contains($0.id) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable & Hashable {

        guard let context = first?.context else {
            return Array(self)
        }

        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.find(predicate.value))
            return filter({ filterResult.contains($0.id) })
        }

        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.filter(predicate))
            return filter({ filterResult.contains($0.id) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable {

        guard let context = first?.context else {
            return Array(self)
        }

        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.find(predicate.value))
            return filter({ filterResult.contains($0.id) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {

        guard let context = first?.context else {
            return Array(self)
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query(in: context)
    }

    func filter<Entity>(
        _ predicate: MetadataPredicate) -> [Query<Entity>]
    where
    Element == Query<Entity> {

        guard let context = first?.context else {
            return Array(self)
        }

        switch predicate {
        case let .updated(within: range):
            if let index = SortIndex<Entity>.ComparableValue<Date>
                .query(predicate.indexName, in: context)
                .resolve(context) {

                return filter { index.contains(id: $0.id, in: range) }
            }
        }

        return []
    }
}

// MARK: - Private Collection StringPredicate Filter

private extension Collection {

    func filter<Entity>(
        _ predicate: StringPredicate<Entity>) -> [Query<Entity>]
    where
    Element == Query<Entity> {

        guard let context = first?.context else {
            return Array(self)
        }

        if predicate.method.isMatching, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.search(predicate.value))
            return filter({ filterResult.contains($0.id) })
        }

         if predicate.method.isIncluding, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths), in: context)
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.search(predicate.value))
            return self
                .filter({ filterResult.contains($0.id) })
                .resolve(context)
                .filter(predicate.isIncluded)
                .query(in: context)
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query(in: context)
    }
}
