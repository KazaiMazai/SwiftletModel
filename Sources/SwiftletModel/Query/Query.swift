//
//  File.swift
//
//
//  Created by Sergey Kazakov on 02/03/2024.
//

import Foundation

public typealias Query<Entity: EntityModelProtocol> = Lazy<Entity, Optional<Entity>, Entity.ID>

public extension Lazy where Result == Optional<Entity>, Metadata == Entity.ID {
    init(context: Context, id: Entity.ID) {
        self.context = context
        self.metadata = id
        self.resolver = { context.find(id) }
    }
    
    func resolve() -> Entity? {
        resolver()
    }
    
    var id: Entity.ID {
        metadata
    }
}

//MARK: - Resolve Query Collection

public extension Collection {
    func resolve<Entity>() -> [Entity] where Element == Query<Entity> {
        compactMap { $0.resolve() }
    }
}

extension Lazy where Result == Optional<Entity>, Metadata == Entity.ID {
    
    init(context: Context, id: Entity.ID, resolver: @escaping () -> Entity?) {
        self.context = context
        self.metadata = id
        self.resolver = resolver
    }
    
    func whenResolved(then perform: @escaping (Entity) -> Entity?) -> Query<Entity> {
        Query(context: context, id: id) {
            guard let entity = resolve() else {
                return nil
            }
            
            return perform(entity)
        }
    }
}


extension Collection {
  func query<Entity>(in context: Context) -> [Query<Entity>] where Element == Entity, Entity: EntityModelProtocol {
      map { $0.query(in: context) }
  }
}
  
