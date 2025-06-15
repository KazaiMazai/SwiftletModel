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
                try Link<Parent, Child>.updateLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .remove
                )
            case .append:
                try Link<Parent, Child>.updateLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .append
                )
            case .replace:
                let enititesToKeep = Set(children)
                
                let oddChildren = Link<Parent, Child>
                    .find(related: keyPath,to: parent, in: context)
                    .filter { !enititesToKeep.contains($0) }
                
                try Link<Parent, Child>.updateLink(
                    parent, oddChildren,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .remove
                )
                
                try Link<Parent, Child>.updateLink(
                    parent, children,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context,
                    option: .replace
                )
            }
        }
}


fileprivate extension Link {
    static func updateLink<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        _ parent: Parent.ID,
        _ children: [Child.ID],
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        in context: inout Context,
        option: Option) throws {
            
            let directMerge: MergeStrategy<Link<Parent, Child>>
            let inverseMerge: MergeStrategy<Link<Child, Parent>>
            
            switch option {
            case .append:
                directMerge = Link<Parent, Child>.append
            case .replace:
                directMerge = Link<Parent, Child>.replace
            case .remove:
                directMerge = Link<Parent, Child>.remove
            }
            
            let inverseOption: Link<Child, Parent>.Option
            inverseOption = MutualRelation<Parent, InverseRelation, InverseConstraint>.inverseLink()
            
            switch (inverseOption, option) {
            case (_, .remove):
                inverseMerge = Link<Child, Parent>.remove
            case (.append, _):
                inverseMerge = Link<Child, Parent>.append
            case (.replace, _):
                inverseMerge = Link<Child, Parent>.replace
            case (.remove, _):
                inverseMerge = Link<Child, Parent>.remove
            }
            
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

