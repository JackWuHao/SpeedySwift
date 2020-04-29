//
//  CollectionExtensions.swift
//  SpeedySwift
//
//  Created by Quinn Von on 19.12.16.
//  Copyright © 2016 SpeedySwift
//

#if canImport(Foundation)
import Foundation
#endif

// MARK: - Methods
public extension Collection {

    /// 并行遍历
    ///
    ///        array.forEachInParallel { item in
    ///            print(item)
    ///        }
    ///
    /// - Parameter each: closure to run for each element.
    public func forEachInParallel(_ each: (Self.Element) -> Void) {
        let indicesArray = Array(indices)

        DispatchQueue.concurrentPerform(iterations: indicesArray.count) { (index) in
            let elementIndex = indicesArray[index]
            each(self[elementIndex])
        }
    }

    /// 保护数组不越界
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: index of element to access element.
    public subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

}

// MARK: - Methods (Int)
public extension Collection where Index == Int {

    /// 返回第一个满足条件的值的索引
    ///
    ///        [1, 7, 1, 2, 4, 1, 6].firstIndex { $0 % 2 == 0 } -> 3
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: first index where the specified condition evaluates to true. (optional)
    public func firstIndex(where condition: (Element) throws -> Bool) rethrows -> Index? {
        for (index, value) in lazy.enumerated() where try condition(value) {
            return index
        }
        return nil
    }

    /// 返回最后一个满足条件的值的索引
    ///
    ///     [1, 7, 1, 2, 4, 1, 8].lastIndex { $0 % 2 == 0 } -> 6
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: last index where the specified condition evaluates to true. (optional)
    public func lastIndex(where condition: (Element) throws -> Bool) rethrows -> Index? {
        for (index, value) in lazy.enumerated().reversed() where try condition(value) {
            return index
        }
        return nil
    }

    /// 返回所有满足条件的值的索引
    ///
    ///     [1, 7, 1, 2, 4, 1, 8].indices(where: { $0 == 1 }) -> [0, 2, 5]
    ///
    /// - Parameter condition: condition to evaluate each element against.
    /// - Returns: all indices where the specified condition evaluates to true. (optional)
    public func indices(where condition: (Element) throws -> Bool) rethrows -> [Index]? {
        var indicies: [Index] = []
        for (index, value) in lazy.enumerated() where try condition(value) {
            indicies.append(index)
        }
        return indicies.isEmpty ? nil : indicies
    }

    /// 按照条件切割
    ///
    ///     [0, 2, 4, 7].forEach(slice: 2) { print($0) } -> //print: [0, 2], [4, 7]
    ///     [0, 2, 4, 7, 6].forEach(slice: 2) { print($0) } -> //print: [0, 2], [4, 7], [6]
    ///
    /// - Parameters:
    ///   - slice: size of array in each interation.
    ///   - body: a closure that takes an array of slice size as a parameter.
    public func forEach(slice: Int, body: ([Element]) throws -> Void) rethrows {
        guard slice > 0, !isEmpty else { return }

        var value: Int = 0
        while value < count {
            try body(Array(self[Swift.max(value, startIndex)..<Swift.min(value + slice, endIndex)]))
            value += slice
        }
    }

    /// 按照条件组中组
    ///
    ///     [0, 2, 4, 7].group(by: 2) -> [[0, 2], [4, 7]]
    ///     [0, 2, 4, 7, 6].group(by: 2) -> [[0, 2], [4, 7], [6]]
    ///
    /// - Parameter size: The size of the slices to be returned.
    /// - Returns: grouped self.
    public func group(by size: Int) -> [[Element]]? {
        //Inspired by: https://lodash.com/docs/4.17.4#chunk
        guard size > 0, !isEmpty else { return nil }
        var value: Int = 0
        var slices: [[Element]] = []
        while value < count {
            slices.append(Array(self[Swift.max(value, startIndex)..<Swift.min(value + size, endIndex)]))
            value += size
        }
        return slices
    }

}

public extension Collection where Element: Equatable, Index == Int {

    /// 数组中查询到的第一个元素的索引.
    ///
    ///        [1, 2, 2, 3, 4, 2, 5].firstIndex(of: 2) -> 1
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].firstIndex(of: 6.5) -> nil
    ///        ["h", "e", "l", "l", "o"].firstIndex(of: "l") -> 2
    ///
    /// - Parameter item: item to check.
    /// - Returns: first index of item in array (if exists).
    public func firstIndex(of item: Element) -> Index? {
        for (index, value) in lazy.enumerated() where value == item {
            return index
        }
        return nil
    }

    /// 数组中查询到的最后一个元素的索引.
    ///
    ///        [1, 2, 2, 3, 4, 2, 5].lastIndex(of: 2) -> 5
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].lastIndex(of: 6.5) -> nil
    ///        ["h", "e", "l", "l", "o"].lastIndex(of: "l") -> 3
    ///
    /// - Parameter item: item to check.
    /// - Returns: last index of item in array (if exists).
    public func lastIndex(of item: Element) -> Index? {
        for (index, value) in lazy.enumerated().reversed() where value == item {
            return index
        }
        return nil
    }

}

// MARK: - Methods (Integer)
public extension Collection where Element == IntegerLiteralType, Index == Int {

    /// 平均值
    ///
    /// - Returns: the average of the array's elements.
    public func average() -> Double {
        // http://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
        return isEmpty ? 0 : Double(reduce(0, +)) / Double(count)
    }

}

// MARK: - Methods (FloatingPoint)
public extension Collection where Element: FloatingPoint {

    /// 平均值
    ///
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].average() = 3.18
    ///
    /// - Returns: average of the array's elements.
    public func average() -> Element {
        guard !isEmpty else { return 0 }
        return reduce(0, {$0 + $1}) / Element(count)
    }

}
