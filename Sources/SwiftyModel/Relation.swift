//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 03/03/2024.
//

import Foundation

extension IdentifiableEntity {
    func relation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>,
        replace: Bool = true
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: nil
        )
    }
}

typealias MutualRelation<T: IdentifiableEntity, Relation: RelationProtocol, Constraint> = Relationship<T, Bidirectional, Relation, Constraint>

typealias OneWayRelation<T: IdentifiableEntity, Relation: RelationProtocol, Constraint> = Relationship<T, Unidirectional, Relation, Constraint>


fileprivate extension IdentifiableEntity {
    
    func saveRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        replace: Bool = true,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: Relation.directLinkOption(replace)
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: InverseRelation.inverseLinkOption()
            )
        )
    }
}

extension IdentifiableEntity {
    func removeRelation<Child, Relation, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Relation, Constraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: nil
        )
    }
    
    func removeRelation<Child, Relation, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Relation, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        EntitiesLink(
            parent: id,
            children: children(keyPath),
            direct: Link(
                name: keyPath.relationName,
                updateOption: .remove
            ),
            inverse: Link(
                name: inverse.relationName,
                updateOption: .remove
            )
        )
    }
}

fileprivate extension RelationProtocol {
    static func directLinkOption(_ replace: Bool) -> Option {
        let append: Option = isCollection ? .append : .replaceIfNotEmpty
        return replace ? .replace : append
    }
    
    static func inverseLinkOption() -> Option {
        isCollection ? .append : .replace
    }
}

fileprivate extension IdentifiableEntity {
    func children<Child, Direction, Relation, Optionality>(_ keyPath: KeyPath<Self, Relationship<Child, Direction, Relation, Optionality>>) -> [Child.ID] {
        self[keyPath: keyPath].ids
    }
}


typealias ManyToOneRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToOneRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToOne, Constraint>

typealias OneToManyRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>

typealias ManyToManyRelation<T: IdentifiableEntity, Constraint> = Relationship<T, Bidirectional, Relation.ToMany, Constraint>
 
extension IdentifiableEntity {
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        replace: Bool = true,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        replace: Bool = true,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>

    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        replace: Bool = true,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
    
    func relation<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        replace: Bool = true,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>
        
    ) -> EntitiesLink<Self, Child> {
        
        saveRelation(keyPath, replace: replace, inverse: inverse)
    }
}
