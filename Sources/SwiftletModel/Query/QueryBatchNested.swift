//
//  QueryBatchNested.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//


//MARK: - Nested Entities Batch Query

public extension Lazy where Result == Optional<Entity>, Key == Entity.ID {
    func with(_ nested: Nested...) -> Query<Entity> {
        with(nested)
    }
    
    func with(_ nested: [Nested]) -> Query<Entity> {
        Entity.nestedQueryModifier(self, nested: nested)
    }
}

//MARK: - Nested Entities Batch Collection Query

public extension Lazy where Result == [Query<Entity>], Key == Void {
    func with(_ nested: Nested...) -> QueryGroup<Entity> {
        with(nested)
    }
    
    func with(_ nested: [Nested]) -> QueryGroup<Entity> {
        whenResolved { queries in
            queries.map { $0.with(nested) }
        }
    }
}

 
 
