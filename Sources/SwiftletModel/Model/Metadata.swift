//
//  MetadataIndex.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 21/04/2025.
//

public enum Metadata: String {
    case updatedAt

    var indexName: String {
        "\(Metadata.self).\(rawValue)"
    }
}
