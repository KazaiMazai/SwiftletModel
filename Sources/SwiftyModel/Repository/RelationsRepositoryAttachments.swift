//
//  File.swift
//
//
//  Created by Sergey Kazakov on 12/07/2024.
//

import Foundation

extension RelationsRepository {
    mutating func saveRelation<Parent: EntityModel, Child, Cardinality, Constraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>) {
            
            saveAttachment(attached(entity, keyPath))
        }
}

extension RelationsRepository {
    mutating func removeRelation<Parent: EntityModel, Child, Cardinality, Constraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>)  {
            
            saveAttachment(detached(entity, keyPath))
        }
    
    mutating func removeRelation<Parent, Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>)  {
            
            saveAttachment(detached(entity, keyPath, inverse: inverse))
        }
}

extension RelationsRepository {
    
    mutating func saveRelation<Parent, Child, Constaint, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Parent, InverseConstraint>>) {
            
            addRelation(entity, keyPath, inverse: inverse)
        }
    
    mutating func saveRelation<Parent, Child, Constaint, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Parent, InverseConstraint>>) {
            
            addRelation(entity, keyPath, inverse: inverse)
        }
    
    mutating func saveRelation<Parent, Child, Constaint, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Parent, InverseConstraint>>){
            
            addRelation(entity, keyPath, inverse: inverse)
        }
    
    mutating func saveRelation<Parent, Child, Constaint, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Parent, InverseConstraint>>) {
            
            addRelation(entity, keyPath, inverse: inverse)
        }
}

fileprivate extension RelationsRepository {
    
    mutating func addRelation<Parent, Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>) {
            
            saveAttachment(attached(entity, keyPath, inverse: inverse))
        }
}

fileprivate extension EntityModel {
    func children<Child, Direction, Cardinality, Constraint>(_ keyPath: KeyPath<Self, Relation<Child, Direction, Cardinality, Constraint>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}

fileprivate extension RelationsRepository {
    func detached<Parent, Child, Cardinality, Constraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> EntitiesAttachment<Parent, Child> {
        
        EntitiesAttachment(
            parent: entity.id,
            children: entity.children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func detached<Parent, Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesAttachment<Parent, Child> {
        
        EntitiesAttachment(
            parent: entity.id,
            children: entity.children(keyPath),
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

extension RelationsRepository {
    func attached<Parent, Child, Cardinality, Constraint>(_ entity: Parent,
                                                        _ keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>
                                                        
    ) -> EntitiesAttachment<Parent, Child> {
        
        EntitiesAttachment(
            parent: entity.id,
            children: entity.children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: entity[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: nil
        )
    }
}


fileprivate extension RelationsRepository {
    
    func attached<Parent, Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entity: Parent,
        _ keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesAttachment<Parent, Child> {
        
        EntitiesAttachment(
            parent: entity.id,
            children: entity.children(keyPath),
            direct: AttachmentAttribute(
                name: keyPath.relationName,
                updateOption: entity[keyPath: keyPath].directLinkSaveOption
            ),
            inverse: AttachmentAttribute(
                name: inverse.relationName,
                updateOption: entity[keyPath: keyPath].inverseLinkSaveOption
            )
        )
    }
}
