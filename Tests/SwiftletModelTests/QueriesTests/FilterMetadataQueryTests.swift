//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import XCTest

final class FilterMetadataQueryTests: XCTestCase {
    let count = 100
    var context = Context()

    lazy var indexedModels = {
        TestingModels.Indexed.Extensively.shuffled(count)
    }()

    override func setUpWithError() throws {
        context = Context()

        try indexedModels
            .forEach { try $0.save(to: &context) }

        // Wait to ensure initial saves have an older timestamp
        Thread.sleep(forTimeInterval: 1.0)
    }

    func test_WhenFilterIndexed_ThenEqualPlainFiltering() throws {
        let expected = indexedModels
            .filter { $0.numOf1 == 1 }

        let filterResult = TestingModels.Indexed.Extensively
            .filter(\.numOf1 == 1)
            .resolve(in: context)

        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(expected.map { $0.id }))
    }

    func test_WhenFilterByUpdatedAtRange_ThenReturnsRecentlyUpdatedModels() throws {
        // Given
        let modelsToUpdate = Array(indexedModels.prefix(5))
        try modelsToUpdate.forEach { try $0.save(to: &context) }

        let now = Date()
        let pastDate = now.addingTimeInterval(-0.5) // 0.5 seconds ago
        let range = pastDate...now

        // When
        let filterResult = TestingModels.Indexed.Extensively
            .filter(MetadataPredicate.updated(within: range))
            .resolve(in: context)

        // Then
        XCTAssertEqual(Set(filterResult.map { $0.id }),
                       Set(modelsToUpdate.map { $0.id }))

        // Verify that non-updated models are not included
        let nonUpdatedIds = Set(indexedModels.dropFirst(5).map { $0.id })
        let resultIds = Set(filterResult.map { $0.id })
        XCTAssertTrue(resultIds.isDisjoint(with: nonUpdatedIds))
    }

    func test_WhenFilterByUpdatedAtRange_WithPastRange_ThenReturnsNoModels() throws {
        // Given
        let twoDaysAgo = Date().addingTimeInterval(-172800) // 48 hours ago
        let oneDayAgo = Date().addingTimeInterval(-86400) // 24 hours ago
        let pastRange = twoDaysAgo...oneDayAgo

        // When
        let filterResult = TestingModels.Indexed.Extensively
            .filter(.updated(within: pastRange))
            .resolve(in: context)

        // Then
        XCTAssertTrue(filterResult.isEmpty)
    }

    func test_WhenLastThenFilterByUpdatedAtRange_ThenFiltersLastModel() throws {
        // Given
        let modelsToUpdate = Array(indexedModels.prefix(5))
        try modelsToUpdate.forEach { try $0.save(to: &context) }

        let now = Date()
        let pastDate = now.addingTimeInterval(-0.5) // 0.5 seconds ago
        let range = pastDate...now

        // When
        let filterResult = TestingModels.Indexed.Extensively
            .query()
            .sorted(by: .updatedAt)
            .last()
            .filter(MetadataPredicate.updated(within: range))
            .resolve(in: context)

        // Then
        XCTAssertNotNil(filterResult)
        XCTAssertEqual(filterResult?.id, modelsToUpdate.last?.id)
    }
}
