//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation


enum KeyPaths {
    
}

extension KeyPaths {
    enum Relation { }
    
    enum MutualRelation { }
    
    enum AnyRelation { }
}

extension KeyPaths.Relation {
     
    typealias ToManyOptional<Parent, Child: IdentifiableEntity> = KeyPath<Parent, [Relation<Child>]?>

    typealias ToMany<Parent, Child: IdentifiableEntity> = KeyPath<Parent, [Relation<Child>]>

    typealias ToOne<Parent, Child: IdentifiableEntity> = KeyPath<Parent, Relation<Child>>

    typealias ToOneOptional<Parent, Child: IdentifiableEntity> = KeyPath<Parent, Relation<Child>?>
}

extension KeyPaths.MutualRelation {
     
    typealias ToManyOptional<Parent, Child: IdentifiableEntity> = KeyPath<Parent, [MutualRelation<Child>]?>

    typealias ToMany<Parent, Child: IdentifiableEntity> = KeyPath<Parent, [MutualRelation<Child>]>

    typealias ToOne<Parent, Child: IdentifiableEntity> = KeyPath<Parent, MutualRelation<Child>>

    typealias ToOneOptional<Parent, Child: IdentifiableEntity> = KeyPath<Parent, MutualRelation<Child>?>
}

extension IdentifiableEntity {
    func relation<E>(_ keyPath: KeyPaths.Relation.ToManyOptional<Self, E>,
                     replace: Bool = true) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .append
            ),
            inverse: nil
        )
    }
    
    func relation<E>(_ keyPath: KeyPaths.Relation.ToOneOptional<Self, E>,
                     replace: Bool = true) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .replaceIfNotEmpty
            ),
            inverse: nil
        )
    }
    
    func relation<E>(_ keyPath: KeyPaths.MutualRelation.ToOneOptional<Self, E>,
                     replace: Bool = true,
                     inverse: KeyPaths.MutualRelation.ToOneOptional<Self, E>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .replaceIfNotEmpty
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .replace
            )
        )
    }
    
    func relation<E>(_ keyPath: KeyPaths.MutualRelation.ToOneOptional<Self, E>,
                     replace: Bool = true,
                     inverse: KeyPaths.MutualRelation.ToManyOptional<E, Self>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .replaceIfNotEmpty
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .append
            )
        )
    }
    
    func relation<E>(_ keyPath: KeyPaths.MutualRelation.ToManyOptional<Self, E>,
                     replace: Bool = true,
                     inverse: KeyPaths.MutualRelation.ToOneOptional<E, Self>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .append
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .replace
            )
        )
    }
    
    func relation<E>(_ keyPath: KeyPaths.MutualRelation.ToManyOptional<Self, E>,
                     replace: Bool = true,
                     inverse: KeyPaths.MutualRelation.ToManyOptional<E, Self>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .append
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .append
            )
        )
    }
}


extension IdentifiableEntity {
    func removeRelation<E>(_ keyPath: KeyPath<Self, [Relation<E>]?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPath<Self, Relation<E>?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPaths.MutualRelation.ToOneOptional<Self, E>,
                           inverse: KeyPaths.MutualRelation.ToOneOptional<E, Self>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPaths.MutualRelation.ToOneOptional<Self, E>,
                           inverse: KeyPaths.MutualRelation.ToManyOptional<E, Self>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPaths.MutualRelation.ToManyOptional<Self, E>,
                           inverse: KeyPaths.MutualRelation.ToOneOptional<E, Self>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPaths.MutualRelation.ToManyOptional<Self, E>,
                           inverse: KeyPaths.MutualRelation.ToManyOptional<E, Self>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
}

fileprivate extension IdentifiableEntity {
    func children<Child, RelationType>(_ keyPath: KeyPath<Self, [RelatedEntity<Child, RelationType>]?>) -> [Child.ID] {
        self[keyPath: keyPath]?.compactMap { $0.id } ?? []
    }
    
    func children<Child, RelationType>(_ keyPath: KeyPath<Self, RelatedEntity<Child, RelationType>?>) -> [Child.ID] {
        [self[keyPath: keyPath]].compactMap { $0?.id }
    }
    
    func children<Child, RelationType>(_ keyPath: KeyPath<Self, [RelatedEntity<Child, RelationType>]>) -> [Child.ID] {
        self[keyPath: keyPath].compactMap { $0.id }
    }
    
    func children<Child, RelationType>(_ keyPath: KeyPath<Self, RelatedEntity<Child, RelationType>>) -> [Child.ID] {
        [self[keyPath: keyPath]].map { $0.id }
    }
}
