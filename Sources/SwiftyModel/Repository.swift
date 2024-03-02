//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

struct Repository {
    private var entitiesRepository = EntitiesRepository()
    private var relationsRepository = RelationsRepository()
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
    
    func all<T>() -> [T] {
        entitiesRepository.all()
    }
    
    func find<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entitiesRepository.find(id)
    }
    
    func findAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.findAll(ids)
    }
    
    func findAllExisting<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T] {
        entitiesRepository.findAllExisting(ids)
    }
}

extension Repository {
    
    @discardableResult
    mutating func remove<T: IdentifiableEntity>(_ id: T.ID) -> T? {
        entitiesRepository.remove(id)
    }
    
    @discardableResult
    mutating func removeAll<T: IdentifiableEntity>(_ ids: [T.ID]) -> [T?] {
        entitiesRepository.removeAll(ids)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T) {
        entitiesRepository.save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entity: T?) {
        entitiesRepository.save(entity)
    }
    
    mutating func save<T: IdentifiableEntity>(_ entities: [T]) {
        self.entitiesRepository.save(entities)
    }
}

extension Repository {
    
    mutating func save<T: IdentifiableEntity>(_ relation: Relation<T>) {
        entitiesRepository.save(relation)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<Relation<T>>) {
        entitiesRepository.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<Relation<T>>)?) {
        entitiesRepository.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relation: BiRelation<T>) {
        entitiesRepository.save(relation)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: some Collection<BiRelation<T>>) {
        entitiesRepository.save(relations)
    }
    
    mutating func save<T: IdentifiableEntity>(_ relations: (any Collection<BiRelation<T>>)?) {
        entitiesRepository.save(relations)
    }
}

extension Repository {
    mutating func save<T: IdentifiableEntity, E: IdentifiableEntity>(_ entityRelation: EntityRelation<T, E>) {
        relationsRepository.save(entityRelation)
    }
}

 

extension Repository {
    func findRelations<T: IdentifiableEntity>(for type: T.Type, relationName: String, id: T.ID) -> Set<String> {
        relationsRepository.findRelations(for: type, relationName: relationName, id: id)
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
