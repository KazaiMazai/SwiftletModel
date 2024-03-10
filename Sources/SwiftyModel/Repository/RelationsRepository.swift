//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

enum Option {
    case append
    case replace
    case remove
}

struct Link {
    let name: String
    let updateOption: Option
}

struct EntitiesLink<Parent: IdentifiableEntity, Child: IdentifiableEntity> {
    let parent: Parent.ID
    let children: [Child.ID]
    let direct: Link
    let inverse: Link?
}

struct RelationsRepository: Codable {
    typealias EntityID = String
    typealias EntityName = String
    typealias RelationName = String
    
    fileprivate var relations: [EntityName: [EntityID: [RelationName: Set<EntityID>]]] = [:]
}

extension RelationsRepository {
    mutating func save<Parent, Child>(
        _ entitiesLink: EntitiesLink<Parent, Child>)
    
    where Parent: IdentifiableEntity, Child: IdentifiableEntity {
        
        saveChildren(
            Parent.self,
            childrenType: Child.self,
            id: entitiesLink.parent,
            relationName: entitiesLink.direct.name,
            children: entitiesLink.children,
            option: entitiesLink.direct.updateOption
        )
        
        guard let inverseUpdate = entitiesLink.inverse else {
            return
        }
        
        entitiesLink.children.forEach {
            saveChildren(
                Child.self,
                childrenType: Parent.self,
                id: $0,
                relationName: inverseUpdate.name,
                children: [entitiesLink.parent],
                option: inverseUpdate.updateOption
            )
        }
    }
    
    func findChildren<Parent: IdentifiableEntity>(
        for: Parent.Type,
        relationName: String,
        id: Parent.ID) -> Set<String> {
            
            let key = String(reflecting: Parent.self)
            
            let entitiesRelations = relations[key] ?? [:]
            let entityRelation = entitiesRelations[id.description] ?? [:]
            let relationsForName = entityRelation[relationName] ?? []
            return relationsForName
        }
}

extension RelationsRepository {
    
    mutating func setChildren<Parent: IdentifiableEntity>(for: Parent.Type,
                                                          relationName: String,
                                                          id: Parent.ID,
                                                          relations: Set<String>) {
        
        let key = String(reflecting: Parent.self)
        
        var entitiesRelations = self.relations[key] ?? [:]
        var entityRelation = entitiesRelations[id.description] ?? [:]
        
        entityRelation[relationName] = relations
        entitiesRelations[id.description] = entityRelation
        self.relations[key] = entitiesRelations
    }
    
    private mutating func saveChildren<Parent, Child>(_ parentType: Parent.Type,
                                                      childrenType: Child.Type,
                                                      id: Parent.ID,
                                                      relationName: String,
                                                      children: [Child.ID],
                                                      option: Option)
    where

    Parent: IdentifiableEntity,
    Child: IdentifiableEntity {
    
        var existingRelations = findChildren(
            for: Parent.self,
            relationName: relationName,
            id: id
        )
        
        switch option {
        case .append:
            children.forEach { existingRelations.insert($0.description) }
        case .replace:
            existingRelations = Set(children.map { $0.description })
        case .remove:
            children.forEach { existingRelations.remove($0.description) }
        }
        
        setChildren(
            for: Parent.self,
            relationName: relationName,
            id: id,
            relations: existingRelations
        )
    }
}

