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
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
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
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
    
    ) -> Query<Child>? {
        repository
            .findChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .first
            .flatMap { Child.ID($0) }
            .map { Query<Child>(repository: repository, id:  $0) }
    }
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    
    ) -> [Query<Child>] {
        repository
            .findChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(repository: repository, id:  $0) }
    }
}

extension Collection {
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> [Query<Child>]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> [[Query<Child>]]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
}

extension Query {
    func resolve<Child, Directionality, Constraints>(
        with keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: (Query<Child>) -> Child? = { $0.resolve() }) -> Entity? {
            
        guard var entity = resolve() else {
            return nil
        }
        
        entity[keyPath: keyPath] = related(keyPath)
            .flatMap { nested($0) }
            .map { .relation($0) } ?? .none
        
        return entity
            
    }
    
    func resolve<Child, Directionality, Constraints>(
        with keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: (Query<Child>) -> Child? = { $0.resolve() }) -> Entity? {
        
        guard var entity = resolve() else {
            return nil
        }
          
        entity[keyPath: keyPath] = .relation(
            related(keyPath)
                .compactMap { nested($0) }
        )
        
        return entity
    }
}
