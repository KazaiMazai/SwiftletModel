//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Query<Entity: EntityModel> {
    let repository: Repository
    let id: Entity.ID
    
    func resolve() -> Entity? {
        repository.find(id)
    }
}

extension Collection {
    func resolve<Entity>() -> [Entity?] where Element == Query<Entity> {
        map { $0.resolve() }
    }
}

extension Repository {
    func query<Entity: EntityModel>(_ id: Entity.ID) -> Query<Entity> {
        query(Entity.self, id: id)
    }
    
    func query<Entity: EntityModel>(_ type: Entity.Type, id: Entity.ID) -> Query<Entity> {
        Query(repository: self, id: id)
    }
    
    func query<Entity: EntityModel>(_ ids: [Entity.ID]) -> [Query<Entity>] {
        ids.map { query($0) }
    }
}


extension Query {
    
    func related<Child, Direction, Optionality>(_ keyPath: KeyPath<Entity, Relationship<Child, Direction, Relation.ToOne, Optionality>>) -> Query<Child>? {
        repository
            .findRelations(for: Entity.self, relationName: keyPath.relationName, id: id)
            .first
            .flatMap { Child.ID($0) }
            .map { Query<Child>(repository: repository, id:  $0) }
    }
    
    func related<Child, Direction, Optionality>(_ keyPath: KeyPath<Entity, Relationship<Child, Direction, Relation.ToMany, Optionality>>) -> [Query<Child>] {
        repository
            .findRelations(for: Entity.self, relationName: keyPath.relationName, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(repository: repository, id:  $0) }
    }
}

extension Collection {
    
    func related<Entity, Child, Direction, Optionality>(
        _ keyPath: KeyPath<Entity, Relationship<Child, Direction, Relation.ToOne, Optionality>>) -> [Query<Child>]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
    
    func related<Entity, Child, Direction, Optionality>(
        _ keyPath: KeyPath<Entity, Relationship<Child, Direction, Relation.ToMany, Optionality>>) -> [[Query<Child>]]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
}
