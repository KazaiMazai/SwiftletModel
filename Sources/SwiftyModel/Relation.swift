//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation


extension IdentifiableEntity {
    func relation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: nil
        )
    }
}

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol, Constraint> = Relationship<T, Bidirectional, Relation, Constraint>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol, Constraint> = Relationship<T, Unidirectional, Relation, Constraint>


fileprivate extension IdentifiableEntity {
    
    func saveRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: self[keyPath: keyPath].inverseLinkSaveOption
            )
        )
    }
}

extension IdentifiableEntity {
    func removeRelation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>
        
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
    
    func removeRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
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

fileprivate extension IdentifiableEntity {
    func children<Child, Direction, Relation, Optionality>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation, Optionality>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}


typealias ManyToOneRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToOneRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToManyRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>

typealias ManyToManyRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>
 
extension IdentifiableEntity {
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>

    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
}
