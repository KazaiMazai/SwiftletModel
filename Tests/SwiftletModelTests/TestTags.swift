//
//  TestTags.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import Testing

extension Tag {
    @Tag static var query: Self
    @Tag static var sort: Self
    @Tag static var filter: Self
    @Tag static var encoding: Self
    @Tag static var decoding: Self
    @Tag static var coding: Self
    @Tag static var relations: Self
    @Tag static var toOne: Self
    @Tag static var toMany: Self
    @Tag static var oneWay: Self
    @Tag static var mutual: Self
    @Tag static var delete: Self
    @Tag static var metadata: Self
    @Tag static var index: Self
    @Tag static var indexes: Self
    @Tag static var hashIndex: Self
    @Tag static var uniqueIndex: Self
    @Tag static var fullTextSearchIndex: Self
    @Tag static var mergeStrategy: Self
}
