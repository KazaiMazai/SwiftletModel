//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

import Foundation

public typealias QueryGroup<Entity: EntityModelProtocol> = ContextQuery<Entity, Array<Query<Entity>>, Void>

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func resolve() -> [Entity] {
        resolveQueries().resolve()
    }
}

extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [Query<T>]) -> QueryGroup<T> {
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
