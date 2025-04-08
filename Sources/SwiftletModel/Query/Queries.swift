//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 07/04/2025.
//

import Foundation

public struct Queries<Entity: EntityModelProtocol> {
    typealias QueriesResolver = () -> [Query<Entity>]
    
    let context: Context
    let queriesResolver: QueriesResolver
    
    init(context: Context, queriesResolver: @escaping QueriesResolver) {
        self.context = context
        self.queriesResolver = queriesResolver
    }
    
    public func resolve() -> [Entity] {
        queriesResolver().resolve()
    }
    
    func resolveQueries() -> [Query<Entity>] {
        queriesResolver()
    }
}

extension Queries {
    func whenResolved<T>(then perform: @escaping ([Query<Entity>]) -> [Query<T>]) -> Queries<T> {
        Queries<T>(context: context) {
            let queries = queriesResolver()
            return perform(queries)
        }
    }
}
