//
//  QueryCollectionNested.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, fragment: false, nested: nested) }
        }
    }

    func with<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }
    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, slice: false, fragment: false, nested: nested) }
        }
    }

    func with<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, slice: true, fragment: false, nested: nested) }
        }
    }
}

// MARK: - Nested Fragment Collection

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryModifier<Child> = { $0 }

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, fragment: true, nested: nested) }
        }
    }

    func fragment<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, slice: false, fragment: true, nested: nested) }
        }
    }

    func fragment<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>,
        nested: @escaping QueryListModifier<Child> = { $0 }

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.with(keyPath, slice: true, fragment: true, nested: nested) }
        }
    }
}

// MARK: - Nested Ids Collection

public extension ContextQuery where Result == [Query<Entity>], Key == Void {
    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToOneRelation<Child, Directionality, Constraints>>

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.id(keyPath) }
        }
    }

    func id<Child, Directionality, Constraints>(
        _ keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.id(keyPath) }
        }
    }

    func id<Child, Directionality, Constraints>(
        slice keyPath: WritableKeyPath<Entity, ToManyRelation<Child, Directionality, Constraints>>

    ) -> QueryList<Entity> {

        whenResolved {
            $0.map { $0.id(slice: keyPath) }
        }
    }
}
