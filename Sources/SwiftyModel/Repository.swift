//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Repository {
    typealias EntityID = String
    typealias EntityName = String
    typealias RelationName = String
    
    private var storages: [EntityName: [EntityID: any IdentifiableEntity]] = [:]
    fileprivate var relations: [EntityName: [EntityID: [RelationName: Set<EntityID>]]] = [:]
    
}

extension Repository {
    func all<T>() -> [T] {
        let key = String(reflecting: T.self)
        return storages[key]?.compactMap { $0.value as? T } ?? []
    }
    
    func find<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        let storage = storages[key] ?? [:]
        return storage[id.description] as? T
    }
    
    func findAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        ids.map { find($0) }
    }
    
    func findAllExisting<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T] {
        findAll(ids).compactMap { $0 }
    }
    
    @discardableResult
    mutating func remove<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        let key = EntityName(reflecting: T.self)
        var storage = storages[key] ?? [:]
        let value = storage[id.description] as? T
        storage.removeValue(forKey: id.description)
        storages[key] = storage
        return value
    }
    
    @discardableResult
    mutating func removeAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        ids.map { remove($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T) {
        let key = String(reflecting: T.self)
        var storage = storages[key] ?? [:]
        var normalizedCopy = entity
        normalizedCopy.normalize()
        storage[entity.id.description] = normalizedCopy
        storages[key] = storage
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T?) {
        guard let entity else {
            return
        }
        
        save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entities: [T]) {
        entities.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: Relation<T>) {
        save(relation.entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<Relation<T>>) {
        relations.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<Relation<T>>)?) {
        guard let relations else {
            return
        }
        
        save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: BiRelation<T>) {
        save(relation.entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<BiRelation<T>>) {
        relations.forEach { save($0) }
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<BiRelation<T>>)?) {
        guard let relations else {
            return
        }
        
        save(relations)
    }
}

enum SaveOption {
    case append
    case replace
}

extension Repository {
   
   
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(_ entityRelation: EntityRelation<T, E>) {
        
        saveRelation(
            T.self,
            id: entityRelation.id,
            relationName: entityRelation.name,
            relations: entityRelation.relation,
            option: entityRelation.option
        )
        
        guard let inverseName = entityRelation.inverseName else {
            return
        }
        
        let reversedRelation = Relation<T>(entityRelation.id)
        
        entityRelation.relation.forEach {
            saveRelation(
                E.self,
                id: $0.id,
                relationName: inverseName,
                relations: [reversedRelation],
                option: entityRelation.inverseOption ?? .append
            )
        }
    }
     
    func relations<T: IdentifiableEntity>(for: T.Type, relationName: String, id: T.ID) -> Set<String> {
        
        let key = String(reflecting: T.self)
        
        let entitiesRelations = relations[key] ?? [:]
        let entityRelation = entitiesRelations[id.description] ?? [:]
        let relationsForName = entityRelation[relationName] ?? []
        return relationsForName
    }
    
    private mutating func saveRelation<T: IdentifiableEntity, E: IdentifiableEntity>(_ entityType: T.Type,
                                                                                     id: T.ID,
                                                                                     relationName: String,
                                                                                     relations: [Relation<E>],
                                                                                     option: SaveOption) {
        
        let key = String(reflecting: T.self)
        
        var entitiesRelations = self.relations[key] ?? [:]
        var entityRelation = entitiesRelations[id.description] ?? [:]
        var relationsForName = entityRelation[relationName] ?? []
        
        switch option {
        case .append:
            relations.forEach { relationsForName.insert($0.id.description) }
        case .replace:
            relationsForName = Set(relations.map { $0.id.description })
        }
        
        entityRelation[relationName] = relationsForName
        entitiesRelations[id.description] = entityRelation
        self.relations[key] = entitiesRelations
    }
}



extension Repository {
    func find<T: IdentifiableEntity>(_ id: T.ID) -> Entity<T> {
        find(T.self, id: id)
    }
    
    func find<T: IdentifiableEntity>(_ type: T.Type, id: T.ID) -> Entity<T> {
        Entity(repository: self, id: id)
    }
    
    func find<T: IdentifiableEntity>(_ ids: [T.ID]) -> [Entity<T>] {
        ids.map { find($0) }
    }
}





struct User: IdentifiableEntity, Codable {
    
    let id: String
    let name: String
    var messages: [Relation<Message>]?
    var follows: [BiRelation<User>]?
    var followedBy: [BiRelation<User>]?
    
    mutating func normalize() {
        messages?.normalize()
        follows?.normalize()
    }
}

struct Message: IdentifiableEntity, Codable {
    let id: String
    let text: String
    var attachments: [BiRelation<Attachment>]?
    
    mutating func normalize() {
        attachments?.normalize()
    }
}

struct Attachment: IdentifiableEntity, Codable {
    let id: String
    let link: String
    var message: BiRelation<Message>?
    
    mutating func normalize() {
        message?.normalize()
    }
}


func test() {
    let attachment = Attachment(id: "1", link: "")
    let message = Message(id: "1", text: "the message", attachments: [BiRelation(attachment)])
    
    var storage = Repository()
    let user = User(id: "2", name: "alice", messages: [Relation(message)])
    
    
    storage.save(user)
    storage.save(user.follows)
    storage.save(user.relation(\.follows, option: .append, inverse: \.followedBy))
    
    storage.save(message)
    storage.save(attachment)
    
    let retrievedUser: [User] = storage
        .find(User.self, id: "2")
        .related(\.followedBy)
        .resolve()
        .compactMap { $0 } ?? []
    
    
    storage.save(message.relation(\.attachments, option: .append, inverse: \.message))
    storage.save(attachment.relation(\.message, inverse: \.attachments))
    storage.save(user.relation(\.messages, option: .append))
    
    let attachments = Message
        .find("1", in: storage)
        .related(\.attachments)
        .resolve()
    
    
    
    storage.find(Message.self, id: "1")
        .related(\.attachments)
        .resolve()
    //
    //let attachments = storage
    //    .get(User.self, id: "2")
    //    .get(\.messages)?
    //    .compactMap { $0 }
    //    .get(\.attachments)
    //    .resolve()
    //    .get(\.messages)?
    //    .get(\.attachments)
    //    .compactMap { $0 }
    //    .get(\Message.attachments)?
    //    .resolve()
    //    .compactMap { $0 } ?? []
    
    let retrievedMessage = storage.find(Attachment.self, id: "1")
        .related(\.message)?
        .resolve()
    
    print(retrievedMessage?.text)
    
    let users: [User] = storage.all()
}
