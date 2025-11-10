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
    func resolve(_ context: Context) -> Entity? {
        value(context, id(context))
    }
}

public extension Collection {
    func resolve<Entity>(_ context: Context) -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve(context) }
    }
}

extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func id(_ context: Context) -> Entity.ID? { key(context) }

    init(id: Entity.ID) {
        self.key = { _ in  id }
        self.value = { context, id in id.flatMap { context.find($0) }}
    }

    init(id: @escaping (Context) -> Entity.ID?) {
        self.key = id
        self.value = { context, id in id.flatMap { context.find($0) } }
    }

    init(id: @escaping (Context) -> Entity.ID?, entity: @escaping (Context) -> Entity?) {
        self.key = id
        self.value = { context, _ in entity(context) }
    }

    func then(perform: @escaping (Context, Entity) -> Entity?) -> Query<Entity> {
        Query(id: id) { context in
            guard let entity = resolve(context) else {
                return nil
            }

            return perform(context, entity)
        }
    }

    static var none: Self {
        Self(id: { _ in nil })
    }
}

// MARK: - Entities Collection Extension

extension Collection {
    func query<Entity>() -> [Query<Entity>]
    where
    Element == Entity,
    Entity: EntityModelProtocol {

        map { $0.query() }
    }
}
