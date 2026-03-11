//
//  FilterBooleanTests.swift
//  SwiftletModel
//
//  Created for Swift Testing migration.
//

import SwiftletModel
import Foundation
import Testing

@Suite("Filter Boolean", .tags(.query, .filter))
struct FilterBooleanTests {
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

    @Test("Filter isActive == true without index equals plain filtering")
    func whenFilterActiveTrueNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.isActive == true }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter isActive == true with index equals plain filtering")
    func whenFilterActiveTrueIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.isActive == true }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter isActive == false without index equals plain filtering")
    func whenFilterActiveFalseNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.isActive == false }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive == false)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter isActive == false with index equals plain filtering")
    func whenFilterActiveFalseIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.isActive == false }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == false)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter isActive != true (negation) without index equals plain filtering")
    func whenFilterActiveNotTrueNoIndex_ThenEqualPlainFiltering() throws {
        let (context, _, notIndexed) = try makeContext()
        let expected = notIndexed.filter { $0.isActive != true }

        let filterResult = TestingModels.NotIndexed.RichProperty
            .filter(\.isActive != true)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Filter isActive != true (negation) with index equals plain filtering")
    func whenFilterActiveNotTrueIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.isActive != true }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive != true)
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Boolean AND combination filter equals plain filtering")
    func whenBooleanAndCombinationFilter_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.isActive == true && $0.age > 50 }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .filter(\.age > 50)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test("Boolean OR combination filter equals plain filtering")
    func whenBooleanOrCombinationFilter_ThenEqualPlainFiltering() throws {
        let (context, indexed, _) = try makeContext()
        let expected = indexed.filter { $0.isActive == true || $0.age < 10 }

        let filterResult = TestingModels.Indexed.RichProperty
            .filter(\.isActive == true)
            .or(.filter(\.age < 10))
            .resolve(in: context)

        #expect(!filterResult.isEmpty)
        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }
}
