//  Copyright © 2016 Alexander Maringele. All rights reserved.

import Foundation

func measure<R>(f:()->R) -> (R, CFAbsoluteTime){
    let start = CFAbsoluteTimeGetCurrent()
    let result = f()
    let end = CFAbsoluteTimeGetCurrent()
    
    return (result, end-start)
}

func doitif(@autoclosure condition: ()->Bool, action:()->Void) {
    if condition() {
        action()
    }
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



extension SequenceType where Generator.Element : Hashable {
    typealias Element = Generator.Element
    
    var elementPlaces : [Element : [Int]] {
        var eo = [Element : [Int]]()
        for (index,value) in self.enumerate() {
            var array = eo[value] ?? [Int]()
            array.append(index)
            eo[value] = array
        }
        return eo
    }
    
    var elementCounts : [Element: Int] {
        var ec = [Element : Int]()
        for value in self {
            var count = ec[value] ?? 0
            count += 1
            ec[value] = count
        }
        
        return ec
    }
}

extension Array {
    
    func permuter<T:Hashable>() -> (
        (before:[T]) -> ( (after:[T]) -> [Element])
    )
    {
        return {
            (before) in return {
                (after) in return
                self.permute(before,after:after)
            }
            
        }
        
    }
    
    func permute<T:Hashable>(before:[T], after:[T]) -> [Element] {
        assert(Set(before) == Set(after))
        assert(before.count == after.count)
        assert(self.count == before.count)
        
        let beforeIndices = before.elementPlaces
        let afterIndices = after.elementPlaces
        
        var target = self
        
        for (key,sourceIndices) in beforeIndices {
            guard let targetIndices = afterIndices[key] else {
                assert(false)
                break
            }
            // assert(sourceIndices.count == targetIndices.count)
            if sourceIndices.count != targetIndices.count {
//                print(before, after)
//                print(beforeIndices, afterIndices)
//                print(sourceIndices, targetIndices)
            }
            
            for (sourceIndex, targetIndex) in zip(sourceIndices, targetIndices) {
                target[targetIndex] = self[sourceIndex]
            }
        }
        
        return target
    }
}

extension Set {
    mutating func uniqueify(inout member: Element) {
        guard let index = self.indexOf(member) else {
            self.insert(member)
            return
        }
        
        member = self[index]
    }
}

//extension Double {
//    init<I:IntegerType>(_ v:I) {
//        assert(false, "\(#function) \(v)")
//        self = 0.0
//    }
//}
//
//extension IntegerType {
//    init(_ v:Double) {
//        assert(false, "\(#function) \(v)")
//        self = 0
//    }
//}
//
//func percent<I:IntegerType>(dividend:I, divisor:I) -> I {
//    let result = 0.5 + 100.0 * (Double(dividend) / Double(divisor))
//    return I(result)
//}

func percent(dividend:Int, divisor:Int) -> Int {
    let result = 0.5 + 100.0 * (Double(dividend) / Double(divisor))
    return Int(result)
}


