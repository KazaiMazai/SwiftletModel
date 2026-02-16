//
//  File.swift
//  SwiftletModel
//
//  Created by Sergey Kazakov on 26/04/2025.
//

import Testing
@testable import SwiftletModel
import Foundation

@Suite
struct MergeStrategyTests {

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

        static func < (lhs: ComparableTestModel,
                       rhs: ComparableTestModel) -> Bool {
            lhs.lastModified < rhs.lastModified
        }
    }

    @Test
    func whenUsingReplaceStrategy_ThenReturnsNewValue() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: nil, tags: ["b"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>.replace
        let result = strategy.merge(old, new)
        #expect(result == new)
    }

    @Test
    func whenPatchingOptionalProperty_ThenPreservesOldValueIfNewIsNil() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: nil, tags: ["b"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>.patch(\TestModel.name)
        let result = strategy.merge(old, new)

        #expect(result.name == "old")
    }

    @Test
    func whenPatchingOptionalValue_ThenKeepsOldValueIfNewIsNil() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge("old", nil)
        #expect(result == "old")
    }

    @Test
    func whenPatchingOptionalValue_ThenUsesNewValueIfPresent() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge(nil, "new")
        #expect(result == "new")
    }

    @Test
    func whenPatchingOptionalValue_ThenPreferencesNewValueOverOld() {
        let strategy = MergeStrategy<String?>.patch()
        let result = strategy.merge("old", "new")
        #expect(result == "new")
    }

    @Test
    func whenAppendingArrayProperty_ThenConcatenatesArrays() {
        let old = TestModel(id: 1, name: "old", numbers: nil, tags: ["a", "b"], lastModified: Date())
        let new = TestModel(id: 1, name: "new", numbers: nil, tags: ["c"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>.append(\TestModel.tags)
        let result = strategy.merge(old, new)

        #expect(result.tags == ["a", "b", "c"])
    }

    @Test
    func whenAppendingOptionalArrayProperty_ThenConcatenatesNonNilArrays() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>.append(\TestModel.numbers)
        let result = strategy.merge(old, new)

        #expect(result.numbers == [1, 2, 3])
    }

    @Test
    func whenAppendingOptionalArrayProperty_ThenPreservesExistingArrayIfNewIsNil() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let nilNew = TestModel(id: 1, name: nil, numbers: nil, tags: ["c"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>.append(\TestModel.numbers)
        let result = strategy.merge(old, nilNew)

        #expect(result.numbers == [1, 2])
    }

    @Test
    func whenUsingLastWriteWins_ThenAppliesStrategiesWhenNewIsHigher() {
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
        #expect(result.id == 1)
        #expect(result.name == "new")
        #expect(result.numbers == [1, 2, 3])
    }

    @Test
    func whenUsingLastWriteWins_ThenAppliesStrategiesWhenOldIsHigher() {
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
        #expect(result.id == 1)
        #expect(result.name == "older")
        #expect(result.numbers == [3, 4])
        #expect(result.lastModified == newDate)
    }

    @Test
    func whenComparableUsingLastWriteWins_ThenAppliesStrategiesWhenOldIsHigher() {
        let oldDate = Date.distantPast
        let newDate = Date()

        let oldHigher = ComparableTestModel(id: 1, name: "older", numbers: [4], tags: ["c"], lastModified: newDate)
        let new = ComparableTestModel(id: 1, name: "new", numbers: [3], tags: ["b"], lastModified: oldDate)

        let strategy = MergeStrategy<ComparableTestModel>.lastWriteWins(
            .patch(\.name),
            .append(\.numbers)
        )

        let result = strategy.merge(oldHigher, new)
        #expect(result.id == 1)
        #expect(result.name == "older")
        #expect(result.numbers == [3, 4])
        #expect(result.lastModified == newDate)
    }

    @Test
    func whenCombiningMultipleStrategies_ThenAppliesThemInOrder() {
        let old = TestModel(id: 1, name: "old", numbers: [1, 2], tags: ["a"], lastModified: Date())
        let new = TestModel(id: 1, name: nil, numbers: [3], tags: ["b"], lastModified: Date())

        let strategy = MergeStrategy<TestModel>(
            .patch(\.name),
            .append(\.numbers)
        )

        let result = strategy.merge(old, new)
        #expect(result.id == 1)
        #expect(result.name == "old")
        #expect(result.numbers == [1, 2, 3])
    }
}
