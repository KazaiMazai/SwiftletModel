//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 09/03/2025.
//

import Foundation

//public enum ResolveDuplicates {
//    case upsert
//    case `throw`
//}

enum IndexType<Entity: EntityModelProtocol> {
    case sort
    case unique(CollisionResolver<Entity>)
}
