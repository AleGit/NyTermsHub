//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

func measure<R>(f:()->R) -> (R, CFAbsoluteTime){
    let start = CFAbsoluteTimeGetCurrent()
    let result = f()
    let end = CFAbsoluteTimeGetCurrent()
    
    return (result, end-start)
}

func errorNumberAndDescription() -> (Int32,String) {
    let errorNumber = errno
    let cstring = strerror(errorNumber) // will always return a valid c string.
    guard let errorString = String.fromCString(cstring) else {
        let message = "Invalid Error Number: \(errorNumber) (this should be impossible)"
        return (errorNumber,message)
    }
    return (errorNumber,errorString)
}

// MARK: -

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

extension SequenceType where Generator.Element : Comparable {
    typealias E = Generator.Element
    func minMaxElementPair() -> (E,E)? {
        return self.reduce(nil) {
            (pair:(E,E)?, element:E) -> (E,E)? in
            guard let (inmin, inmax) = pair else {
                return (element,element) // first element of sequence is minimum and maximum so far
            }
            return (min(inmin,element), max(inmax,element))
        }
    }
}

extension Range where Element: Comparable {
    /// create range such that all elements in the sequence are in the range
    init?<S:SequenceType where S.Generator.Element == Element>(sequence: S) {
        guard let (minimum,maximum) = sequence.minMaxElementPair()
            else { return nil } // empty sequence has neihter minimum nor maximum.
        assert (minimum <= maximum)
        self = minimum...maximum
    }
}

// MARK: -

extension Dictionary {
    // get all keys where the values match a predicate
    func keys(predicate : (Element)->Bool) -> [Key] {
        return self.filter { predicate($0) }.map { $0.0 }
    }
}


// MARK: -
extension String  {
    func contains(string:StringSymbol) -> Bool {
        return self.rangeOfString(string) != nil
    }
    func containsOne<S:SequenceType where S.Generator.Element == StringSymbol>(strings:S) -> Bool {
        return strings.reduce(false) { $0 || self.contains($1) }
    }
    func containsAll<S:SequenceType where S.Generator.Element == StringSymbol>(strings:S) -> Bool {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}

// MARK: -

extension CollectionType
where Generator.Element : CustomStringConvertible {
    func joinWithSeparator(separator:String) -> String {
        return self.map { $0.description }.joinWithSeparator(separator)
    }
}

//extension CollectionType
//where Generator.Element == SubSequence.Generator.Element {
//    var decompose: (head: Generator.Element, tail: SubSequence)? {
//        guard let head = first else { return nil }
//        return (head, dropFirst())
//    }
//}

extension CollectionType
where Generator.Element == SubSequence.Generator.Element {
    var decompose: (head: Generator.Element, tail: [Generator.Element])? {
        guard let head = first else { return nil }
        return (head, Array(dropFirst()))
    }
}


// MARK: -

extension SequenceType {
    
    func all(predicate: Generator.Element -> Bool) -> Bool {
        return self.reduce(true) { $0 && predicate($1) }
    }
    
    func one(predicate: Generator.Element -> Bool) -> Bool {
        return self.reduce(false) { $0 || predicate($1) }
    }
    
    func count(predicate: Generator.Element -> Bool) -> Int {
        return self.reduce(0) { $0 + (predicate($1) ? 1 : 0) }
    }
}

// MARK: -


