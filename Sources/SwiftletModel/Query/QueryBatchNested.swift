//
//  QueryBatchNested.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//


//MARK: - Nested Entities Batch Query

public extension Lazy where Result == Optional<Entity>, Metadata == Entity.ID {
    func with(_ nested: Nested...) -> Query<Entity> {
        with(nested)
    }
    
    func with(_ nested: [Nested]) -> Query<Entity> {
        Entity.nestedQueryModifier(self, nested: nested)
    }
}

//MARK: - Nested Entities Batch Collection Query

extension Collection {
    func with<Entity>(_ nested: Nested...) -> [Query<Entity>] where Element == Query<Entity> {
        with(nested)
    }
    
    func with<Entity>(_ nested: [Nested]) -> [Query<Entity>] where Element == Query<Entity> {
        map { $0.with(nested) }
    }
}

public extension Lazy where Result == [Query<Entity>], Metadata == Void {
    func with(_ nested: Nested...) -> Queries<Entity> {
        with(nested)
    }
    
    func with(_ nested: [Nested]) -> Queries<Entity> {
        whenResolved { queries in
            queries.map { $0.with(nested) }
        }
    }
}

 
 
