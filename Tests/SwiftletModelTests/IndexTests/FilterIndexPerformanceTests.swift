//
//  File.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 02/04/2025.
//

import SwiftletModel
import Foundation
import XCTest

final class FilterPerformanceTests: XCTestCase {
    let count = 5000
    var context = Context()

    lazy var notIndexedModels = {
        TestingModels.NotIndexed.shuffled(count)
    }()

    lazy var indexedModels = {
        TestingModels.ExtensivelyIndexed.shuffled(count)
    }()

    override func setUp() async throws {
        context = Context()
        try notIndexedModels
            .forEach { try $0.save(to: &context) }

        try indexedModels
            .forEach { try $0.save(to: &context) }
    }

    func test_NoIndex_FilterPerformance() throws {
        measure {
            _ = TestingModels.NotIndexed
                .filter(\.numOf1 == 1, in: context)
                .resolve(context)
        }
    }

    func test_Indexed_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .filter(\.numOf1 == 1, in: context)
                .resolve(context)
        }
    }

    func test_RawFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .query(in: context)
                .resolve(context)
                .filter {
                    $0.numOf1 == 1
                }
        }
    }

    func test_NotIndexedComplexFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.NotIndexed
                .filter(\.numOf1 == 1, in: context)
                .filter(\.numOf10 != 5)
                .filter(\.numOf100 == 4)
                .filter(\.numOf1000 == 2)
                .resolve(context)
        }
    }

    func test_IndexedComplexFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .filter(\.numOf1 == 1, in: context)
                .filter(\.numOf10 != 5)
                .filter(\.numOf100 == 4)
                .filter(\.numOf1000 == 2)
                .resolve(context)
        }
    }

    func test_RawComplexFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .query(in: context)
                .resolve(context)
                .filter {
                    $0.numOf1 == 1
                    && $0.numOf10 != 5
                    && $0.numOf100 == 4
                    && $0.numOf1000 == 2
                }
        }
    }

    func test_IndexedComplexComparisonFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .filter(\.numOf1 >= 1, in: context)
                .filter(\.numOf10 <= 5)
                .filter(\.numOf100 > 4)
                .filter(\.numOf1000 < 2)
                .resolve(context)
        }
    }

    func test_RawComplexComparisonFilter_FilterPerformance() throws {
        measure {
            _ = TestingModels.ExtensivelyIndexed
                .query(in: context)
                .resolve(context)
                .filter {
                    $0.numOf1 >= 1
                    && $0.numOf10 <= 5
                    && $0.numOf100 > 4
                    && $0.numOf1000 < 2
                }
        }
    }
}

