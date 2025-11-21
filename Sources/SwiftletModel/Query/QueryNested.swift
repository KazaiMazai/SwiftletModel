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

            with(keyPath, fragment: false, lazy: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,

        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: false, lazy: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: false, lazy: false, nested: nested)
        }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: false, lazy: false, nested: nested)
        }
}

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func lazy<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: false, lazy: true, nested: nested)
        }

    func lazy<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,

        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: false, lazy: true, nested: nested)
        }

    func lazy<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: false, lazy: true, nested: nested)
        }

    func lazy<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: false, lazy: true, nested: nested)
        }
}

// MARK: - Nested Fragment Query

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, lazy: false, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: true, lazy: false, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: true, lazy: false, nested: nested)
        }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, lazy: false, nested: nested)
    }
}

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func lazyFragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, lazy: true, nested: nested)
        }

    func lazyFragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: false, fragment: true, lazy: true, nested: nested)
        }

    func lazyFragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }) -> Self {

            with(keyPath, slice: true, fragment: true, lazy: true, nested: nested)
        }

    func lazyFragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            with(keyPath, fragment: true, lazy: true, nested: nested)
    }
}

// MARK: - Query Nested Ids

public extension ContextQuery where Result == Entity?, Key == Entity.ID {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>) -> Self {

            then { context, entity in
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
        lazy: Bool,
        nested: @escaping QueryModifier<Child> = { $0 }) -> Self {

            then { context, entity in
                var entity = entity
                if lazy {
                    entity[keyPath: keyPath] =
                        .relation({ nested(related(keyPath)).resolve(in: context) }, fragment: fragment)
                } else {
                    let resolvedRelated = nested(related(keyPath)).resolve(in: context)
                    entity[keyPath: keyPath] =
                        .relation({ resolvedRelated }, fragment: fragment)
                }
                
                return entity
            }
        }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool,
        fragment: Bool,
        lazy: Bool,
        nested: @escaping QueryListModifier<Child>) -> Self {

            then { context, entity in
                var entity = entity
                if lazy {
                    entity[keyPath: keyPath] = slice ?
                        .appending({ nested(related(keyPath)).resolve(in: context) }, fragment: fragment) :
                        .relation({ nested(related(keyPath)).resolve(in: context) }, fragment: fragment)
                } else {
                    let resolvedRelated = nested(related(keyPath)).resolve(in: context)
                    entity[keyPath: keyPath] = slice ?
                        .appending({ resolvedRelated }, fragment: fragment) :
                        .relation({ resolvedRelated }, fragment: fragment)
                }
              
                return entity
            }
        }

    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        slice: Bool) -> Self {

            then { context, entity in
                var entity = entity
                let ids = queryRelated(in: context, keyPath).compactMap { $0.id(context) }
                entity[keyPath: keyPath] = slice ? .appending(ids: ids) : .ids(ids)
                return entity
            }
        }
}
