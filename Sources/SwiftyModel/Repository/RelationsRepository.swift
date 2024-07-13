//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation
import Collections

struct RelationsRepository: Codable {
    typealias EntityID = String
    typealias EntityName = String
    typealias RelationName = String
    
    fileprivate var relations: [EntityName: [EntityID: [RelationName: OrderedSet<EntityID>]]] = [:]
}

extension RelationsRepository {
    mutating func saveLinks<Parent, Child>(_ links: Links<Parent, Child>) where Parent: EntityModel, Child: EntityModel {
        
        links.direct.forEach { link in
            saveLink(link)
        }
        
        links.inverse.forEach { link in
            saveLink(link)
        }
    }
    
    func findChildren<Parent: EntityModel>(
        for: Parent.Type,
        relationName: String,
        id: Parent.ID) -> OrderedSet<String> {
            
            let key = String(reflecting: Parent.self)
            
            let entitiesRelations = relations[key] ?? [:]
            let entityRelation = entitiesRelations[id.description] ?? [:]
            let relationsForName = entityRelation[relationName] ?? []
            return relationsForName
        }
}

private extension RelationsRepository {
    
    mutating func setChildren<Parent: EntityModel>(for: Parent.Type,
                                                   relationName: String,
                                                   id: Parent.ID,
                                                   relations: OrderedSet<String>) {
        
        let key = String(reflecting: Parent.self)
        
        var entitiesRelations = self.relations[key] ?? [:]
        var entityRelation = entitiesRelations[id.description] ?? [:]
        
        entityRelation[relationName] = relations
        entitiesRelations[id.description] = entityRelation
        self.relations[key] = entitiesRelations
    }
    
    mutating func saveLink<Parent, Child>(_ link: Link<Parent, Child>) where Parent: EntityModel, Child: EntityModel {
        
        var existingRelations = findChildren(
            for: Parent.self,
            relationName: link.attribute.name,
            id: link.parent
        )
      
        switch link.attribute.updateOption {
        case .append:
            link.children.forEach { existingRelations.append($0.description) }
        case .replace:
            existingRelations = OrderedSet(link.children.map { $0.description })
        case .remove:
            link.children.forEach { existingRelations.remove($0.description) }
        }
        
        setChildren(
            for: Parent.self,
            relationName: link.attribute.name,
            id: link.parent,
            relations: existingRelations
        )
    }
}

