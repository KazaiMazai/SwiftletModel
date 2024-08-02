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

    private var relations: [EntityName: [EntityID: [RelationName: OrderedSet<EntityID>]]] = [:]
}

extension RelationsRepository {
    mutating func updateLinks<Parent, Child>(_ links: Links<Parent, Child>) {

        links.direct.forEach { link in
            updateLink(link)
        }

        links.inverse.forEach { link in
            updateLink(link)
        }
    }
}

extension RelationsRepository {
    func getChildren<Parent: EntityModel>(
        for: Parent.Type,
        relationName: String,
        id: Parent.ID) -> OrderedSet<String> {

            let entityName = String(reflecting: Parent.self)

            let entitiesRelations = relations[entityName] ?? [:]
            let entityRelation = entitiesRelations[id.description] ?? [:]
            let relationsForName = entityRelation[relationName] ?? []
            return relationsForName
    }

    private mutating func setChildren<Parent: EntityModel>(
        for: Parent.Type,
        relationName: String,
        id: Parent.ID,
        relations: OrderedSet<String>) {

            let entityName = String(reflecting: Parent.self)

            var entitiesRelations = self.relations[entityName] ?? [:]
            var entityRelation = entitiesRelations[id.description] ?? [:]

            entityRelation[relationName] = relations
            entitiesRelations[id.description] = entityRelation
            self.relations[entityName] = entitiesRelations
    }
}

private extension RelationsRepository {
    mutating func updateLink<Parent, Child>(_ link: Link<Parent, Child>) {

        var existingRelations = getChildren(
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
