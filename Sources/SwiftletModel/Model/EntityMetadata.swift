//
//  Metadata.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 19/04/2025.
//

import Foundation

@EntityModel
struct Metadata<Entity: EntityModelProtocol> {
    @Index<Self>(\.savedAt)
    var savedAtIndex
    
    var id: Entity.ID
    var createdAt: Date = .distantPast
    var savedAt: Date = .distantPast
    
    @Relationship
    var entity: Entity? = .none
    
    mutating func willSave(to context: inout Context) throws {
        savedAt = Date()
        if let existing = query(in: context).resolve() {
            
        }
            
    }
}
