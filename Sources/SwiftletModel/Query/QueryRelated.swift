//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
 

//MARK: - Related Entities Query


public extension LazyQuery where QueryResult == Optional<Entity>, Metadata == Entity.ID {
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> Queries<Child> {
        
        Queries(context: context) {
            queryRelated(keyPath)
        }
    }
}

public extension LazyQuery where QueryResult == Optional<Entity>, Metadata == Entity.ID {
    
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

extension LazyQuery where QueryResult == Optional<Entity>, Metadata == Entity.ID {
    func queryRelated<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Child>] {
        context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
}

//MARK: - Related Entities Collection Query

public extension LazyQuery where QueryResult == [Query<Entity>], Metadata == Void {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Queries<Child> {
       
        whenResolved {
            $0.compactMap { $0.queryRelated(keyPath) }.flatMap { $0 }
        }
    }
}
