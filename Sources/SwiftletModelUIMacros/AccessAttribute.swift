//
//  AccessAttribute.swift
//  Crocodil
//
//  Created by Serge Kazakov on 30/06/2025.
//
import Foundation

enum AccessAttribute: String {
    case `private`
    case `fileprivate`
    case `internal`
    case `public`
    case `open`
    case missingAttribute = ""

    var name: String {
        rawValue
    }
}
