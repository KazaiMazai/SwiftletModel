//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
 

//MARK: - Related Entities Query


public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> QueryGroup<Child> {
        
        QueryGroup(context: context) {
            queryRelated(keyPath)
        }
    }
}

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
        
    ) -> Query<Child> {
        
        guard let id = id else {
            return .none(in: context)
        }
        
        return Query(context: context) { context in
            context.getChildren(for: Entity.self, relationName: keyPath.name, id: id)
                .first
                .flatMap { Child.ID($0) }
        }
    }
}

extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    func queryRelated<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Child>] {
        
        guard let id = id else {
            return []
        }
        
        return context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
}

//MARK: - Related Entities Collection Query

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> QueryGroup<Child> {
       
        whenResolved {
            $0.compactMap { $0.queryRelated(keyPath) }.flatMap { $0 }
        }
    }
}
