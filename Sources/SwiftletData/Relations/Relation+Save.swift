//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

//MARK: - Save Relations and Attached Entities

public extension EntityModel {
    func save<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        to repository: inout Repository) throws {
            
        try saveEntity(at: keyPath, in: &repository)
        saveRelation(at: keyPath, in: &repository)
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository) throws {
            
        try saveEntity(at: keyPath, in: &repository)
        saveRelation(at: keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) throws {
            
        try saveEntity(at: keyPath, in: &repository)
        saveRelation(at: keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) throws {
            
        try saveEntity(at: keyPath, in: &repository)
        saveRelation(at: keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository) throws {
            
        try saveEntity(at: keyPath, in: &repository)
        saveRelation(at: keyPath, inverse: inverse, in: &repository)
    }
}

//MARK: -  Private

private extension EntityModel {

    func saveRelation<Child, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
        repository.save(links(relationIds(keyPath), keyPath))
    }
    
    func saveRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        at keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository) {
            
        let children = relationIds(keyPath)
        switch relation(keyPath).directLinkSaveOption {
        case .append:
            repository.save(links(children, keyPath, inverse: inverse))
        case .replace, .remove:
            let enititesToKeep = Set(children)
            let oddExisingChildren = repository
                .findChildren(for: Self.self, relationName: keyPath.name, id: id)
                .compactMap { Child.ID($0) }
                .filter { !enititesToKeep.contains($0) }
            
            repository.save(removeLinks(oddExisingChildren, keyPath, inverse: inverse))
            repository.save(links(children, keyPath, inverse: inverse))
        }
    }
}

private extension EntityModel {
    func saveEntity<Child, Directionality, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        in repository: inout Repository) throws {
            
        try relation(keyPath).save(&repository)
    }
}
 
private extension EntityModel {
    func links<Child, Cardinality, Constraint>(
        _ children: [Child.ID],
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: [Link(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.name,
                    updateOption: relation(keyPath).directLinkSaveOption
                )
            )],
            inverse: []
        )
    }

    func links<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
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
                    updateOption: relation(keyPath).directLinkSaveOption
                )
            )],
            inverse: children.map { child in
                Link(
                    parent: child,
                    children: [id],
                    attribute: LinkAttribute(
                        name: inverse.name,
                        updateOption: relation(keyPath).inverseLinkSaveOption
                    )
                )
            }
        )
    }
}
