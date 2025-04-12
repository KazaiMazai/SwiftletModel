//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias QueryModifier<T: EntityModelProtocol> = (Query<T>) -> Query<T>

//MARK: - Nested Entity Query

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, slice: false, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, slice: true, fragment: false, nested: nested)
        }
}

//MARK: - Nested Fragment Query

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, slice: false, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            with(keyPath, slice: true, fragment: true, nested: nested)
        }
}

//MARK: - Query Nested Ids

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Self {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = related(keyPath)
                    .id.map { .id($0)} ?? .none
                return entity
            }
        }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Self {
            
            id(keyPath, slice: false)
        }
    
    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Self {
            
            id(keyPath, slice: true)
        }
}


//MARK: - Private Nested Queries

extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        fragment: Bool,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = nested(related(keyPath))
                    .resolve()
                    .map { .relation($0, fragment: fragment) } ?? .none
                
                return entity
            }
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool,
        fragment: Bool,
        nested: @escaping QueryModifier<Child>) -> Self {
            
            whenResolved {
                var entity = $0
                let relatedEntities = queryRelated(keyPath)
                    .map { nested($0) }
                    .compactMap { $0.resolve() }
                
                entity[keyPath: keyPath] = slice ?
                    .appending(relatedEntities, fragment: fragment) :
                    .relation(relatedEntities, fragment: fragment)
                return entity
            }
        }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool) -> Self {
            
            whenResolved {
                var entity = $0
                let ids = queryRelated(keyPath).compactMap { $0.id }
                entity[keyPath: keyPath] = slice ? .appending(ids: ids) : .ids(ids)
                return entity
            }
        }
}
