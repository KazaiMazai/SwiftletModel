//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

protocol IdentifiableEntity {
    associatedtype ID: Hashable & Codable & LosslessStringConvertible
    
    var id: ID { get }
    
    mutating func normalize()
}

extension IdentifiableEntity {
    func getEntity(in repository: Repository) -> Entity<Self> {
        Entity(repository: repository, id: id)
    }
    
    static func find(_ id: ID, in repository: Repository) -> Entity<Self> {
        repository.find(id)
    }
    
    static func find(_ ids: [ID], in repository: Repository) -> [Entity<Self>] {
        repository.find(ids)
    }
}



extension IdentifiableEntity {
    func normalized() -> Self {
        var copy = self
        copy.normalize()
        return copy
    }
}


extension KeyPath {
    var relationName: String {
        String(describing: self)
    }
}
