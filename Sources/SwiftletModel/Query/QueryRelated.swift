//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
 

//MARK: - Related Entities Query


public extension Query {
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> Queries<Child> {
        
        Queries(context: context) {
            related(keyPath)
        }
    }
}

public extension Query {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
        
    ) -> Query<Child>? {
        context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .first
            .flatMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
}

extension Query {
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Child>] {
        context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
}

//MARK: - Related Entities Collection Query

extension Collection {
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> [Query<Child>]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> [Query<Child>]
    
    where Element == Query<Entity> {
        compactMap { $0.related(keyPath) }.flatMap { $0 }
    }
}

public extension Queries {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Queries<Child> {
        
        whenResolved {
            $0.related(keyPath)
        }
    }
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Queries<Child> {
       
        whenResolved {
            $0.related(keyPath)
        }
    }
}
