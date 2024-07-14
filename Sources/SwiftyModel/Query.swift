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
    private let resolved: Entity?
    
    init(repository: Repository, id: Entity.ID, entity: Entity? = nil) {
        self.repository = repository
        self.id = id
        self.resolved = entity
    }
    
    func resolve() -> Entity? {
        resolved ?? repository.find(id)
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
    typealias QueryModifier<T: EntityModel> = (Query<T>) -> Query<T>
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: QueryModifier<Child> = { $0 }) -> Query {
            
        guard var entity = resolve() else {
            return self
        }
        
        entity[keyPath: keyPath] = related(keyPath)
            .map { nested($0) }
            .flatMap { $0.resolve() }
            .map { .relation($0) } ?? .none
        
        return Query(repository: repository, id: id, entity: entity)
    }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: QueryModifier<Child> = { $0 }) -> Query {
        
        guard var entity = resolve() else {
            return self
        }
          
        entity[keyPath: keyPath] = .relation(
            related(keyPath)
                .map { nested($0) }
                .compactMap { $0.resolve() }
        )
        
        return Query(repository: repository, id: id, entity: entity)
    }
}
