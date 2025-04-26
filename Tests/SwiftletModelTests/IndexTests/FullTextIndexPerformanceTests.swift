//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

@testable import SwiftletModel
import Foundation
import XCTest

final class FullTextIndexPerformanceTests: XCTestCase {
    var context = Context()

    lazy var indexedModels = {
        TestingModels.StringFullTextIndexed.shuffled()
    }()

    lazy var notIndexeddModels = {
        TestingModels.StringNotIndexed.shuffled()
    }()

    override func setUp() async throws {
        context = Context()

        try indexedModels
            .forEach { try $0.save(to: &context) }

        try notIndexeddModels
            .forEach { try $0.save(to: &context) }
    }

    func test_RawContainTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.StringNotIndexed
                .query(in: context)
                .resolve()
                .filter {
                    $0.text.contains("banan", caseSensitive: false)
                }
        }
    }

    func test_IndexedContainsTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.StringFullTextIndexed
                .filter(.string(\.text, contains: "banan"), in: context)
                .resolve()
        }
    }

    func test_NotIndexedContainsTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.StringNotIndexed
                .filter(.string(\.text, contains: "banan"), in: context)
                .resolve()
        }
    }

    func test_IndexedMatchTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.StringFullTextIndexed
                .filter(.string(\.text, matches: "banan"), in: context)
                .resolve()
        }
    }

    func test_NotIndexedMatchTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.StringNotIndexed
                .filter(.string(\.text, matches: "banan"), in: context)
                .resolve()
        }
    }

    func test_RawMatchTextFilter_FilterPerformance() throws {
        measure {
            let tokens = "banan".makeTokens()
            _ = TestingModels.StringNotIndexed
                .query(in: context)
                .resolve()
                .filter {
                    $0.text.matches(tokens: tokens)
                }
        }
    }

    func test_NoIndex_SavePerformance() throws {
        let models = notIndexeddModels

        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }

    func test_Indexed_SavePerformance() throws {
        let models = indexedModels

        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }
}

