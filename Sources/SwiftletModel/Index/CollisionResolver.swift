//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 10/03/2025.
//

import Foundation

public struct CollisionResolver<Entity: EntityModelProtocol> {
    let resolveCollisionHandler: (Entity.ID, inout Context) throws -> Void
    
    func resolveCollision(id: Entity.ID, in context: inout Context) throws {
        try resolveCollisionHandler(id, &context)
    }
    
    public init(resolveCollisionHandler: @escaping (Entity.ID, inout Context) throws -> Void) {
        self.resolveCollisionHandler = resolveCollisionHandler
    }
}

public extension CollisionResolver {
    static var `throw`: Self {
        CollisionResolver { id, _ in
            throw Errors.uniqueValueIndexViolation(id: id)
        }
    }
    
    static var upsert: Self {
        CollisionResolver { id, context in
            try Query<Entity>(context: context, id: id)
                .resolve()?
                .delete(from: &context)
                
        }
    }
}
 
public extension CollisionResolver {
    enum Errors: Error {
        case uniqueValueIndexViolation(id: Entity.ID)
    }
}
