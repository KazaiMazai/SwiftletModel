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
        to context: inout Context) throws {
            
        try saveEntities(at: keyPath, in: &context)
        saveRelation(at: keyPath, in: &context)
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {
            
        try saveEntities(at: keyPath, in: &context)
        saveRelation(at: keyPath, inverse: inverse, in: &context)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {
            
        try saveEntities(at: keyPath, in: &context)
        saveRelation(at: keyPath, inverse: inverse, in: &context)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {
            
        try saveEntities(at: keyPath, in: &context)
        saveRelation(at: keyPath, inverse: inverse, in: &context)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {
            
        try saveEntities(at: keyPath, in: &context)
        saveRelation(at: keyPath, inverse: inverse, in: &context)
    }
}

//MARK: -  Private

private extension EntityModel {

    func saveRelation<Child, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) {
            
        context.updateLinks(link(relationIds(keyPath), keyPath))
    }
    
    func saveRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        at keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) {
            
        let children = relationIds(keyPath)
        switch relation(keyPath).directLinkSaveOption {
        case .append:
            context.updateLinks(link(children, keyPath, inverse: inverse))
        case .replace, .remove:
            let enititesToKeep = Set(children)
            let oddExisingChildren = context
                .findChildren(for: Self.self, relationName: keyPath.name, id: id)
                .compactMap { Child.ID($0) }
                .filter { !enititesToKeep.contains($0) }
            
            context.updateLinks(unlink(oddExisingChildren, keyPath, inverse: inverse))
            context.updateLinks(link(children, keyPath, inverse: inverse))
        }
    }
}

private extension EntityModel {
    func saveEntities<Child, Directionality, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        in context: inout Context) throws {
            
        try relation(keyPath).save(&context)
    }
}
 
private extension EntityModel {
    func link<Child, Cardinality, Constraint>(
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

    func link<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
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
