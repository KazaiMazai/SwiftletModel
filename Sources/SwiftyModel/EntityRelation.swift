//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension EntityModel {
    func relation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        EntitiesAttachment(
            parent: id,
            children: children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: nil
        )
    }
}

typealias MutualRelation<T: EntityModel, Relation: RelationProtocol, Constraint> = Relationship<T, Bidirectional, Relation, Constraint>

typealias OneWayRelation<T: EntityModel, Relation: RelationProtocol, Constraint> = Relationship<T, Unidirectional, Relation, Constraint>


fileprivate extension EntityModel {
    
    func saveRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        EntitiesAttachment(
            parent: id,
            children: children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: AttachmentAttribute(
                name: inverse.relationName,
                updateOption: self[keyPath: keyPath].inverseLinkSaveOption
            )
        )
    }
}

extension EntityModel {
    func removeRelation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        EntitiesAttachment(
            parent: id,
            children: children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func removeRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        EntitiesAttachment(
            parent: id,
            children: children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: AttachmentAttribute(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
}

fileprivate extension EntityModel {
    func children<Child, Direction, Relation, Optionality>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation, Optionality>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}


typealias ManyToOneRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToOneRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToManyRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>

typealias ManyToManyRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>
 
extension EntityModel {
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>

    ) -> EntitiesAttachment<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesAttachment<Self, Child> {
        
        saveRelation(keyPath, inverse: inverse)
    }
}
