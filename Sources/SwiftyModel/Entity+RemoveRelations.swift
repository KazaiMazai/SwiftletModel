//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

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

fileprivate extension EntityModel {
    func removeLink<Child, Cardinality, Constraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: StoredLink(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.relationName,
                    updateOption: .remove
                )
            ),
            inverse: []
        )
    }
    
    func removeLink<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: StoredLink(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.relationName,
                    updateOption: .remove
                )
            ),
            inverse: children.map { child in
                StoredLink(
                    parent: child,
                    children: [id],
                    attribute: LinkAttribute(
                        name: inverse.relationName,
                        updateOption: .remove
                    )
                )
            }
        )
    }
}
