//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation

// MARK: - Related Entities Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> QueryList<Child> {

        QueryList(context: context) {
            queryRelated(keyPath)
        }
    }
}

public extension ContextQuery where Result == Entity?, Key == Entity.ID {

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>

    ) -> Query<Child> {

        Query(context: context) { context in
            guard let id = id else {
                return nil
            }
            
            return StoredRelations<Entity, Child>.queryChildren(
                of: id,
                keyPath: keyPath,
                in: context
            )
            .first
        }
    }
}

extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func queryRelated<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>

    ) -> [Query<Child>] {

        guard let id = id else {
            return []
        }
        
        return StoredRelations<Entity, Child>.queryChildren(
            of: id,
            keyPath: keyPath,
            in: context
        )
        .map { Query<Child>(context: context, id: $0) }
    }
}

// MARK: - Related Entities Collection Query

public extension ContextQuery where Result == [Query<Entity>], Key == Void {

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> QueryGroup<Child> {

        whenResolved {
            $0.map { $0.queryRelated(keyPath) }
        }
    }

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> QueryList<Child> {

            whenResolved {
                $0.map { $0.related(keyPath) }
            }
    }
}
