//
//  File.swift
//
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation



fileprivate extension EntityModel {
    func saveEntity<Child, Directionality, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        _ repository: inout Repository) {
            
            self[keyPath: keyPath].save(&repository)
    }
}


public extension EntityModel {
    func save<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        _ repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(relation(keyPath))
    }
}

public extension EntityModel {
    func removeRelation<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        _  repository: inout Repository) {
            
            repository.save(removeRelation(keyPath))
    }
    
    func removeRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        _  repository: inout Repository)  {
            
            repository.save(removeRelation(keyPath, inverse: inverse))
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        _  repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(relation(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        _  repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(relation(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        _  repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(relation(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        _  repository: inout Repository){
            
            saveEntity(keyPath, &repository)
            repository.save(relation(keyPath, inverse: inverse))
    }
}


//MARK: -  Private


fileprivate extension EntityModel {
    func relation<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
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


fileprivate extension EntityModel {
    
    func saveRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
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
    func removeRelation<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
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
    
    func removeRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
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
    func children<Child, Direction, Cardinality, Constraint>(_ keyPath: KeyPath<Self, Relation<Child, Direction, Cardinality, Constraint>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}

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

