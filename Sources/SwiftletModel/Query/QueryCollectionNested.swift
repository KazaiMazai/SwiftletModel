//
//  QueryCollectionNested.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

public extension Collection {
    func with<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> [Query<Entity>] where Element == Query<Entity> {
            
            map { $0.with(keyPath, fragment: false, nested: nested) }
        }
    
    func with<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.with(keyPath, slice: false, fragment: false, nested: nested) }
    }
    
    func with<Entity, Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.with(keyPath, slice: true, fragment: false, nested: nested) }
    }
}


//MARK: - Nested Fragment Collection

public extension Collection {
    func fragment<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.with(keyPath, fragment: true, nested: nested) }
    }
    
    func fragment<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.with(keyPath, slice: false, fragment: true, nested: nested) }
    }
    
    func fragment<Entity, Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.with(keyPath, slice: true, fragment: true, nested: nested) }
    }
}

//MARK: - Nested Ids Collection

public extension Collection {
    func id<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.id(keyPath) }
    }
    
    func id<Entity, Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.id(keyPath) }
    }
    
    func id<Entity, Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Entity>] where Element == Query<Entity> {
        
        map { $0.id(slice: keyPath) }
    }
}
