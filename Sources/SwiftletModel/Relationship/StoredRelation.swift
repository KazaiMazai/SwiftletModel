//
//  StoredRelationships.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/06/2025.
//

import Foundation
import Collections

@EntityModel
struct StoredRelations<Parent, Child>: Sendable
where
Parent: EntityModelProtocol,
Child: EntityModelProtocol {
    
    var id: String { "\(parent)-\(name)" }
    
    private let name: String
    private let parent: Parent.ID
    private(set) var children: OrderedSet<Child.ID> = []
    
    init(id: Parent.ID, name: String, relations: [Child.ID]) {
        self.parent = id
        self.name = name
        self.children = OrderedSet(relations)
    }
    
    func asDeleted(in context: Context) -> Deleted<Self>? { nil }
    
    func saveMetadata(to context: inout Context) throws { }
    
    func deleteMetadata(from context: inout Context) throws { }
    
    
    static var defaultMergeStrategy: MergeStrategy<Self> { .replace }

    static var fragmentMergeStrategy: MergeStrategy<Self> { Self.append }
    
    static var append: MergeStrategy<Self> {
        MergeStrategy { old, new in
            var old = old
            old.children.append(contentsOf: new.children)
            return old
        }
    }
    
    static var replace: MergeStrategy<Self> {
        MergeStrategy { old, new in new }
    }
     
    static var remove: MergeStrategy<Self> {
        MergeStrategy { old, new in
            var old = old
            old.children.subtract(new.children)
            return old
        }
    }
    
    static func find<Directionality, Cardinality, Constraint>(
        related keyPath: KeyPath<Parent, Relation<Child, Directionality, Cardinality, Constraint>>,
        to parent: Parent.ID,
        in context: Context) -> [Child.ID] {
            query("\(parent)-\(keyPath.name)", in: context)
                .resolve()?
                .children.elements ?? []
    }
}

extension StoredRelations {
    static func save<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        to context: inout Context,
        options: Option) throws {
            
            switch options {
            case .remove:
                try StoredRelations<Parent, Child>.saveRelation(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .remove
                )
            case .append:
                try StoredRelations<Parent, Child>.saveRelation(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .append
                )
            case .replace:
                let enititesToKeep = Set(children)
                
                let oddChildren = StoredRelations<Parent, Child>
                    .find(related: keyPath,to: parent, in: context)
                    .filter { !enititesToKeep.contains($0) }
                
                try StoredRelations<Parent, Child>.saveRelation(
                    parent, oddChildren,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .remove
                )
                
                try StoredRelations<Parent, Child>.saveRelation(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .replace
                )
            }
        }
}


fileprivate extension StoredRelations {
    
    static func saveRelation<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        in context: inout Context,
        option: Option) throws {
            let storedRelations = StoredRelations(
                id: parent,
                name: keyPath.name,
                relations: children
            )
            
            let inverseOption = MutualRelation<Self, InverseRelation, InverseConstraint>.inverseLinkUpdateOption
            let merge: MergeStrategy<StoredRelations<Parent, Child>>
            let inverseMerge: MergeStrategy<StoredRelations<Child, Parent>>
            
            switch option {
            case .append:
                merge = Self.append
                switch inverseOption {
                case .append:
                    inverseMerge = StoredRelations<Child, Parent>.append
                case .replace:
                    inverseMerge = StoredRelations<Child, Parent>.replace
                case .remove:
                    inverseMerge = StoredRelations<Child, Parent>.remove
                }
            case .replace:
                merge = Self.replace
                switch inverseOption {
                case .append:
                    inverseMerge = StoredRelations<Child, Parent>.append
                case .replace:
                    inverseMerge = StoredRelations<Child, Parent>.replace
                case .remove:
                    inverseMerge = StoredRelations<Child, Parent>.remove
                }
            case .remove:
                merge = Self.remove
                inverseMerge = StoredRelations<Child, Parent>.remove
            }
            
            try storedRelations.save(to: &context, options: merge)
            
            try children.forEach {
                let relation = StoredRelations<Child, Parent>(
                    id: $0,
                    name: inverse.name,
                    relations: [parent]
                )
                
                try relation.save(
                    to: &context,
                    options: inverseMerge
                )
            }
        }
}


extension StoredRelations {
 
    static func save<Cardinality, Constraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>,
        to context: inout Context,
        options: Option
    ) throws {
        
        let storedRelations = StoredRelations(
            id: parent,
            name: keyPath.name,
            relations: children
        )
        
        switch options {
        case .append:
            try storedRelations.save(to: &context, options: Self.append)
        case .replace:
            try storedRelations.save(to: &context, options: Self.replace)
        case .remove:
            try storedRelations.save(to: &context, options: Self.remove)
        }
    }
}

