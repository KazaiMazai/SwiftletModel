//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import Testing

@Suite
struct FilterMetadataQueryTests {
    let count = 100

    var indexedModels: [TestingModels.ExtensivelyIndexed] {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }

    private func makeContext() throws -> (context: Context, indexedModels: [TestingModels.ExtensivelyIndexed]) {
        var context = Context()
        let models = indexedModels

        try models.forEach { try $0.save(to: &context) }

        // Wait to ensure initial saves have an older timestamp
        Thread.sleep(forTimeInterval: 1.0)
        return (context, models)
    }

    @Test
    func whenFilterIndexed_ThenEqualPlainFiltering() throws {
        let (context, indexedModels) = try makeContext()
        let expected = indexedModels
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        #expect(Set(filterResult.map { $0.id }) == Set(expected.map { $0.id }))
    }

    @Test
    func whenFilterByUpdatedAtRange_ThenReturnsRecentlyUpdatedModels() throws {
        var (context, indexedModels) = try makeContext()
        // Given
        let modelsToUpdate = Array(indexedModels.prefix(5))
        try modelsToUpdate.forEach { try $0.save(to: &context) }

        let now = Date()
        let pastDate = now.addingTimeInterval(-0.5) // 0.5 seconds ago
        let range = pastDate...now

        // When
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(MetadataPredicate.updated(within: range))
            .resolve(in: context)

        // Then
        #expect(Set(filterResult.map { $0.id }) == Set(modelsToUpdate.map { $0.id }))

        // Verify that non-updated models are not included
        let nonUpdatedIds = Set(indexedModels.dropFirst(5).map { $0.id })
        let resultIds = Set(filterResult.map { $0.id })
        #expect(resultIds.isDisjoint(with: nonUpdatedIds))
    }

    @Test
    func whenFilterByUpdatedAtRange_WithPastRange_ThenReturnsNoModels() throws {
        let (context, _) = try makeContext()
        // Given
        let twoDaysAgo = Date().addingTimeInterval(-172800) // 48 hours ago
        let oneDayAgo = Date().addingTimeInterval(-86400) // 24 hours ago
        let pastRange = twoDaysAgo...oneDayAgo

        // When
        let filterResult = TestingModels.ExtensivelyIndexed
            .filter(.updated(within: pastRange))
            .resolve(in: context)

        // Then
        #expect(filterResult.isEmpty)
    }

    @Test
    func whenLastThenFilterByUpdatedAtRange_ThenFiltersLastModel() throws {
        var (context, indexedModels) = try makeContext()
        // Given
        let modelsToUpdate = Array(indexedModels.prefix(5))
        try modelsToUpdate.forEach { try $0.save(to: &context) }

        let now = Date()
        let pastDate = now.addingTimeInterval(-0.5) // 0.5 seconds ago
        let range = pastDate...now

        // When
        let filterResult = TestingModels.ExtensivelyIndexed
            .query()
            .sorted(by: .updatedAt)
            .last()
            .filter(MetadataPredicate.updated(within: range))
            .resolve(in: context)

        // Then
        #expect(filterResult != nil)
        #expect(filterResult?.id == modelsToUpdate.last?.id)
    }
}
