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

extension Range where Element: Comparable {
    /// create range such that all elements in the sequence are in the range
    init?<S:SequenceType where S.Generator.Element == Element>(sequence: S) {
        guard let
            minimum = sequence.minElement(),
            maximum = sequence.maxElement()
            else { return nil }
        assert (minimum <= maximum)
        
        self.init(start:minimum, end:maximum.successor())
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

extension CFTimeInterval {
    static let hour = 3600.0
    static let minute = 60.0
    static let second = 1.0
    static let ms = 0.001
    static let µs = 0.000_001
    static let ns = 0.000_000_001
    static let units = [
        hour : "h",
        minute : "m",
        second : "s",
        ms: "ms",
        µs : "µs",
        ns : "ns"
    ]
    
    var prettyTimeIntervalDescription : String {
        var t = self
        switch self {
        case _ where floor(t/CFAbsoluteTime.hour) > 0:
            t += 0.5*CFAbsoluteTime.minute // round minute
            let hour = t/CFAbsoluteTime.hour
            t -= floor(hour)*CFAbsoluteTime.hour
            let minute = t/CFAbsoluteTime.minute
            return "\(Int(hour))\(CFAbsoluteTime.units[CFAbsoluteTime.hour]!)" + " \(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)"
            
        case _ where floor(t/CFAbsoluteTime.minute) > 0:
            t += 0.5*CFAbsoluteTime.second // round second
            let minute = t/CFAbsoluteTime.minute
            t -= floor(minute)*CFAbsoluteTime.minute
            let second = t/CFAbsoluteTime.second
            return "\(Int(minute))\(CFAbsoluteTime.units[CFAbsoluteTime.minute]!)" + " \(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)"
            
        case _ where floor(t/CFAbsoluteTime.second) > 0:
            t += 0.5*CFAbsoluteTime.ms // round ms
            let second = t/CFAbsoluteTime.second
            t -= floor(second)*CFAbsoluteTime.second
            let ms = t/CFAbsoluteTime.ms
            return "\(Int(second))\(CFAbsoluteTime.units[CFAbsoluteTime.second]!)" + " \(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)"
            
        case _ where floor(t/CFAbsoluteTime.ms) > 0:
            t += 0.5*CFAbsoluteTime.µs // round µs
            let ms = t/CFAbsoluteTime.ms
            t -= floor(ms)*CFAbsoluteTime.ms
            let µs = t/CFAbsoluteTime.µs
            return "\(Int(ms))\(CFAbsoluteTime.units[CFAbsoluteTime.ms]!)" + " \(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)"
            
        case _ where floor(t/CFAbsoluteTime.µs) > 0:
            t += 0.5*CFAbsoluteTime.ns // round µs
            let µs = t/CFAbsoluteTime.µs
            t -= floor(µs)*CFAbsoluteTime.µs
            let ns = t/CFAbsoluteTime.ns
            return "\(Int(µs))\(CFAbsoluteTime.units[CFAbsoluteTime.µs]!)" + " \(Int(ns))\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        default:
            let ns = t/CFAbsoluteTime.ns
            return "\(ns)\(CFAbsoluteTime.units[CFAbsoluteTime.ns]!)"
            
        }
    }
}

extension UInt64 {
    private static let prefixedByteUnits = ["B", "KiB", "MiB" // , "GiB", "TiB"
    ]
    
    var prettyByteDescription : String {
        var dividend = self
        let divisor = 1024 as UInt64
        
        guard dividend != 0 else {
            return "0 B"
        }
        
//        guard dividend > 0 else {
//            return "-" + (-self).prettyByteDescription
//        }
        
        var index = 0
        
        while dividend/divisor > 0 && index < (UInt64.prefixedByteUnits.count-1) {
            let remainder = dividend % divisor
            let quotient = dividend % divisor
            
            
            index += 1
            dividend = quotient + remainder > (divisor/2) ? 1 : 0
        }
        
        return "\(dividend) \(UInt64.prefixedByteUnits[index])"
    }
}

