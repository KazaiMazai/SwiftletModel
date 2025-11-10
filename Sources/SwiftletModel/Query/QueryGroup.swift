//
//  QueriesGroup.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 13/04/2025.
//

public typealias QueryGroup<Entity: EntityModelProtocol> = ContextQuery<Entity, [[Query<Entity>]], Void>

public extension ContextQuery where Result == [[Query<Entity>]], Key == Void {
    func resolve(_ context: Context) -> [[Entity]] {
        resolveQueries(context).compactMap { $0.resolve(context) }
    }
}

extension ContextQuery where Result == [[Query<Entity>]], Key == Void {
    init(queriesResolver: @escaping (Context) -> [[Query<Entity>]]) {
        self.key = { _ in Void() }
        self.result = { context, _ in queriesResolver(context) }
    }

    func resolveQueries(_ context: Context) -> [[Query<Entity>]] {
        result(context, key(context))
    }
}
