//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public struct Query<Entity: EntityModelProtocol> {
    typealias Resolver = () -> Entity?
    
    public let id: Entity.ID
    
    let context: Context
    let resolver: Resolver
    
    public init(context: Context, id: Entity.ID) {
        self.context = context
        self.id = id
        self.resolver = { context.find(id) }
    }
    
    public func resolve() -> Entity? {
        resolver()
    }
}

//MARK: - Related Entities Query

public extension Query {
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
        
    ) -> Query<Child>? {
        context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .first
            .flatMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
    
    func related<Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
        
    ) -> [Query<Child>] {
        context
            .getChildren(for: Entity.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            .map { Query<Child>(context: context, id: $0) }
    }
}

//MARK: - Related Entities Collection Query

public extension Collection {
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> [Query<Child>]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
    
    func related<Entity, Child, Directionality, Constraints>(
        _ keyPath: KeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> [[Query<Child>]]
    
    where Element == Query<Entity> {
        
        compactMap { $0.related(keyPath) }
    }
}

public typealias QueryModifier<T: EntityModelProtocol> = (Query<T>) -> Query<T>

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

//MARK: - Nested Entity Query

public extension Query {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: false, fragment: false, nested: nested)
        }
    
    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: true, fragment: false, nested: nested)
        }
}

//MARK: - Nested Fragment Query

public extension Query {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: false, fragment: true, nested: nested)
        }
    
    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            with(keyPath, slice: true, fragment: true, nested: nested)
        }
}

//MARK: - Query Nested Ids

public extension Query {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Query {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = related(keyPath)
                    .map { .id($0.id) } ?? .none
                return entity
            }
        }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Query {
            
            id(keyPath, slice: false)
        }
    
    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Query {
            
            id(keyPath, slice: true)
        }
}

//MARK: - Query Nested Entities Collection

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

//MARK: - Context Query Extension
extension Context {
    func query<Entity: EntityModelProtocol>(_ id: Entity.ID) -> Query<Entity> {
        Query(context: self, id: id)
    }
    
    func query<Entity: EntityModelProtocol>(_ ids: [Entity.ID]) -> [Query<Entity>] {
        ids.map { query($0) }
    }
    
    func query<Entity: EntityModelProtocol>() -> [Query<Entity>] {
        query(ids(Entity.self))
    }
}

//MARK: - Private Nested Queries

private extension Query {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        fragment: Bool,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Query {
            
            whenResolved {
                var entity = $0
                entity[keyPath: keyPath] = related(keyPath)
                    .map { nested($0) }
                    .flatMap { $0.resolve() }
                    .map { .relation($0, fragment: fragment) } ?? .none
                
                return entity
            }
        }
    
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool,
        fragment: Bool,
        nested: @escaping QueryModifier<Child>) -> Query {
            
            whenResolved {
                var entity = $0
                let relatedEntities = related(keyPath)
                    .map { nested($0) }
                    .compactMap { $0.resolve() }
                
                entity[keyPath: keyPath] = slice ?
                    .appending(relatedEntities, fragment: fragment) :
                    .relation(relatedEntities, fragment: fragment)
                return entity
            }
        }
    
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool) -> Query {
            
            whenResolved {
                var entity = $0
                let ids = related(keyPath).map { $0.id }
                entity[keyPath: keyPath] = slice ? .appending(ids: ids) : .ids(ids)
                return entity
            }
        }
}

//MARK: - Resolve Query Collection

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

//MARK: - Sorting

public extension Collection {
    func sorted<Entity, T>(by keyPath: KeyPath<Entity, T>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T: Comparable {
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<T>
            .query(.indexName(keyPath), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted(using: .keyPath(keyPath))
                .query(in: context) 
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1>(by kp0: KeyPath<Entity, T0>,
                                _ kp1: KeyPath<Entity, T1>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<Pair<T0, T1>>
            .query(.indexName(kp0, kp1), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted(using: .keyPath(kp0), .keyPath(kp1))
                .query(in: context) 
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1, T2>(by kp0: KeyPath<Entity, T0>,
                                    _ kp1: KeyPath<Entity, T1>,
                                    _ kp2: KeyPath<Entity, T2>) -> [Query<Entity>]
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable,
    T2: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        
        guard let index = SortIndex<Entity>.ComparableValue<Triplet<T0, T1, T2>>
            .query(.indexName(kp0, kp1, kp2), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted(using: .keyPath(kp0), .keyPath(kp1), .keyPath(kp2))
                .query(in: context) 
        }
        
        return sorted(using: index)
    }
    
    func sorted<Entity, T0, T1, T2, T3>(by kp0: KeyPath<Entity, T0>,
                                        _ kp1: KeyPath<Entity, T1>,
                                        _ kp2: KeyPath<Entity, T2>,
                                        _ kp3: KeyPath<Entity, T3>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T0: Comparable,
    T1: Comparable,
    T2: Comparable,
    T3: Comparable {
        
        guard let context = first?.context else {
            return Array(self)
        }
        guard let index = SortIndex<Entity>.ComparableValue<Quadruple<T0, T1, T2, T3>>
            .query(.indexName(kp0, kp1, kp2, kp3), in: context)
            .resolve()
        else {
            return self
                .resolve()
                .sorted(using: .keyPath(kp0), .keyPath(kp1), .keyPath(kp2), .keyPath(kp3))
                .query(in: context) 
        }
        
        return sorted(using: index)
    }
}

//MARK: - Private Sorting

private extension Collection {

    func sorted<Entity, T>(using index: SortIndex<Entity>.ComparableValue<T>) -> [Query<Entity>]
    
    where
    Element == Query<Entity>,
    T: Comparable {
        
        let queries = Dictionary(map { query in (query.id, query) }, uniquingKeysWith: { $1 })
        return index
            .sorted
            .compactMap { queries[$0] }
    }
}

//MARK: - Private Query extensions

private extension Query {
    
    init(context: Context, id: Entity.ID, resolver: @escaping () -> Entity?) {
        self.context = context
        self.id = id
        self.resolver = resolver
    }
    
    func whenResolved(then perform: @escaping (Entity) -> Entity?) -> Query<Entity> {
        Query(context: context, id: id) {
            guard let entity = resolve() else {
                return nil
            }
            
            return perform(entity)
        }
    }
}

