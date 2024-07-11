//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 11/07/2024.
//

import Foundation

struct EntitiesAttachment<Parent: EntityModel, Child: EntityModel> {
    let parent: Parent.ID
    let children: [Child.ID]
    let direct: AttachmentAttribute
    let inverse: AttachmentAttribute?
}

enum Option {
    case append
    case replace
    case remove
}

struct AttachmentAttribute {
    let name: String
    let updateOption: Option
}
