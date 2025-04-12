//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias Query<Entity: EntityModelProtocol> = ContextQuery<Entity, Optional<Entity>, Entity.ID>

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    init(context: Context, id: Entity.ID) {
        self.context = context
        self.key = { _ in  id }
        self.result = { context, id in id.flatMap { context.find($0) }}
    }
    
    func resolve() -> Entity? {
        result(context, id)
    }
    
    var id: Entity.ID? { key(context) }
}

//MARK: - Resolve Query Collection

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func none(in context: Context) -> Self {
        Self(context: context, id: nil) { nil }
    }
    
    init(context: Context, id: @escaping (Context) -> Entity.ID?) {
        self.context = context
        self.key = id
        self.result = { context, id in id.flatMap { context.find($0) } }
    }
    
    fileprivate init(context: Context, id: Entity.ID?, entity: @escaping () -> Entity?) {
        self.context = context
        self.key = { _ in id }
        self.result = { _,_ in entity() }
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

