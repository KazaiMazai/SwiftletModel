//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

import Foundation

public typealias Queries<Entity: EntityModelProtocol> = LazyQuery<Entity, Array<Query<Entity>>, Void>
 
extension LazyQuery where QueryResult == [Query<Entity>], Metadata == Void {
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [Query<T>]) -> Queries<T> {
        Queries<T>(context: context) {
            let queries = self.resolver()
            return perform(queries)
        }
    }
    
    init(context: Context, queriesResolver: @escaping () -> [Query<Entity>]) {
        self.context = context
        self.id = Void()
        self.resolver = queriesResolver
    }
    
    public func resolve() -> [Entity] {
        resolver().resolve()
    }
    
    func resolveQueries() -> [Query<Entity>] {
        resolver()
    }
}
