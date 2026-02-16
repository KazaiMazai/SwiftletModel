//
//  ArrayExtensionsTests.swift
//  SwiftletModel
//
//  Created by Serge Kazakov on 17/11/2025.
//

@testable import SwiftletModel
import Foundation
import Testing

@Suite
struct ArrayExtensionsTests {

    // MARK: - removingDuplicates(by:) tests

    @Test("Empty array returns empty after removing duplicates")
    func removingDuplicates_WhenArrayIsEmpty_ThenReturnsEmptyArray() {
        let emptyArray: [Int] = []
        let result = emptyArray.removingDuplicates(by: { $0 })

        #expect(result == [])
    }

    @Test("Array without duplicates returns unchanged")
    func removingDuplicates_WhenArrayHasNoDuplicates_ThenReturnsOriginalArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test("Array with duplicates returns deduplicated")
    func removingDuplicates_WhenArrayHasDuplicates_ThenReturnsDeduplicated() {
        let array = [1, 2, 3, 2, 4, 3, 5]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test("Array with all duplicates returns single element")
    func removingDuplicates_WhenArrayHasAllDuplicates_ThenReturnsSingleElement() {
        let array = [1, 1, 1, 1, 1]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == [1])
    }

    @Test("Single element array returns unchanged")
    func removingDuplicates_WhenArrayHasSingleElement_ThenReturnsSingleElement() {
        let array = [42]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == [42])
    }

    @Test("Removing duplicates preserves first occurrence")
    func removingDuplicates_WhenRemovingDuplicates_ThenPreservesFirstOccurrence() {
        let array = [1, 2, 3, 2, 4, 3, 5, 1]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test("Custom key deduplication keeps first occurrence per key")
    func removingDuplicates_WhenUsingCustomKey_ThenDeduplicatesByKey() {
        struct Person {
            let id: Int
            let name: String
        }

        let people = [
            Person(id: 1, name: "Alice"),
            Person(id: 2, name: "Bob"),
            Person(id: 1, name: "Alice Updated"),
            Person(id: 3, name: "Charlie")
        ]

        let result = people.removingDuplicates(by: { $0.id })

        #expect(result.count == 3)
        #expect(result[0].id == 1)
        #expect(result[0].name == "Alice")
        #expect(result[1].id == 2)
        #expect(result[2].id == 3)
    }

    @Test("String deduplication removes duplicate strings")
    func removingDuplicates_WhenUsingStringKey_ThenDeduplicatesByString() {
        let array = ["apple", "banana", "apple", "cherry", "banana", "date"]
        let result = array.removingDuplicates(by: { $0 })

        #expect(result == ["apple", "banana", "cherry", "date"])
    }

    // MARK: - limit(_:offset:) tests

    @Test("Empty array returns empty with limit")
    func limit_WhenArrayIsEmpty_ThenReturnsEmptyArray() {
        let emptyArray: [Int] = []
        let result = emptyArray.limit(5, offset: 0)

        #expect(result == [])
    }

    @Test("Zero offset returns first elements")
    func limit_WhenOffsetIsZero_ThenReturnsFirstElements() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let result = array.limit(3, offset: 0)

        #expect(result == [1, 2, 3])
    }

    @Test("Non-zero offset returns elements from offset")
    func limit_WhenOffsetIsNonZero_ThenReturnsElementsFromOffset() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let result = array.limit(3, offset: 5)

        #expect(result == [6, 7, 8])
    }

    @Test("Limit exceeding remaining returns all remaining")
    func limit_WhenLimitExceedsRemainingElements_ThenReturnsRemainingElements() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(10, offset: 2)

        #expect(result == [3, 4, 5])
    }

    @Test("Offset at end returns empty array")
    func limit_WhenOffsetIsAtEnd_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: 5)

        #expect(result == [])
    }

    @Test("Offset beyond array length returns empty")
    func limit_WhenOffsetExceedsArrayLength_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: 10)

        #expect(result == [])
    }

    @Test("Zero limit returns empty array")
    func limit_WhenLimitIsZero_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(0, offset: 0)

        #expect(result == [])
    }

    @Test("Negative limit returns empty array")
    func limit_WhenLimitIsNegative_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(-5, offset: 0)

        #expect(result == [])
    }

    @Test("Negative offset returns empty array")
    func limit_WhenOffsetIsNegative_ThenReturnsEmptyArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(3, offset: -1)

        #expect(result == [])
    }

    @Test("Limit of one returns single element")
    func limit_WhenLimitIsOne_ThenReturnsSingleElement() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(1, offset: 2)

        #expect(result == [3])
    }

    @Test("Single element array returns that element")
    func limit_WhenArrayHasSingleElement_ThenReturnsThatElement() {
        let array = [42]
        let result = array.limit(5, offset: 0)

        #expect(result == [42])
    }

    @Test("Full coverage returns entire array")
    func limit_WhenOffsetAndLimitCoverEntireArray_ThenReturnsEntireArray() {
        let array = [1, 2, 3, 4, 5]
        let result = array.limit(5, offset: 0)

        #expect(result == [1, 2, 3, 4, 5])
    }

    @Test("String array limit returns expected slice")
    func limit_WhenUsingStringArray_ThenWorksCorrectly() {
        let array = ["a", "b", "c", "d", "e", "f"]
        let result = array.limit(2, offset: 3)

        #expect(result == ["d", "e"])
    }

    @Test("Multiple calls produce consistent results")
    func limit_WhenCalledMultipleTimes_ThenProducesConsistentResults() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let result1 = array.limit(3, offset: 4)
        let result2 = array.limit(3, offset: 4)

        #expect(result1 == result2)
        #expect(result1 == [5, 6, 7])
    }

    @Test("Chained limits apply sequentially")
    func limit_WhenChaining_ThenWorksCorrectly() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

        let result = array.limit(6, offset: 2).limit(2, offset: 1)

        #expect(result == [4, 5])
    }
}
