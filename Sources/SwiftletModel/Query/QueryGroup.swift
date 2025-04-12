//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

import Foundation

public typealias QueryGroup<Entity: EntityModelProtocol> = Lazy<Entity, Array<Query<Entity>>, Void>

public extension Lazy where Result == [Query<Entity>], Metadata == Void {
    func resolve() -> [Entity] {
        resolver().resolve()
    }
}

extension Lazy where Result == [Query<Entity>], Metadata == Void {
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [Query<T>]) -> QueryGroup<T> {
        QueryGroup<T>(context: context) {
            let queries = self.resolver()
            return perform(queries)
        }
    }
    
    init(context: Context, queriesResolver: @escaping () -> [Query<Entity>]) {
        self.context = context
        self.metadata = Void()
        self.resolver = queriesResolver
    }
    
    func resolveQueries() -> [Query<Entity>] {
        resolver()
    }
}
