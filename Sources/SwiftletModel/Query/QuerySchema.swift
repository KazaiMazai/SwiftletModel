//
//  QuerySchema.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 22/04/2025.
//

public extension ContextQuery where Result == Optional<Entity>, Key == Entity.ID {
    static func schemaQuery(in context: Context) -> Query<Entity> {
        Query.none(in: context)
    }
}

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    static func schemaQuery(in context: Context) -> QueryList<Entity> {
        Entity.query(in: context)
            .sorted(by: .updatedAt)
    }
}
