//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension EntityModel {
    func relation<Child, Kind, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Kind, Constraint>>
        
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

typealias MutualRelation<T: EntityModel, Kind: RelationKindProtocol, Constraint> = Relationship<T, Bidirectional, Kind, Constraint>

typealias OneWayRelation<T: EntityModel, Kind: RelationKindProtocol, Constraint> = Relationship<T, Unidirectional, Kind, Constraint>


fileprivate extension EntityModel {
    
    func saveRelation<Child, Kind, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Kind, Constraint>>,
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
    func removeRelation<Child, Kind, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Kind, Constraint>>
        
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
    
    func removeRelation<Child, Kind, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Kind, Constraint>>,
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
    func children<Child, Direction, Kind, Constraint>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Kind, Constraint>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}


typealias ManyToOneRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, RelationKind.ToOne, Constraint>

typealias OneToOneRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, RelationKind.ToOne, Constraint>

typealias OneToManyRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, RelationKind.ToMany, Constraint>

typealias ManyToManyRelation<T: EntityModel, Constraint> = Relationship<T, Bidirectional, RelationKind.ToMany, Constraint>
 
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
