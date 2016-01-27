//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

// MARK: - Range

extension Range where Element : Comparable {
    /// expands range if value is not in range
    /// - successor `struct Range<Element : ForwardIndexType>`
    ///
    /// - `func min<T : Comparable>(x: T, _ y: T) -> T`
    ///
    /// - `func max<T : Comparable>(x: T, _ y: T) -> T`
    mutating func insert(value:Element) {
        guard !self.contains(value) else { return }
        
        self.startIndex = min(self.startIndex, value)
        self.endIndex = max(self.endIndex, value.successor())
    }
}

extension Range where Element : Hashable, Element: Comparable {
    /// create range such that all elements in the set are in the range
    init?(set: Set<Element>) {
        guard let minimum = set.minElement() else { return nil }
        guard let maximum = set.maxElement() else { return nil }
        
        assert (minimum <= maximum)
        
        self.init(start:minimum, end:maximum.successor())
    }
}

// MARK: - Dictionary

extension Dictionary {
    // get all keys where the values match a predicate
    func filteredKeys(predicate : (Element)->Bool) -> [Key] {
        return self.filter { predicate($0) }.map { $0.0 }
    }
}


// MARK: - String
extension String  {
    func contains(string:Symbol) -> Bool {
        return self.rangeOfString(string) != nil
    }
    func containsOne<S:SequenceType where S.Generator.Element == Symbol>(strings:S) -> Bool {
        return strings.reduce(false) { $0 || self.contains($1) }
    }
    func containsAll<S:SequenceType where S.Generator.Element == Symbol>(strings:S) -> Bool {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}

// MARK: - Array

extension Array where Element : CustomStringConvertible {
    /// Concatinate descriptions of elements separated by separator.
    func joinWithSeparator(separator:String) -> String {
        return self.map { $0.description }.joinWithSeparator(separator)
    }
}

extension Array {
    func decompose() -> (Element, [Element])? {
        return isEmpty ? nil : (self[startIndex], Array(self.dropFirst()))
    }
}

// MARK: - Sequence Type

extension SequenceType {
    func all(predicate: Generator.Element -> Bool) -> Bool {
        for x in self where !predicate(x) {
            return false
        }
        return true
    }
}