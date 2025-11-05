//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation

public typealias Query<Entity: EntityModelProtocol> = ContextQuery<Entity, Entity?, Entity.ID>

// MARK: - Resolve Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func resolve() -> Entity? {
        result(context, id)
    }
}

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }

}

extension ContextQuery where Result == Entity?, Key == Entity.ID {
    var id: Entity.ID? { key(context) }

    init(context: Context, id: Entity.ID) {
        self.context = context
        self.key = { _ in  id }
        self.result = { context, id in id.flatMap { context.find($0) }}
    }

    init(context: Context, id: @escaping (Context) -> Entity.ID?) {
        self.context = context
        self.key = id
        self.result = { context, id in id.flatMap { context.find($0) } }
    }

    init(context: Context, id: Entity.ID?, entity: @escaping () -> Entity?) {
        self.context = context
        self.key = { _ in id }
        self.result = { _, _ in entity() }
    }

    func whenResolved(then perform: @escaping (Entity) -> Entity?) -> Query<Entity> {
        Query(context: context, id: id) {
            guard let entity = resolve() else {
                return nil
            }

            return perform(entity)
        }
    }

    static func none(in context: Context) -> Self {
        Self(context: context, id: nil) { nil }
    }
}

// MARK: - Entities Collection Extension

extension Collection {
    func query<Entity>(in context: Context) -> [Query<Entity>]
    where
    Element == Entity,
    Entity: EntityModelProtocol {

        map { $0.query(in: context) }
    }
}
