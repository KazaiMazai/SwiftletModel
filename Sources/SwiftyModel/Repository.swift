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
    
    private var entities = EntitiesStorage()
    private var relations = RelationsStorage()
    
}


extension Repository {
    func all<T>() -> [T] {
        entities.all()
    }
    
    func find<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entities.find(id)
    }
    
    func findAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entities.findAll(ids)
    }
    
    func findAllExisting<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T] {
        entities.findAllExisting(ids)
    }
    
    @discardableResult
    mutating func remove<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entities.remove(id)
    }
    
    @discardableResult
    mutating func removeAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entities.removeAll(ids)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T) {
        entities.save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T?) {
        entities.save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entities: [T]) {
        self.entities.save(entities)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: Relation<T>) {
        entities.save(relation)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<Relation<T>>) {
        entities.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<Relation<T>>)?) {
        entities.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: BiRelation<T>) {
        entities.save(relation)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<BiRelation<T>>) {
        entities.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<BiRelation<T>>)?) {
        entities.save(relations)
    }
}

extension Repository {
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(_ entityRelation: EntityRelation<T, E>) {
        relations.save(entityRelation)
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

extension Repository {
    func relations<T: IdentifiableEntity>(for type: T.Type, relationName: String, id: T.ID) -> Set<String> {
        relations.relations(for: type, relationName: relationName, id: id)
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
