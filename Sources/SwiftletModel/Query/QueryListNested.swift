//
//  QueryCollectionNested.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryModifier<Child> = { $0 }) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, fragment: false, lazy: lazy, nested: nested) }
        }
    }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryListModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, slice: false, fragment: false, lazy: lazy, nested: nested) }
        }
    }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryListModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, slice: true, fragment: false, lazy: lazy, nested: nested) }
        }
    }
}

// MARK: - Nested Fragment Collection

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, fragment: true, lazy: lazy, nested: nested) }
        }
    }

    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryListModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, slice: false, fragment: true, lazy: lazy, nested: nested) }
        }
    }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        lazy: Bool = false,
        nested: @escaping QueryListModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.with(keyPath, slice: true, fragment: true, lazy: lazy, nested: nested) }
        }
    }
}
 

// MARK: - Nested Ids Collection

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.id(keyPath) }
        }
    }

    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.id(keyPath) }
        }
    }

    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>
    ) -> QueryList<Entity> {

        then { _, queries in
            queries.map { $0.id(slice: keyPath) }
        }
    }
}
