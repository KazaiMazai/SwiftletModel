//
//  StoredRelationships.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 12/06/2025.
//

import Foundation
import Collections

extension Link {
    enum Option {
        case append
        case replace
        case remove
    }
}

@EntityModel
struct Link<Parent, Child>: Sendable
where
Parent: EntityModelProtocol,
Child: EntityModelProtocol {
    
    var id: String { "\(parent)-\(name)" }
    
    private let name: String
    private let parent: Parent.ID
    private(set) var children: OrderedSet<Child.ID> = []
    
    init( _ parent: Parent.ID, _ children: [Child.ID], name: String) {
        self.parent = parent
        self.name = name
        self.children = OrderedSet(children)
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

extension Link {
    
    static func update<Cardinality, Constraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>,
        to context: inout Context,
        options: Option
    ) throws {
        
        let directLink = Link(
            parent, children,
            name: keyPath.name
        )
        
        switch options {
        case .append:
            try directLink.save(to: &context, options: Self.append)
        case .replace:
            try directLink.save(to: &context, options: Self.replace)
        case .remove:
            try directLink.save(to: &context, options: Self.remove)
        }
    }
    
    static func update<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        to context: inout Context,
        options: Option) throws {
            
            switch options {
            case .remove:
                try Link<Parent, Child>.updateMutualLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    directMerge: Link<Parent, Child>.remove,
                    inverseMerge: Link<Child, Parent>.remove
                )
            case .append:
                try Link<Parent, Child>.updateMutualLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    directMerge: Link<Parent, Child>.append,
                    inverseMerge: inverse.typeOfValue.inverseMerge()
                )
            case .replace:
                let childrenSet = Set(children)
                
                let oddChildren = Link<Parent, Child>
                    .find(related: keyPath, to: parent, in: context)
                    .filter { !childrenSet.contains($0) }
                
                try Link<Parent, Child>.updateMutualLink(
                    parent, oddChildren,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    directMerge: Link<Parent, Child>.remove,
                    inverseMerge: Link<Child, Parent>.remove
                )
                
                try Link<Parent, Child>.updateMutualLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    directMerge: Link<Parent, Child>.replace,
                    inverseMerge: inverse.typeOfValue.inverseMerge()
                )
            }
        }
}


fileprivate extension Link {
    
    static func updateMutualLink<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        in context: inout Context,
        directMerge: MergeStrategy<Link<Parent, Child>>,
        inverseMerge: MergeStrategy<Link<Child, Parent>>) throws {
            
            let directLink = Link(
                parent, children,
                name: keyPath.name
            )
            
            try directLink.save(to: &context, options: directMerge)
            try children.forEach {
                let inverseLink = Link<Child, Parent>(
                    $0, [parent],
                    name: inverse.name
                )
                
                try inverseLink.save(
                    to: &context,
                    options: inverseMerge
                )
            }
        }
}

extension Relation {
    static  func inverseLink<Parent>() -> Link<Parent, Entity>.Option {
        Cardinality.isToMany ? .append : .replace
    }
    
    static  func inverseMerge<Parent>() -> MergeStrategy<Link<Parent, Entity>> {
        let inverseOption: Link<Parent, Entity>.Option = inverseLink()
        switch inverseOption {
        case .append:
            return Link<Parent, Entity>.append
        case .replace:
            return Link<Parent, Entity>.replace
        case .remove:
            return Link<Parent, Entity>.remove
        }
    }
}

fileprivate extension KeyPath {
    var typeOfValue: Value.Type {
        Value.self
    }
}
