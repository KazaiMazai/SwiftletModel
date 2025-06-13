//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation
import Collections
//
//struct RelationsRepository: Codable {
//    typealias EntityID = String
//    typealias EntityName = String
//    typealias RelationName = String
//    
//    private(set) var relations: [EntityName: [EntityID: [RelationName: OrderedSet<EntityID>]]] = [:]
//}
//
//extension RelationsRepository {
//    mutating func updateLinks<Parent, Child>(_ links: Links<Parent, Child>) {
//        
//        links.direct.forEach { link in
//            updateLink(link)
//        }
//        
//        links.inverse.forEach { link in
//            updateLink(link)
//        }
//    }
//}
//
//extension RelationsRepository {
//    func getChildren<Parent: EntityModelProtocol>(
//        for: Parent.Type,
//        relationName: String,
//        id: Parent.ID) -> OrderedSet<String> {
//            
//            let entityName = String(reflecting: Parent.self)
//            let entitiesRelations = relations[entityName] ?? [:]
//            let entityRelation = entitiesRelations[id.description] ?? [:]
//            return entityRelation[relationName] ?? []
//        }
//    
//    private mutating func setChildren<Parent: EntityModelProtocol>(
//        for: Parent.Type,
//        relationName: String,
//        id: Parent.ID,
//        relations: OrderedSet<String>) {
//            
//            let entityName = String(reflecting: Parent.self)
//            
//            var entitiesRelations = self.relations[entityName] ?? [:]
//            var entityRelation = entitiesRelations[id.description] ?? [:]
//            
//            entityRelation[relationName] = relations
//            entitiesRelations[id.description] = entityRelation
//            self.relations[entityName] = entitiesRelations
//        }
//}
//
//private extension RelationsRepository {
//    mutating func updateLink<Parent, Child>(_ link: Link<Parent, Child>) {
//        
//        var existingRelations = getChildren(
//            for: Parent.self,
//            relationName: link.attribute.name,
//            id: link.parent
//        )
//        
//        switch link.attribute.updateOption {
//        case .append:
//            link.children.forEach { existingRelations.append($0.description) }
//        case .replace:
//            existingRelations = OrderedSet(link.children.map { $0.description })
//        case .remove:
//            link.children.forEach { existingRelations.remove($0.description) }
//        }
//        
//        setChildren(
//            for: Parent.self,
//            relationName: link.attribute.name,
//            id: link.parent,
//            relations: existingRelations
//        )
//    }
//}

@EntityModel
struct StoredRelations<Parent, Child>: Sendable
where
Parent: EntityModelProtocol,
Child: EntityModelProtocol {
    
    var id: String { "\(parentId)-\(name)" }
    
    let name: String
    private let parentId: Parent.ID
    private(set) var relations: OrderedSet<Child.ID> = []
    
    init(id: Parent.ID, name: String, relations: [Child.ID]) {
        self.parentId = id
        self.name = name
        self.relations = OrderedSet(relations)
    }
    
    func asDeleted(in context: Context) -> Deleted<Self>? { nil }
    
    func saveMetadata(to context: inout Context) throws { }
    
    func deleteMetadata(from context: inout Context) throws { }
    
    
    static var defaultMergeStrategy: MergeStrategy<Self> { .replace }

    static var fragmentMergeStrategy: MergeStrategy<Self> { Self.append }
    
    static var append: MergeStrategy<Self> {
        MergeStrategy { old, new in
            var old = old
            old.relations.append(contentsOf: new.relations)
            return old
        }
    }
    
    static var replace: MergeStrategy<Self> {
        MergeStrategy { old, new in new }
    }
     
    static var remove: MergeStrategy<Self> {
        MergeStrategy { old, new in
            var old = old
            old.relations.subtract(new.relations)
            return old
        }
    }
    
    static func query(
        parentId: Parent.ID,
        relationName: String,
        in context: Context) -> Query<Self> {
            
            query("\(parentId)-\(relationName)", in: context)
        }
    
    static func queryChildren(
        parentId: Parent.ID,
        relationName: String,
        in context: Context) -> [Child.ID] {
            query(parentId: parentId,  relationName: relationName, in: context)
            .resolve()?
            .relations.elements ?? []
    }
    
}

extension StoredRelations {
    static func updateLink<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        parentId: Parent.ID,
        children: [Child.ID],
        option: Option,
        
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {
            
            switch option {
            case .remove:
                try StoredRelations<Parent, Child>.update(
                    
                    parentId: parentId,
                    children: children,
                    option: .remove,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context
                )
            case .append:
                try StoredRelations<Parent, Child>.update(
                    parentId: parentId,
                    children: children,
                    option: .append,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context
                )
            case .replace:
                let enititesToKeep = Set(children)
                
                let odd = StoredRelations<Parent, Child>
                    .query(parentId: parentId, relationName: keyPath.name, in: context)
                    .resolve()?
                    .relations.elements ?? []
                    .filter { !enititesToKeep.contains($0) }
                
                try StoredRelations<Parent, Child>.update(
                    parentId: parentId,
                    children: odd,
                    option: .remove,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context
                )
                
                try StoredRelations<Parent, Child>.update(
                    parentId: parentId,
                    children: children,
                    option: .replace,
                    keyPath: keyPath,
                    inverse: inverse,
                    in: &context
                )
            }
        }
}


fileprivate extension StoredRelations {
    
    static func update<Cardinality, Constraint, InverseRelation, InverseConstraint>(
        parentId: Parent.ID,
        children: [Child.ID],
        option: Option,
        
        keyPath: KeyPath<Parent, MutualRelation<Child, Cardinality, Constraint>>,
        inverse: KeyPath<Child, MutualRelation<Parent, InverseRelation, InverseConstraint>>,
        in context: inout Context) throws {
            let storedRelations = StoredRelations(
                id: parentId,
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
                    relations: [parentId]
                )
                
                try relation.save(
                    to: &context,
                    options: inverseMerge
                )
            }
        }
}


extension StoredRelations {
 
    static func updateLink<Cardinality, Constraint>(
        
        parentID: Parent.ID,
        children: [Child.ID],
        option: Option,
        keyPath: KeyPath<Parent, OneWayRelation<Child, Cardinality, Constraint>>,
        in context: inout Context) throws {
            
            let storedRelations = StoredRelations(
                id: parentID,
                name: keyPath.name,
                relations: children
            )
            
            switch option {
            case .append:
                try storedRelations.save(to: &context, options: Self.append)
            case .replace:
                try storedRelations.save(to: &context, options: Self.replace)
            case .remove:
                try storedRelations.save(to: &context, options: Self.remove)
            }
    }
 
}

 
