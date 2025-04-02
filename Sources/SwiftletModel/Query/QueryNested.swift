//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias QueryModifier<T: EntityModelProtocol> = (Query<T>) -> Query<T>

//MARK: - Nested Entity Query

public extension Query {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: false, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: true, fragment: false, nested: nested)
        }
}

//MARK: - Nested Fragment Query

public extension Query {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: false, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: true, fragment: true, nested: nested)
        }
}

//MARK: - Query Nested Ids

public extension Query {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Query {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = related(keyPath)
                    .map { .id($0.id) } ?? .none
                return entity
            }
        }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Query {
            
            id(keyPath, slice: false)
        }
    
    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Query {
            
            id(keyPath, slice: true)
        }
}


//MARK: - Private Nested Queries

extension Query {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        fragment: Bool,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = related(keyPath)
                    .map { nested($0) }
                    .flatMap { $0.resolve() }
                    .map { .relation($0, fragment: fragment) } ?? .none
                
                return entity
            }
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool,
        fragment: Bool,
        nested: @escaping QueryModifier<Child>) -> Query {
            
            whenResolved {
                var entity = $0
                let relatedEntities = related(keyPath)
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
        slice: Bool) -> Query {
            
            whenResolved {
                var entity = $0
                let ids = related(keyPath).map { $0.id }
                entity[keyPath: keyPath] = slice ? .appending(ids: ids) : .ids(ids)
                return entity
            }
        }
}
