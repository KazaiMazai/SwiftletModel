//
//  FilterEnumTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Enum", .tags(.query, .filter))
struct FilterEnumTests {
    let count = 100

    var indexedModels: [TestingModels.Indexed.RichProperty] {
        TestingModels.Indexed.RichProperty.shuffled(count)
    }

    var notIndexedModels: [TestingModels.NotIndexed.RichProperty] {
        TestingModels.NotIndexed.RichProperty.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, indexed: [TestingModels.Indexed.RichProperty], notIndexed: [TestingModels.NotIndexed.RichProperty]) {
        var context = Context()
        let indexed = indexedModels
        let notIndexed = notIndexedModels

        try indexed.forEach { try $0.save(to: &context) }
        try notIndexed.forEach { try $0.save(to: &context) }

        return (context, indexed, notIndexed)
    }

    @Test("Filter status == .published without index equals plain filtering")
    func whenFilterStatusPublishedNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.status == .published }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status == .published)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter status == .published with index equals plain filtering")
    func whenFilterStatusPublishedIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.status == .published }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.status == .published)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter status == .draft without index equals plain filtering")
    func whenFilterStatusDraftNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.status == .draft }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status == .draft)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter status == .archived with index equals plain filtering")
    func whenFilterStatusArchivedIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.status == .archived }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.status == .archived)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter status != .draft without index equals plain filtering")
    func whenFilterStatusNotDraftNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.status != .draft }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status != .draft)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter status != .draft with index equals plain filtering")
    func whenFilterStatusNotDraftIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.status != .draft }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.status != .draft)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multiple enum values with OR without index equals plain filtering")
    func whenFilterMultipleEnumOrNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.status == .published || $0.status == .archived }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.status == .published)
            .or(TestingModels.NotIndexed.RichProperty.filter(\.status == .archived))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Multiple enum values with OR with index equals plain filtering")
    func whenFilterMultipleEnumOrIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.status == .published || $0.status == .archived }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.status == .published)
            .or(TestingModels.Indexed.RichProperty.filter(\.status == .archived))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Enum with AND combination filter equals plain filtering")
    func whenEnumAndCombinationFilter_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.status == .published && $0.isActive == true }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.status == .published)
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
