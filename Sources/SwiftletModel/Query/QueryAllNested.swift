//
//  QueryAllNested.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

// MARK: - All Nested Entities Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func with(_ nested: Nested...) -> Query<Entity> {
        with(nested)
    }

    func with(_ nested: [Nested]) -> Query<Entity> {
        Entity.nestedQueryModifier(self, nested: nested)
    }
}

// MARK: - All Nested Entities Collection Query

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func with(_ nested: Nested...) -> QueryList<Entity> {
        with(nested)
    }

    func with(_ nested: [Nested]) -> QueryList<Entity> {
        then { context, queries in
            queries.map { $0.with(nested) }
        }
    }
}
