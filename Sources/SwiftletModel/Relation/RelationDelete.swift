//
//  File.swift
//
//
//  Created by Sergey Kazakov on 13/07/2024.
//

import Foundation

// MARK: - Delete Relations & Attached Entities

public extension EntityModel {
    func delete<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        from context: inout Context) throws {

        let children = context
            .getChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }

        try delete(children, relation: keyPath, from: &context)
    }

    func delete<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        from context: inout Context) throws {

        let children = context
            .getChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }

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
        detach(entities, relation: keyPath, in: &context)
    }

    func delete<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        from context: inout Context) throws {

        try entities.forEach { try Child.delete(id: $0, from: &context) }
        detach(entities, relation: keyPath, inverse: inverse, in: &context)
    }
}

// MARK: - Detach Relations

public extension EntityModel {
    func detach<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) {

        let children = context
            .getChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }

        detach(children, relation: keyPath, in: &context)
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) {

        let children = context
            .getChildren(for: Self.self, relationName: keyPath.name, id: id)
            .compactMap { Child.ID($0) }

        detach(children, relation: keyPath, inverse: inverse, in: &context)
    }

    func detach<Child, Cardinality, Constraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) {

        detach(entities, relation: keyPath, in: &context)
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: Child.ID...,
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) {

        detach(entities, relation: keyPath, inverse: inverse, in: &context)
    }

    func detach<Child, Cardinality, Constraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) {

        context.updateLinks(unlink(entities, keyPath))
    }

    func detach<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ entities: [Child.ID],
        relation keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) {

        context.updateLinks(unlink(entities, keyPath, inverse: inverse))
    }
}

extension EntityModel {
    func unlink<Child, Cardinality, Constraint>(
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

    func unlink<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
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
