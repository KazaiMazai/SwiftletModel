//
//  File.swift
//
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation


//MARK: - Save Relation and Attached Entities

public extension EntityModel {
    func save<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        to repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(attachmentLink(keyPath))
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(attachmentLink(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(attachmentLink(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(keyPath, &repository)
            repository.save(attachmentLink(keyPath, inverse: inverse))
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository){
            
            saveEntity(keyPath, &repository)
            repository.save(attachmentLink(keyPath, inverse: inverse))
    }
}

//MARK: - Detach Relation

public extension EntityModel {
    func detach<Child, Cardinality, Constraint>(
        all keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            let children = repository
                .findRelations(for: Self.self, relationName: keyPath.relationName, id: id)
                .compactMap { Child.ID($0) }
            
            detach(children, relation: keyPath, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        all keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
            let children = repository
                .findRelations(for: Self.self, relationName: keyPath.relationName, id: id)
                .compactMap { Child.ID($0) }
            
            detach(children, relation: keyPath, inverse: inverse, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            detach(children(keyPath), relation: keyPath, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
            detach(children(keyPath), relation: keyPath, inverse: inverse, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            detach(entities, relation: keyPath, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
            detach(entities, relation: keyPath, inverse: inverse, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            repository.save(removeLink(entities, keyPath))
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
            repository.save(removeLink(entities, keyPath, inverse: inverse))
    }
}

//MARK: -  Private

fileprivate extension EntityModel {
    func saveEntity<Child, Directionality, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        _ repository: inout Repository) {
            
            self[keyPath: keyPath].save(&repository)
    }
}
 
fileprivate extension EntityModel {
    func attachmentLink<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Link<Self, Child> {
        
        Link(parent: id,
             children: children(keyPath),
             direct: LinkAttribute(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
             ),
             inverse: nil
        )
    }

    func attachmentLink<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> Link<Self, Child> {
        
        Link(parent: id,
             children: children(keyPath),
             direct: LinkAttribute(
                name: keyPath.relationName,
                updateOption: self[keyPath: keyPath].directLinkSaveOption
             ),
             inverse: LinkAttribute(
                name: inverse.relationName,
                updateOption: self[keyPath: keyPath].inverseLinkSaveOption
             )
        )
    }
}

extension EntityModel {
    func removeLink<Child, Cardinality, Constraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Link<Self, Child> {
        
        Link(parent: id,
             children: children,
             direct: LinkAttribute(
                name: keyPath.relationName,
                updateOption: .remove
             ),
             inverse: nil
        )
    }
    
    func removeLink<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> Link<Self, Child> {
        
        Link(parent: id,
             children: children,
             direct: LinkAttribute(
                name: keyPath.relationName,
                updateOption: .remove
             ),
             inverse: LinkAttribute(
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
