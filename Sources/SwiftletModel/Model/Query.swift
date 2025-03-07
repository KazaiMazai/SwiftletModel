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

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

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

public extension Query {
    func with(_ nested: NestedQuery) -> Query<Entity> {
        Entity.nestedQuery(nested, query: self)
    }
}
 
public extension Collection {
    func with<Entity>(_ nested: NestedQuery) -> [Query<Entity>] where Element == Query<Entity> {
        map { $0.with(nested) }
    }
}

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
