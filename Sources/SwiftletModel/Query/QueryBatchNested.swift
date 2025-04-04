//
//  QueryBatchNested.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//


//MARK: - Nested Entities Batch Query

public extension Query {
    func with(_ nested: Nested...) -> Query<Entity> {
        with(nested)
    }
    
    func with(_ nested: [Nested]) -> Query<Entity> {
        Entity.nestedQueryModifier(self, nested: nested)
    }
}

//MARK: - Nested Entities Batch Collection Query

public extension Collection {
    func with<Entity>(_ nested: Nested...) -> [Query<Entity>] where Element == Query<Entity> {
        with(nested)
    }
    
    func with<Entity>(_ nested: [Nested]) -> [Query<Entity>] where Element == Query<Entity> {
        map { $0.with(nested) }
    }
}