//
//  QuerySchema.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 22/04/2025.
//

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    static func schemaQuery() -> Query<Entity> {
        Query.none
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    static func schemaQuery() -> QueryList<Entity> {
        Entity.query().sorted(by: .updatedAt)
    }
}
