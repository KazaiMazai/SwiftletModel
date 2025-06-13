//
//  File.swift
//
//
//  Created by Serge Kazakov on 02/03/2024.
//

import Foundation
import Collections

public struct Context: Sendable {
    private var entitiesRepository = EntitiesRepository()
//    private var relationsRepository = RelationsRepository()

    public init() { }
}

public extension Context {
    func ids<T: EntityModelProtocol>(_ entityType: T.Type) -> [T.ID] {
        entitiesRepository.ids(T.self)
    }

    func all<T: EntityModelProtocol>() -> [T] {
        entitiesRepository.all()
    }

    func find<T: EntityModelProtocol>(_ id: T.ID) -> T? {
        entitiesRepository.find(id)
    }

    func findAll<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.findAll(ids)
    }

    func findAllExisting<T: EntityModelProtocol>(_ ids: [T.ID]) -> [T] {
        entitiesRepository.findAllExisting(ids)
    }
}

public extension Context {

    mutating func remove<T: EntityModelProtocol>(_ entityType: T.Type, id: T.ID) {
        entitiesRepository.remove(T.self, id: id)
    }

    mutating func removeAll<T: EntityModelProtocol>(_ entityType: T.Type, ids: [T.ID]) {
        entitiesRepository.removeAll(T.self, ids: ids)
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T,
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entity, options: options)
    }

    mutating func insert<T: EntityModelProtocol>(_ entity: T?,
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entity, options: options)
    }

    mutating func insert<T: EntityModelProtocol>(_ entities: [T],
                                                 options: MergeStrategy<T> = .replace) {

        entitiesRepository.insert(entities, options: options)
    }
}

//extension Context {
//    mutating func updateLinks<Parent: EntityModelProtocol, Child: EntityModelProtocol>(_ links: Links<Parent, Child>) {
//        relationsRepository.updateLinks(links)
//    }
//}

//extension Context {
//    func getChildren<T: EntityModelProtocol>(for type: T.Type, relationName: String, id: T.ID) -> OrderedSet<String> {
//        relationsRepository.getChildren(for: type, relationName: relationName, id: id)
//    }
//}

extension Context {
    func query<Entity: EntityModelProtocol>(_ id: Entity.ID) -> Query<Entity> {
        Query(context: self, id: id)
    }

    func query<Entity: EntityModelProtocol>(_ ids: [Entity.ID]) -> QueryList<Entity> {
        QueryList(context: self) {
            ids.map { query($0) }
        }
    }

    func query<Entity: EntityModelProtocol>() -> QueryList<Entity> {
        query(ids(Entity.self))
    }
}
