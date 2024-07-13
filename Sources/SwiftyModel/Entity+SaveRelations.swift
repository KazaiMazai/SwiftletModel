//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

//MARK: - Save Relation and Attached Entities

public extension EntityModel {
    func save<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        to repository: inout Repository) {
            
            saveEntity(at: keyPath, &repository)
            attach(keyPath, in: &repository)
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository){
            
            saveEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
}

//MARK: -  Private

private extension EntityModel {

    func attach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            repository.save(links(children(keyPath), keyPath))
        }
    
    func attach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository) {
            
            let children = children(keyPath)
            switch relationAt(keyPath).directLinkSaveOption {
            case .append:
                repository.save(links(children, keyPath, inverse: inverse))
            case .replace, .remove:
                let enititesAtKeyPath = Set(children)
                let toRemove = repository
                    .findRelations(for: Self.self, relationName: keyPath.relationName, id: id)
                    .compactMap { Child.ID($0) }
                    .filter { !enititesAtKeyPath.contains($0) }
                
                repository.save(removeLinks(toRemove, keyPath, inverse: inverse))
                repository.save(links(children, keyPath, inverse: inverse))
            }
        }
}

private extension EntityModel {
    func saveEntity<Child, Directionality, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        _ repository: inout Repository) {
            
            relationAt(keyPath).save(&repository)
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
                    name: keyPath.relationName,
                    updateOption: relationAt(keyPath).directLinkSaveOption
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
                    name: keyPath.relationName,
                    updateOption: relationAt(keyPath).directLinkSaveOption
                )
            )],
            inverse: children.map { child in
                Link(
                    parent: child,
                    children: [id],
                    attribute: LinkAttribute(
                        name: inverse.relationName,
                        updateOption: relationAt(keyPath).inverseLinkSaveOption
                    )
                )
            }
        )
    }
}
