//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 30/03/2025.
//

import SwiftletModel
import Foundation
import XCTest

final class SortIndexPerformanceTests: XCTestCase {
    var count: Int { 2000 }
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.SingleValueIndexed.shuffled(count)
    }()

    lazy var evalPropertyIndexedModels = {
        TestingModels.EvaluatedPropertyDescIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }

        try evalPropertyIndexedModels
            .forEach { try $0.save(to: &context) }
    }

    func test_NoIndex_SortPerformance() throws {
        let queries: QueryList<TestingModels.NotIndexed> = TestingModels.NotIndexed.query()
        measure {
            _ = queries
                .sorted(by: \.numOf1)
                .resolve(context)
        }
    }

    func test_Indexed_SortPerformance() throws {
        let queries: QueryList<TestingModels.SingleValueIndexed> = TestingModels.SingleValueIndexed.query()
        measure {
            _ = queries
                .sorted(by: \.numOf1)
                .resolve(context)
        }
    }

    func test_EvalProperyIndexed_SortPerformance() throws {
        let queries: QueryList<TestingModels.EvaluatedPropertyDescIndexed> = TestingModels.EvaluatedPropertyDescIndexed.query()
        measure {
            _ = queries
                .sorted(by: \.numOf1.desc)
                .resolve(context)
        }
    }

    func test_NoIndex_SavePerformance() throws {
        let models = notIndexedModels

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

    func test_EvaluatedPropertyIndexed_SavePerformance() throws {
        let models = evalPropertyIndexedModels

        measure {
            var context = Context()
            try! models.forEach { try $0.save(to: &context) }
        }
    }
}
