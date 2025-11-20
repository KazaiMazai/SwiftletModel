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

        QueryList { context in
            queryRelated(in: context, keyPath)
        }
    }
}

public extension ContextQuery where Result == Entity?, Key == Entity.ID {

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>

    ) -> Query<Child> {

        Query { context in
            guard let id = id(context) else {
                return nil
            }

            return Link<Entity, Child>.findChildrenOf(
                id, with: keyPath,
                in: context
            )
            .first
        }
    }
}

extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func queryRelated<Child, Directionality, Constraints>(
        in context: Context,
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>

    ) -> [Query<Child>] {

        guard let id = id(context) else {
            return []
        }

        return Link<Entity, Child>.findChildrenOf(
            id, with: keyPath,
            in: context
        )
        .map { Query<Child>(id: $0) }
    }
}

// MARK: - Related Entities Collection Query

public extension ContextQuery where Result == [Query<Entity>], Key == Void {

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> QueryGroup<Child> {

        then { context, queries in
            queries.map { $0.queryRelated(in: context, keyPath) }
        }
    }

    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> QueryList<Child> {

            then { context, queries in
                queries.map { $0.related(keyPath) }
            }
    }
}
