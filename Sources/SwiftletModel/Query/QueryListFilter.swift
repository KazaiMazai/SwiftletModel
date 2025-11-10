//
//  QueryCollectionFilter.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 06/04/2025.
//
import Foundation

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    static func filter<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable {
        Query.filter(predicate)
    }

    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable {
        then { context, queries in queries.filter(predicate, in: context) }
    }

    func filter<T>(
        _ predicate: Predicate<Entity, T>) -> QueryList<Entity>
    where
    T: Comparable & Hashable {
        then { context, queries in queries.filter(predicate, in: context) }
    }

    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Hashable {
        then { context, queries in queries.filter(predicate, in: context) }
    }

    func filter<T>(
        _ predicate: EqualityPredicate<Entity, T>) -> QueryList<Entity>
    where
    T: Equatable {
        then { context, queries in queries.filter(predicate, in: context) }
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func filter( _ predicate: StringPredicate<Entity>) -> QueryList<Entity> {
        then { context, queries in queries.filter(predicate, in: context) }
    }

    static func filter(
        _ predicate: StringPredicate<Entity>) -> QueryList<Entity> {
            Query.filter(predicate)
    }
}

// MARK: - Metadata Predicate Filter

public extension ContextQuery {

    func filter(_ predicate: MetadataPredicate) -> QueryList<Entity>
    where
    Result == [Query<Entity>],
    Key == Void {
        then { context, queries in queries.filter(predicate, in: context) }
    }
}

// MARK: - Private Collection Predicate Filter

private extension Collection {

    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable {

        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.filter(predicate))
            return filter({ filterResult.contains($0.id(context)) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query()
    }

    func filter<Entity, T>(
        _ predicate: Predicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Comparable & Hashable {
 

        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.find(predicate.value))
            return filter({ filterResult.contains($0.id(context)) })
        }

        if let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(predicate.keyPath))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.filter(predicate))
            return filter({ filterResult.contains($0.id(context)) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query()
    }

    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Hashable {

        if predicate.method == .equal, let index = SortIndex<Entity>.HashableValue<T>
            .query(.indexName(predicate.keyPath))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.find(predicate.value))
            return filter({ filterResult.contains($0.id(context)) })
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query()
    }

    func filter<Entity, T>(
        _ predicate: EqualityPredicate<Entity, T>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T: Equatable {

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query()
    }

    func filter<Entity>(
        _ predicate: MetadataPredicate,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity> {

        switch predicate {
        case let .updated(within: range):
            if let index = SortIndex<Entity>.ComparableValue<Date>
                .query(predicate.indexName)
                .resolve(context) {

                return filter { index.contains(id: $0.id(context), in: range) }
            }
        }

        return []
    }
}

// MARK: - Private Collection StringPredicate Filter

private extension Collection {

    func filter<Entity>(
        _ predicate: StringPredicate<Entity>,
        in context: Context) -> [Query<Entity>]
    where
    Element == Query<Entity> {

        if predicate.method.isMatching, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.search(predicate.value))
            return filter({ filterResult.contains($0.id(context)) })
        }

         if predicate.method.isIncluding, let index = FullTextIndex<Entity>
            .HashableValue<[String]>
            .query(.indexName(predicate.keyPaths))
            .resolve(context) {

            let filterResult: Set<Entity.ID?> = Set(index.search(predicate.value))
            return self
                .filter({ filterResult.contains($0.id(context)) })
                .resolve(context)
                .filter(predicate.isIncluded)
                .query()
        }

        return self
            .resolve(context)
            .filter(predicate.isIncluded)
            .query()
    }
}
