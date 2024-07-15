//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Query<Entity: EntityModel> {
    let repository: Repository
    private let state: State
    
    init(repository: Repository, id: Entity.ID) {
        self.repository = repository
        self.state = .initial(id)
    }
    
    init(repository: Repository, resolved: Entity) {
        self.repository = repository
        self.state = .resolved(resolved)
    }
    
    var id: Entity.ID {
        state.id
    }
    
    func resolve() -> Entity? {
        state.resolved ?? repository.find(id)
    }
}

private extension Query {
    
    enum State {
        case initial(Entity.ID)
        case resolved(Entity)
        
        var id: Entity.ID {
            switch self {
            case .initial(let id):
                return id
            case .resolved(let entity):
                return entity.id
            }
        }
        
        var resolved: Entity? {
            switch self {
            case .initial:
                return nil
            case .resolved(let entity):
                return entity
            }
        }
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
    
    static var identity: QueryModifier<Entity> {
        { $0 }
    }
     
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: QueryModifier<Child> = Query.identity) -> Query {
            
        guard var entity = resolve() else {
            return self
        }
        
        entity[keyPath: keyPath] = related(keyPath)
            .map { nested($0) }
            .flatMap { $0.resolve() }
            .map { .relation($0) } ?? .none
        
        return Query(repository: repository, resolved: entity)
    }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        fragment: Bool = false,
        nested: QueryModifier<Child> = Query.identity) -> Query {
        
        guard var entity = resolve() else {
            return self
        }
            
        let resolved = related(keyPath)
                .map { nested($0) }
                .compactMap { $0.resolve() }
            
        entity[keyPath: keyPath] = fragment ? .fragment(resolved) :.relation(resolved)
        
        return Query(repository: repository, resolved: entity)
    }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Query {
            
        guard var entity = resolve() else {
            return self
        }
        
        entity[keyPath: keyPath] = related(keyPath)
            .map { .relation(id: $0.id) } ?? .none
        
        return Query(repository: repository, resolved: entity)
    }
    
    func ids<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        fragment: Bool = false) -> Query {
        
        guard var entity = resolve() else {
            return self
        }
            
        let ids = related(keyPath).map { $0.id }
        entity[keyPath: keyPath] = fragment ? .fragment(ids: ids) : .relation(ids: ids)
         
        return Query(repository: repository, resolved: entity)
    }
}
