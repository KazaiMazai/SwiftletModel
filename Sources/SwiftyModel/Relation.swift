//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func relation<Child, Relation>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation>>,
        replace: Bool = true
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: nil
        )
    }
    
    func relation<Child, Relation>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation>?>,
        replace: Bool = true
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: nil
        )
    }
    
    func relation<Child, Relation, InverseRelation>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation>>,
        replace: Bool = true,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: InverseRelation.inverseLinkOption()
            )
        )
    }
    
    func relation<Child, Relation, InverseRelation>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation>?>,
        replace: Bool = true,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation>?>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: InverseRelation.inverseLinkOption()
            )
        )
    }
}

extension IdentifiableEntity {
    func removeRelation<Child, Relation>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation>>
        
    ) -> EntitiesLink<Self, Child> {
        
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
    
    func removeRelation<Child, Relation>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation>?>
        
    ) -> EntitiesLink<Self, Child> {
        
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
    
    func removeRelation<Child, Relation, InverseRelation>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation>>
        
    ) -> EntitiesLink<Self, Child> {
        
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
    
    func removeRelation<Child, Relation, InverseRelation>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation>?>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation>?>
        
    ) -> EntitiesLink<Self, Child> {
        
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

fileprivate extension RelationProtocol {
    static func directLinkOption(_ replace: Bool) -> Option {
        let append: Option = isCollection ? .append : .replaceIfNotEmpty
        return replace ? .replace : append
    }
    
    static func inverseLinkOption() -> Option {
        isCollection ? .append : .replace
    }
}

fileprivate extension IdentifiableEntity {
    func children<Child, Direction, Relation>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation>?>) -> [Child.ID] {
        self[keyPath: keyPath]?.ids ?? []
    }
    
    func children<Child, Direction, Relation>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}
