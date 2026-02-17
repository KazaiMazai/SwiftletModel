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
        TestingModels.Indexed.StringFullText.shuffled()
    }()

    lazy var notIndexeddModels = {
        TestingModels.NotIndexed.StringModel.shuffled()
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
            _ = TestingModels.NotIndexed.StringModel
                .query()
                .resolve(in: context)
                .filter {
                    $0.text.contains("banan", caseSensitive: false)
                }
        }
    }

    func test_IndexedContainsTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.Indexed.StringFullText
                .filter(.string(\.text, contains: "banan"))
                .resolve(in: context)
        }
    }

    func test_NotIndexedContainsTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.NotIndexed.StringModel
                .filter(.string(\.text, contains: "banan"))
                .resolve(in: context)
        }
    }

    func test_IndexedMatchTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.Indexed.StringFullText
                .filter(.string(\.text, matches: "banan"))
                .resolve(in: context)
        }
    }

    func test_NotIndexedMatchTextFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.NotIndexed.StringModel
                .filter(.string(\.text, matches: "banan"))
                .resolve(in: context)
        }
    }

    func test_RawMatchTextFilter_FilterPerformance() throws {
        measure {
            let tokens = "banan".makeTokens()
            _ = TestingModels.NotIndexed.StringModel
                .query()
                .resolve(in: context)
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

