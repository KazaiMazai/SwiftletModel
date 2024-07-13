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
            
            saveRelatedEntity(at: keyPath, &repository)
            attach(keyPath, in: &repository)
    }
}

public extension EntityModel {
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveRelatedEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveRelatedEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to repository: inout Repository) {
            
            saveRelatedEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
    
    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to repository: inout Repository){
            
            saveRelatedEntity(at: keyPath, &repository)
            attach(keyPath, inverse: inverse, in: &repository)
    }
}


//MARK: -  Private

fileprivate extension EntityModel {
    func detachIfNeeded<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        allExcept keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository)  {
            
            switch self[keyPath: keyPath].directLinkSaveOption {
            case .append:
                return
            case .replace, .remove:
                let enititesAtKeyPath = Set(children(keyPath))
                let children = repository
                    .findRelations(for: Self.self, relationName: keyPath.relationName, id: id)
                    .compactMap { Child.ID($0) }
                    .filter { !enititesAtKeyPath.contains($0) }
                
                detach(children, relation: keyPath, inverse: inverse, in: &repository)
            }
    }
    
    func attach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in repository: inout Repository) {
            
            repository.save(attachmentLink(keyPath))
        }
    
    func attach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in repository: inout Repository) {
            
            detachIfNeeded(allExcept: keyPath, inverse: inverse, in: &repository)
            repository.save(attachmentLink(keyPath, inverse: inverse))
        }
}

fileprivate extension EntityModel {
    func saveRelatedEntity<Child, Directionality, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        _ repository: inout Repository) {
            
            self[keyPath: keyPath].save(&repository)
    }
}
 
fileprivate extension EntityModel {
    func attachmentLink<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>
        
    ) -> Links<Self, Child> {
        
        Links(
            direct: Link(
                parent: id,
                children: children(keyPath),
                attribute: LinkAttribute(
                    name: keyPath.relationName,
                    updateOption: self[keyPath: keyPath].directLinkSaveOption
                )
            ),
            inverse: []
        )
    }

    func attachmentLink<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> Links<Self, Child> {
        
        let children = children(keyPath)
        return Links(
            direct: Link(
                parent: id,
                children: children,
                attribute: LinkAttribute(
                    name: keyPath.relationName,
                    updateOption: self[keyPath: keyPath].directLinkSaveOption
                )
            ),
            inverse: children.map { child in
                Link(
                    parent: child,
                    children: [id],
                    attribute: LinkAttribute(
                        name: inverse.relationName,
                        updateOption: self[keyPath: keyPath].inverseLinkSaveOption
                    )
                )
            }
        )
    }
}
