//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

//MARK: - Detach Relations

public extension EntityModel {
    func detach<Child, Cardinality, Constraint>(
        all keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
        let children = repository
            .findChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            
        detach(children, relation: keyPath, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        all keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
        let children = repository
            .findChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }
            
        detach(children, relation: keyPath, inverse: inverse, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
        detach(relationIds(keyPath), relation: keyPath, in: &repository)
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
        detach(relationIds(keyPath), relation: keyPath, inverse: inverse, in: &repository)
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
            
        repository.save(removeLinks(entities, keyPath))
    }
    
    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
        repository.save(removeLinks(entities, keyPath, inverse: inverse))
    }
}

extension EntityModel {
    func removeLinks<Child, Cardinality, Constraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: [Link(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.name,
                    updateOption: .remove
                )
            )],
            inverse: []
        )
    }
    
    func removeLinks<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: [Link(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.name,
                    updateOption: .remove
                )
            )],
            inverse: children.map { child in
                Link(
                    parent: child,
                    children: [id],
                    attribute: LinkAttribute(
                        name: inverse.name,
                        updateOption: .remove
                    )
                )
            }
        )
    }
}
