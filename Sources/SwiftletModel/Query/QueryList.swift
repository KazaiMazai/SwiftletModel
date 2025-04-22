//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

import Foundation

public typealias QueryList<Entity: EntityModelProtocol> = ContextQuery<Entity, [Query<Entity>], Void>

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func resolve() -> [Entity] {
        resolveQueries().resolve()
    }
}

extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [Query<T>]) -> QueryList<T> {
        QueryList<T>(context: context) {
            let queries = resolveQueries()
            return perform(queries)
        }
    }
    
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [[Query<T>]]) -> QueryGroup<T> {
        QueryGroup<T>(context: context) {
            let queries = resolveQueries()
            return perform(queries)
        }
    }
    
    init(context: Context, queriesResolver: @escaping () -> [Query<Entity>]) {
        self.context = context
        self.key = { _ in Void() }
        self.result = { _,_ in queriesResolver() }
    }
    
    func resolveQueries() -> [Query<Entity>] {
        result(context, key(context))
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func first() -> Query<Entity> {
        Query(context: context) { _ in
            resolveQueries().first?.id
        }
    }
    
    func last() -> Query<Entity> {
        Query(context: context) { _ in
            resolveQueries().last?.id
        }
    }
}
