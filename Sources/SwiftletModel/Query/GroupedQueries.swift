//
//  QueriesGroup.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 13/04/2025.
//


public typealias GroupedQueries<Entity: EntityModelProtocol> = ContextQuery<Entity, [[Query<Entity>]], Void>

public extension ContextQuery where Result == [[Query<Entity>]], Key == Void {
    func resolve() -> [[Entity]] {
        resolveQueries().compactMap { $0.resolve() }
    }
}

extension ContextQuery where Result == [[Query<Entity>]], Key == Void {
    func whenResolved<T>(then perform: @escaping ([[Query<Entity>]]) -> [[Query<T>]]) -> GroupedQueries<T> {
        GroupedQueries<T>(context: context) {
            let queries = resolveQueries()
            return perform(queries)
        }
    }
    
    init(context: Context, queriesResolver: @escaping () -> [[Query<Entity>]]) {
        self.context = context
        self.key = { _ in Void() }
        self.result = { _,_ in queriesResolver() }
    }
    
    func resolveQueries() -> [[Query<Entity>]] {
        result(context, key(context))
    }
}
