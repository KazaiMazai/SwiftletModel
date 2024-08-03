//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 11/07/2024.
//

import Foundation

typealias Links<Parent: EntityModelProtocol, Child: EntityModelProtocol> = (direct: [Link<Parent, Child>],
                                                            inverse: [Link<Child, Parent>])

struct Link<Parent: EntityModelProtocol, Child: EntityModelProtocol> {
    let parent: Parent.ID
    let children: [Child.ID]
    let attribute: LinkAttribute
}

enum Option {
    case append
    case replace
    case remove
}

struct LinkAttribute {
    let name: String
    let updateOption: Option
}
