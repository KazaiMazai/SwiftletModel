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
}


typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Bidirectional, Relation, Constraint.Optional>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol> = Relationship<T, Unidirectional, Relation, Constraint.Optional>


fileprivate extension IdentifiableEntity {
    
    func saveRelation<Child, Relation, InverseRelation>(
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
    func children<Child, Direction, Relation, Optionality>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation, Optionality>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}
 

extension IdentifiableEntity {
    
    func relation<Child>(
        _ keyPath: KeyPath<Self, OneToMany<Child>>,
        replace: Bool = true,
        inverse: KeyPath<Child, ManyToOne<Self>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child>(
        _ keyPath: KeyPath<Self, ManyToOne<Child>>,
        replace: Bool = true,
        inverse: KeyPath<Child, OneToMany<Self>>

    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child>(
        _ keyPath: KeyPath<Self, ManyToMany<Child>>,
        replace: Bool = true,
        inverse: KeyPath<Child, ManyToMany<Self>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child>(
        _ keyPath: KeyPath<Self, OneToOne<Child>>,
        replace: Bool = true,
        inverse: KeyPath<Child, OneToOne<Self>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
}
