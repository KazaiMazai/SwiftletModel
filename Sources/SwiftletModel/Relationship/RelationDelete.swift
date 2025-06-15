//
//  File.swift
//
//
//  Created by Serge Kazakov on 13/07/2024.
//

import Foundation

// MARK: - Delete Relations & Attached Entities

public extension EntityModelProtocol {
    func delete<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        from context: inout Context) throws {

        let children = StoredRelations<Self, Child>.find(
            related: keyPath,
            to: id,
            in: context
        )

        try delete(children, relation: keyPath, from: &context)
    }

    func delete<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        from context: inout Context) throws {

            let children = StoredRelations<Self, Child>.find(
                related: keyPath,
                to: id,
                in: context
            )
            
            try delete(children, relation: keyPath, inverse: inverse, from: &context)
    }

    func delete<Child, Cardinality, Constraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        from context: inout Context) throws {

        try delete(entities, relation: keyPath, from: &context)
    }

    func delete<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        from context: inout Context) throws {

        try delete(entities, relation: keyPath, inverse: inverse, from: &context)
    }

    func delete<Child, Cardinality, Constraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        from context: inout Context) throws {

        try entities.forEach { try Child.delete(id: $0, from: &context) }
        try detach(entities, relation: keyPath, in: &context)
    }

    func delete<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        from context: inout Context) throws {

        try entities.forEach { try Child.delete(id: $0, from: &context) }
        try detach(entities, relation: keyPath, inverse: inverse, in: &context)
    }
}

// MARK: - Detach Relations

public extension EntityModelProtocol {
    func detach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) throws {

        let children = StoredRelations<Self, Child>.find(
            related: keyPath,
            to: id,
            in: context
        )

        try detach(children, relation: keyPath, in: &context)
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {

        let children = StoredRelations<Self, Child>.find(
            related: keyPath,
            to: id,
            in: context
        )

        try detach(children, relation: keyPath, inverse: inverse, in: &context)
    }

    func detach<Child, Cardinality, Constraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) throws {

        try detach(entities, relation: keyPath, in: &context)
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {

        try detach(entities, relation: keyPath, inverse: inverse, in: &context)
    }

    func detach<Child, Cardinality, Constraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) throws {

            try StoredRelations<Self, Child>.save(
                id, entities,
                keyPath: keyPath,
                to: &context,
                options: .remove
            )
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {

    
        try StoredRelations<Self, Child>.save(
            id, entities,
            keyPath: keyPath,
            inverse: inverse,
            to: &context,
            options: .remove
        )
    }
}
