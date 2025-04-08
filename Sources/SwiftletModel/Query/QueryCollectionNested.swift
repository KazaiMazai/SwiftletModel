//
//  QueryCollectionNested.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 02/04/2025.
//

extension Collection {
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

public extension Queries {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Queries<Entity>  {
            
        whenResolved {
            $0.with(keyPath, nested: nested)
        }
    }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }  
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.with(keyPath, nested: nested)
        }
    }
    
    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.with(slice: keyPath, nested: nested)
        }
    }
}


//MARK: - Nested Fragment Collection

extension Collection {
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

public extension Queries {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.fragment(keyPath, nested: nested)
        }
    }
    
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.fragment(keyPath, nested: nested)
        }
    }
    
    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.fragment(slice: keyPath, nested: nested)
        }
    }
}

//MARK: - Nested Ids Collection

extension Collection {
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

public extension Queries {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.id(keyPath)
        }
    }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.id(keyPath)
        }
    }
    
    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> Queries<Entity> {
        
        whenResolved {
            $0.id(slice: keyPath)
        }
    }
}
