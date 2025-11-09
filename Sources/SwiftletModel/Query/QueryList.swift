//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 07/04/2025.
//

import Foundation

public typealias QueryList<Entity: EntityModelProtocol> = ContextQuery<Entity, [Query<Entity>], Void>

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func resolve(_ context: Context) -> [Entity] {
        resolveQueries(context).resolve(context)
    }
}

extension ContextQuery where Result == [Query<Entity>], Key == Void, Entity: EntityModelProtocol {
    func whenResolved<T>(then perform: @escaping (Context, [Query<Entity>]) -> [Query<T>]) -> QueryList<T> {
        QueryList<T> { context in
            let queries = resolveQueries(context)
            return perform(context, queries)
        }
    }

    func whenResolved<T>(then perform: @escaping (Context, [Query<Entity>]) -> [[Query<T>]]) -> QueryGroup<T> {
        QueryGroup<T> { context in
            let queries = resolveQueries(context)
            return perform(context, queries)
        }
    }

    init(queriesResolver: @escaping (Context) -> [Query<Entity>]) {
        self.key = { _ in Void() }
        self.value = { context, _ in queriesResolver(context) }
    }
    
    init(ids: [Entity.ID]) {
        self.key = { _ in Void() }
        self.value = { context, _ in ids.map { context.query($0) } }
    }
    
    init() {
        self = QueryList<Entity> { context in
            context.ids(Entity.self).map { context.query($0)}
        }
    }

    func resolveQueries(_ context: Context) -> [Query<Entity>] {
        value(context, key(context))
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func first() -> Query<Entity> {
        Query { context in
            resolveQueries(context).first?.id(context)
        }
    }

    func last() -> Query<Entity> {
        Query { context in
            resolveQueries(context).last?.id(context)
        }
    }
    
    func limit(_ limit: Int, offset: Int = 0) -> QueryList<Entity> {
        whenResolved { queries in
            queries.limit(limit, offset: offset)
        }
    }
}
