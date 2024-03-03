//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func relation<E>(_ keyPath: KeyPath<Self, [Relation<E>]?>,
                     replace: Bool = true) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: (self[keyPath: keyPath] ?? []).map { $0.id },
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .append
            ),
            inverse: nil
        )
    }
    
    func relation<E>(_ keyPath: KeyPath<Self, Relation<E>?>, replace: Bool = true) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
            direct: Link(
                name: keyPath.relationName,
                updateOption: replace ? .replace : .replaceIfNotEmpty
            ),
            inverse: nil
        )
    }
    
    func relation<E>(_ keyPath: KeyPath<Self, MutualRelation<E>?>,
                     replace: Bool = true,
                     inverse: KeyPath<E, MutualRelation<Self>?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
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
    
    func relation<E>(_ keyPath: KeyPath<Self, MutualRelation<E>?>,
                     replace: Bool = true,
                     inverse: KeyPath<E, [MutualRelation<Self>]?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
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
    
    func relation<E>(_ keyPath: KeyPath<Self, [MutualRelation<E>]?>,
                     replace: Bool = true,
                     inverse: KeyPath<E, MutualRelation<Self>?>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: self[keyPath: keyPath]?.compactMap { $0.id } ?? [],
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
    
    func relation<E>(_ keyPath: KeyPath<Self, [MutualRelation<E>]?>,
                     replace: Bool = true,
                     inverse: KeyPath<E, [MutualRelation<Self>]?>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: self[keyPath: keyPath]?.compactMap { $0.id } ?? [],
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
            children: (self[keyPath: keyPath] ?? []).map { $0.id },
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
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func removeRelation<E>(_ keyPath: KeyPath<Self, MutualRelation<E>?>,
                           inverse: KeyPath<E, MutualRelation<Self>?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
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
    
    func removeRelation<E>(_ keyPath: KeyPath<Self, MutualRelation<E>?>,
                           inverse: KeyPath<E, [MutualRelation<Self>]?>) -> EntitiesLink<Self, E> {
        
        EntitiesLink(
            parent: id,
            children: [self[keyPath: keyPath]].compactMap { $0?.id },
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
    
    func removeRelation<E>(_ keyPath: KeyPath<Self, [MutualRelation<E>]?>,
                           inverse: KeyPath<E, MutualRelation<Self>?>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: self[keyPath: keyPath]?.compactMap { $0.id } ?? [],
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
    
    func removeRelation<E>(_ keyPath: KeyPath<Self, [MutualRelation<E>]?>,
                           inverse: KeyPath<E, [MutualRelation<Self>]?>) -> EntitiesLink<Self, E> {
        EntitiesLink(
            parent: id,
            children: self[keyPath: keyPath]?.compactMap { $0.id } ?? [],
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
