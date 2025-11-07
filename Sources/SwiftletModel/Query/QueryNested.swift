//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation

public typealias QueryModifier<T: EntityModelProtocol> = (Query<T>) -> Query<T>

public typealias QueryListModifier<T: EntityModelProtocol> = (QueryList<T>) -> QueryList<T>

// MARK: - Nested Entity Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,

        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: false, nested: nested)
        }
}

// MARK: - Nested Fragment Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: true, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: true, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, nested: nested)
    }
}

// MARK: - Query Nested Ids

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Self {

            whenResolved { context, entity in
                var entity = entity
                entity[keyPath: keyPath] = related(keyPath)
                    .id(context)
                    .map { .id($0)} ?? .none
                return entity
            }
        }

    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Self {

            id(keyPath, slice: false)
        }

    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>) -> Self {

            id(keyPath, slice: true)
        }
}

// MARK: - Private Nested Queries

extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        fragment: Bool,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            whenResolved { context, entity in
                var entity = entity
                entity[keyPath: keyPath] = nested(related(keyPath))
                    .resolve(context)
                    .map { .relation($0, fragment: fragment) } ?? .none

                return entity
            }
        }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool,
        fragment: Bool,
        nested: @escaping QueryListModifier<Child>) -> Self {

            whenResolved { context, entity in
                var entity = entity
                let relatedEntities = nested(related(keyPath)).resolve(context)

                entity[keyPath: keyPath] = slice ?
                    .appending(relatedEntities, fragment: fragment) :
                    .relation(relatedEntities, fragment: fragment)
                return entity
            }
        }

    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool) -> Self {

            whenResolved { context, entity in
                var entity = entity
                let ids = queryRelated(in: context, keyPath).compactMap { $0.id(context) }
                entity[keyPath: keyPath] = slice ? .appending(ids: ids) : .ids(ids)
                return entity
            }
        }
}
