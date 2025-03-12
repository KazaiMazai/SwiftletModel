//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation
 
enum IndexType<Entity: EntityModelProtocol> {
    case sort
    case unique(CollisionResolver<Entity>)
}
 
