//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public struct Query<Entity: EntityModelProtocol> {
    typealias Resolver = () -> Entity?
    
    public let id: Entity.ID
    
    let context: Context
    let resolver: Resolver
    
    public init(context: Context, id: Entity.ID) {
        self.context = context
        self.id = id
        self.resolver = { context.find(id) }
    }
    
    public func resolve() -> Entity? {
        resolver()
    }
}
 
//MARK: - Resolve Query Collection

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

//MARK: - Context Query Extension

extension Context {
    func query<Entity: EntityModelProtocol>(_ id: Entity.ID) -> Query<Entity> {
        Query(context: self, id: id)
    }
    
    func query<Entity: EntityModelProtocol>(_ ids: [Entity.ID]) -> [Query<Entity>] {
        ids.map { query($0) }
    }
    
    func query<Entity: EntityModelProtocol>(_ ids: [Entity.ID]) -> Queries<Entity> {
        Queries(context: self) {
            ids.map { query($0) }
        }
    }
    
    func query<Entity: EntityModelProtocol>() -> [Query<Entity>] {
        query(ids(Entity.self))
    }
    
    func query<Entity: EntityModelProtocol>() -> Queries<Entity> {
        query(ids(Entity.self))
    }
}

//MARK: - Internal Query extensions

extension Query {
    
    init(context: Context, id: Entity.ID, resolver: @escaping () -> Entity?) {
        self.context = context
        self.id = id
        self.resolver = resolver
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

