//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias Query<Entity: EntityModelProtocol> = Lazy<Entity, Optional<Entity>, Entity.ID>

public extension Lazy where Result == Optional<Entity>, Key == Entity.ID {
    init(context: Context, id: Entity.ID) {
        self.context = context
        self.keyResolver = { _ in  id }
        self.resolver = { context, id in id.flatMap { context.find($0) }}
    }
    
    func resolve() -> Entity? {
        resolver(context, keyResolver(context))
    }
    
    var id: Entity.ID? { keyResolver(context) }
}

//MARK: - Resolve Query Collection

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

extension Lazy where Result == Optional<Entity>, Key == Entity.ID {
    init(context: Context, idResolver: @escaping (Context) -> Entity.ID?) {
        self.context = context
        self.keyResolver = idResolver
        self.resolver = { context, id in id.flatMap { context.find($0) } }
    }
    
    static func none(in context: Context) -> Self {
        Self(context: context, idResolver: { _ in nil })
    }
    
    init(context: Context, id: Entity.ID?, resolver: @escaping () -> Entity?) {
        self.context = context
        self.keyResolver = { _ in id }
        self.resolver = { _,_ in resolver() }
    }
    
    func whenResolved(then perform: @escaping (Entity) -> Entity?) -> Query<Entity> {
        Query(context: context, id: id) {
            guard let entity = resolve() else {
                return nil
            }
            
            return perform(entity)
        }
    }
}

//MARK: - Entities Collection Extension

extension Collection {
    func query<Entity>(in context: Context) -> [Query<Entity>]
    where
    Element == Entity,
    Entity: EntityModelProtocol {
        
        map { $0.query(in: context) }
    }
}

