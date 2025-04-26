//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 26/04/2025.
//

import XCTest
@testable import SwiftletModel

final class MergeStrategyTests: XCTestCase {
    
    struct TestModel: Equatable, Sendable {
        var id: Int
        var name: String?
        var numbers: [Int]?
        var tags: [String]
        var lastModified: Date
    }
    
    struct ComparableTestModel: Equatable, Sendable, Comparable {
        var id: Int
        var name: String?
        var numbers: [Int]?
        var tags: [String]
        var lastModified: Date
        
        static func < (lhs: MergeStrategyTests.ComparableTestModel,
                       rhs: MergeStrategyTests.ComparableTestModel) -> Bool {
            lhs.lastModified < rhs.lastModified
        }
    }
    
    func test_WhenUsingReplaceStrategy_ThenReturnsNewValue() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: nil, tags: ["b"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>.replace
        let result = strategy.merge(old, new)
        XCTAssertEqual(result, new)
    }
    
    func test_WhenPatchingOptionalProperty_ThenPreservesOldValueIfNewIsNil() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: nil, tags: ["b"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>.patch(\TestModel.name)
        let result = strategy.merge(old, new)
        
        XCTAssertEqual(result.name, "old")
    }
    
    func test_WhenPatchingOptionalValue_ThenKeepsOldValueIfNewIsNil() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge("old", nil)
        XCTAssertEqual(result, "old")
    }
    
    func test_WhenPatchingOptionalValue_ThenUsesNewValueIfPresent() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge(nil, "new")
        XCTAssertEqual(result, "new")
    }
    
    func test_WhenPatchingOptionalValue_ThenPreferencesNewValueOverOld() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge("old", "new")
        XCTAssertEqual(result, "new")
    }
    
    func test_WhenAppendingArrayProperty_ThenConcatenatesArrays() {
        let old = TestModel(id: 1, name: "old", numbers: nil, tags: ["a", "b"], lastModified: Date())
        let new = TestModel(id: 1, name: "new", numbers: nil, tags: ["c"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>.append(\TestModel.tags)
        let result = strategy.merge(old, new)
        
        XCTAssertEqual(result.tags, ["a", "b", "c"])
    }
    
    func test_WhenAppendingOptionalArrayProperty_ThenConcatenatesNonNilArrays() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>.append(\TestModel.numbers)
        let result = strategy.merge(old, new)
        
        XCTAssertEqual(result.numbers, [1, 2, 3])
    }
    
    func test_WhenAppendingOptionalArrayProperty_ThenPreservesExistingArrayIfNewIsNil() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let nilNew = TestModel(id: 1, name: nil, numbers: nil, tags: ["c"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>.append(\TestModel.numbers)
        let result = strategy.merge(old, nilNew)
        
        XCTAssertEqual(result.numbers, [1, 2])
    }
    
    func test_WhenUsingLastWriteWins_ThenAppliesStrategiesWhenNewIsHigher() {
        let oldDate = Date.distantPast
        let newDate = Date()
        
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: oldDate)
        let new = TestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: newDate)
        
        let strategy = MergeStrategy<TestModel>.lastWriteWins(
            .patch(\.name),
            .append(\.numbers),
            comparedBy: \.lastModified
        )
        
        let result = strategy.merge(old, new)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "new")
        XCTAssertEqual(result.numbers, [1, 2, 3])
    }
    
    func test_WhenUsingLastWriteWins_ThenAppliesStrategiesWhenOldIsHigher() {
        let oldDate = Date.distantPast
        let newDate = Date()
        
        let oldHigher = TestModel(id: 1, name: "older", numbers: [4], tags: ["c"], lastModified: newDate)
        let new = TestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: oldDate)
        
        let strategy = MergeStrategy<TestModel>.lastWriteWins(
            .patch(\.name),
            .append(\.numbers),
            comparedBy: \.lastModified
        )
        
        let result = strategy.merge(oldHigher, new)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "older")
        XCTAssertEqual(result.numbers, [3, 4])
        XCTAssertEqual(result.lastModified, newDate)
    }
    
    func test_WhenComparableUsingLastWriteWins_ThenAppliesStrategiesWhenOldIsHigher() {
        let oldDate = Date.distantPast
        let newDate = Date()
        
        let oldHigher = ComparableTestModel(id: 1, name: "older", numbers: [4], tags: ["c"], lastModified: newDate)
        let new = ComparableTestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: oldDate)
        
        let strategy = MergeStrategy<ComparableTestModel>.lastWriteWins(
            .patch(\.name),
            .append(\.numbers)
        )
        
        let result = strategy.merge(oldHigher, new)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "older")
        XCTAssertEqual(result.numbers, [3, 4])
        XCTAssertEqual(result.lastModified, newDate)
    }
    
    func test_WhenCombiningMultipleStrategies_ThenAppliesThemInOrder() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: [3], tags: ["b"], lastModified: Date())
        
        let strategy = MergeStrategy<TestModel>(
            .patch(\.name),
            .append(\.numbers)
        )
        
        let result = strategy.merge(old, new)
        XCTAssertEqual(result.id, 1)
        XCTAssertEqual(result.name, "old")
        XCTAssertEqual(result.numbers, [1, 2, 3])
    }
}

