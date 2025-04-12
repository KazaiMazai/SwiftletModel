//
//  Context+Query.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/04/2025.
//

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
