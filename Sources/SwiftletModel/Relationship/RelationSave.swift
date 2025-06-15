//
//  File.swift
//  
//
//  Created by Serge Kazakov on 13/07/2024.
//

import Foundation
import OrderedCollections

// MARK: - Save Relations and Attached Entities

public extension EntityModelProtocol {
    func save<Child, Cardinality, Constraint>(
        _ keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        to context: inout Context) throws {

        try saveEntities(at: keyPath, in: &context)
        try saveRelation(at: keyPath, in: &context)
    }
}

public extension EntityModelProtocol {

    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToOneRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {

        try saveEntities(at: keyPath, in: &context)
        try saveRelation(at: keyPath, inverse: inverse, in: &context)
    }

    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToManyRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {

        try saveEntities(at: keyPath, in: &context)
        try saveRelation(at: keyPath, inverse: inverse, in: &context)
    }

    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, ManyToManyRelation<Child, Constaint>>,
        inverse: KeyPath<Child, ManyToManyRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {

        try saveEntities(at: keyPath, in: &context)
        try saveRelation(at: keyPath, inverse: inverse, in: &context)
    }

    func save<Child, Constaint, InverseConstraint>(
        _ keyPath: KeyPath<Self, OneToOneRelation<Child, Constaint>>,
        inverse: KeyPath<Child, OneToOneRelation<Self, InverseConstraint>>,
        to context: inout Context) throws {

        try saveEntities(at: keyPath, in: &context)
        try saveRelation(at: keyPath, inverse: inverse, in: &context)
    }
}

// MARK: - Private

private extension EntityModelProtocol {

    func saveRelation<Child, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) throws {

            try Link<Self, Child>.update(
                id, relationIds(keyPath),
                keyPath: keyPath,
                in: &context,
                options: relation(keyPath).updateOption()
            )
    }

    func saveRelation<Child, Cardinality, Constraint, InverseRelation, InverseConstraint>(
        at keyPath: KeyPath<Self, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Self, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {

        try Link<Self, Child>.update(
            id, relationIds(keyPath),
            keyPath: keyPath,
            inverse: inverse,
            in: &context,
            options: relation(keyPath).updateOption()
        )
    }
}

private extension EntityModelProtocol {
    func saveEntities<Child, Directionality, Cardinality, Constraint>(
        at keyPath: KeyPath<Self, Relation<Child, Directionality, Cardinality, Constraint>>,
        in context: inout Context) throws {

        try relation(keyPath).save(&context)
    }
}
 
