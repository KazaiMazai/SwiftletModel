//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 10/03/2025.
//

import Foundation

public struct CollisionResolver<Entity: EntityModelProtocol> {
    let resolveCollisionHandler: (Entity.ID, Entity.ID, String, inout Context) throws -> Void

    func resolveCollision(existing: Entity.ID, new: Entity.ID, indexName: String, in context: inout Context) throws {
        try resolveCollisionHandler(existing, new, indexName, &context)
    }

    public init(resolveCollisionHandler: @escaping (Entity.ID, Entity.ID, String, inout Context) throws -> Void) {
        self.resolveCollisionHandler = resolveCollisionHandler
    }
}

public extension CollisionResolver {
    static var `throw`: Self {
        CollisionResolver { existing, new, indexName, _ in
            throw Errors.uniqueValueIndexViolation(existing: existing, new: new, indexName: indexName)
        }
    }

    static var upsert: Self {
        CollisionResolver { existing, _, _, context in
            try Query<Entity>(context: context, id: existing)
                .resolve()?
                .delete(from: &context)
        }
    }
}

public extension CollisionResolver {
    enum Errors: Error {
        case uniqueValueIndexViolation(existing: Entity.ID, new: Entity.ID, indexName: String)
    }
}
