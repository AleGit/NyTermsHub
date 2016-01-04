//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// [AM2015TRS, *Definition 2.1.14.*] A position is a finite sequence of positive integers.
/// The *root* position is the empty sequence and denoted by `ε`
/// and `p+q` denotes the concatenation of positions `p` and `q`.
/// We define binary relations <= , <, and || on positions as follows.
/// We say that position `p` is above position `q
/// if there exists a (necessarily unique) position `r` such that `p+r = q`.
/// In that case wedefine `q\p` as the position r.
/// If `p` is above q we also say that `q` is below p or p is a *prefix* of `q`, and we write `p` <= `q`.
/// We write `p < q` if `p <= q` and `p != q`. If `p < q` we say that `p` is a proper prefix of `q`.
/// Positions `p`, q are parallel, denoted by `p || q`, if neither `p <= q` nor `q <= p`.

struct Position {
    /// internal data
    private var hops : [Int]
    
    /// create a root position
    init() { hops = [Int]() }
    
    func decompose() -> (Int, Position)? {
        guard let (head, array) = hops.decompose else { return nil }
        
        return (head,Position(array))
    }
}

/// The *root* position is the empty sequence and denoted by `ε`
let ε = Position()

extension Position : Hashable { // : Equatable
    var hashValue : Int {
        return hops.description.hashValue
    }
}

// Equatable
func ==(lhs:Position, rhs:Position) -> Bool {
    return lhs.hops == rhs.hops
}

extension Position {
    init<S: SequenceType where S.Generator.Element == Int>(_ sequence:S) {
        
        assert(sequence.reduce(true) { $0 && ($1 > 0) }, "'\(sequence)' A position is a finite sequence of POSITIVE integers.")
        
        self.init()
        self.hops += sequence
    }
}

// `p + q` denotes the concatenation of positions `p` and `q`.
func +=<S : SequenceType where S.Generator.Element == Int>(inout lhs: Position, rhs: S) {
    
    assert(rhs.reduce(true) { $0 && ($1 > 0) }, "'\(rhs)' A position is a finite sequence of POSITIVE integers.")
    
    lhs.hops += rhs
}

func -(lhs:Position, rhs:Position) -> Position? {
    guard rhs <= lhs else { return nil }
    
    return Position(lhs.hops[rhs.hops.count..<lhs.hops.count])
}

/// If `p` is above q we also say that `q` is below p or p is a *prefix* of `q`, and we write `p` <= `q`.
func <= (lhs:Position, rhs:Position) -> Bool {
    guard lhs.hops.count <= rhs.hops.count else { return false }
    return lhs.hops[0..<lhs.count] == rhs.hops[0..<lhs.count]
}

/// We write `p < q` if `p <= q` and `p != q`. If `p < q` we say that `p` is a proper prefix of `q`.
func < (lhs:Position, rhs:Position) -> Bool {
    guard lhs.hops.count < rhs.hops.count else { return false }
    return lhs.hops[0..<lhs.count] == rhs.hops[0..<lhs.count]
}

/// Positions `p`, q are parallel, denoted by `p || q`, if neither `p <= q` nor `q <= p`.
func || (lhs:Position, rhs:Position) -> Bool {
    return !( lhs <= rhs ) && !( rhs <= lhs )
}


/// The index of a `Position` is just the index of the internal data.
extension Position : Indexable, MutableIndexable {
    var startIndex: Int { return self.hops.startIndex }
    var endIndex: Int { return self.hops.endIndex }
    subscript (index:Int) -> Int {
        get {return self.hops[index] }
        set { self.hops[index] = newValue }
    }
    
    /// typealias Index : ForwardIndexType
    /// var startIndex: Self.Index { get }
    /// var endIndex: Self.Index { get }
    /// subscript (position: Self.Index) -> Self._Element { get }
    ///
    /// subscript (position: Self.Index) -> Self._Element { get set }
}

/// The generater of a `Position` is just the generator of the internal data.
extension Position : SequenceType {
    func generate() -> IndexingGenerator<[Int]> {
        let g = self.hops.generate()
        return g
    }
    
    /// - func generate() -> Self.Generator
    /// - func underestimateCount() -> Int
    /// - map<T>(@noescape transform: (Self.Generator.Element) throws -> T) rethrows -> [T]
    /// - filter(@noescape includeElement: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.Generator.Element]
    /// - forEach(@noescape body: (Self.Generator.Element) throws -> ()) rethrows
    /// - dropFirst(n: Int) -> Self.SubSequence
    /// - dropLast(n: Int) -> Self.SubSequence
    /// - prefix(maxLength: Int) -> Self.SubSequence
    /// - suffix(maxLength: Int) -> Self.SubSequence
    /// - split(maxSplit: Int, allowEmptySlices: Bool, @noescape isSeparator: (Self.Generator.Element) throws -> Bool) rethrows -> [Self.SubSequence]
}

extension Position : CollectionType { // : Indexable, SequenceType
    // var count : Int { return hops.count }
    // var isEmpty : Bool { return hops.isEmpty }
    
    /// - func generate() -> Self.Generator
    /// - subscript (position: Self.Index) -> Self.Generator.Element { get }
    /// - subscript (bounds: Range<Self.Index>) -> Self.SubSequence { get }
    /// - func prefixUpTo(end: Self.Index) -> Self.SubSequence
    /// - func suffixFrom(start: Self.Index) -> Self.SubSequence
    /// - prefixThrough(position: Self.Index) -> Self.SubSequence
    /// - var isEmpty: Bool { get }
    /// - var count: Self.Index.Distance { get }
    /// - var first: Self.Generator.Element? { get }
    
}

extension Position : RangeReplaceableCollectionType {
    mutating func replaceRange<C : CollectionType where C.Generator.Element == Int>(subRange: Range<Index>, with newElements: C) {
        self.hops.replaceRange(subRange, with: newElements)
    }
    
    /// init()
    /// mutating func replaceRange<C : CollectionType where C.Generator.Element == Generator.Element>(subRange: Range<Self.Index>, with newElements: C)
    /// mutating func reserveCapacity(n: Self.Index.Distance)
    /// mutating func append(x: Self.Generator.Element)
    /// mutating func appendContentsOf<S : SequenceType where S.Generator.Element == Generator.Element>(newElements: S)
    /// mutating func insert(newElement: Self.Generator.Element, atIndex i: Self.Index)
    /// mutating func insertContentsOf<S : CollectionType where S.Generator.Element == Generator.Element>(newElements: S, at i: Self.Index)
    /// mutating func removeAtIndex(i: Self.Index) -> Self.Generator.Element
    /// mutating func removeFirst() -> Self.Generator.Element
    /// mutating func removeFirst(n: Int)
    /// mutating func removeRange(subRange: Range<Self.Index>)
    /// mutating func removeAll(keepCapacity keepCapacity: Bool)
}

extension Position : MutableCollectionType { // : MutableIndexable, CollectionType
    /// typealias SubSequence = MutableSlice<Self>
    /// subscript (position: Self.Index) -> Self.Generator.Element { get set }
    /// subscript (bounds: Range<Self.Index>) -> Self.SubSequence { get set }
}

extension Position : MutableSliceable { // :  CollectionType, MutableCollectionType
    /// subscript (_: Range<Self.Index>) -> Self.SubSequence { get set }
}

extension Position : ArrayLiteralConvertible {
    init(arrayLiteral elements: Int...) {
        self.hops = elements
    }

    /// typealias Element
    /// init(arrayLiteral elements: Self.Element...)
}

extension Position { // : _ArrayType { // : RangeReplaceableCollectionType, MutableSliceable, ArrayLiteralConvertible
    /// init(count: Int, repeatedValue: Self.Generator.Element)
    /// var count: Int { get }
    /// var capacity: Int { get }
    /// var isEmpty: Bool { get }
    /// subscript (index: Int) -> Self.Generator.Element { get set }
    /// mutating func reserveCapacity(minimumCapacity: Int)
    /// func +=<S : SequenceType where S.Generator.Element == Generator.Element>(inout lhs: Self, rhs: S)
    /// mutating func insert(newElement: Self.Generator.Element, atIndex i: Int)
    /// mutating func removeAtIndex(index: Int) -> Self.Generator.Element
    /// init(_ buffer: Self._Buffer)
}

extension Position : CustomStringConvertible {
    
    var description : String {
        guard !hops.isEmpty else  { return "ε" }
        
        return hops.joinWithSeparator(".")
    }
    
}

extension Position : StringLiteralConvertible {
    // UnicodeScalarLiteralConvertible
    // typealias UnicodeScalarLiteralType = StringLiteralType
    init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    // ExtendedGraphemeClusterLiteralConvertible:UnicodeScalarLiteralConvertible
    // typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    // StringLiteralConvertible:ExtendedGraphemeClusterLiteralConvertible
    // typealias StringLiteralType
    init(stringLiteral value: StringLiteralType) {
        self.init()
        
        var remainder = value
        while !remainder.isEmpty {
            var head = remainder
            if let range = remainder.rangeOfString(".") {
                head = remainder[remainder.startIndex..<range.startIndex]
                remainder.removeRange(remainder.startIndex..<range.endIndex)
            }
            else {
                remainder.removeAll()
            }
            
            if let hop = Int(head) {
                assert(hop > 0, "'\(value)' A position is a finite sequence of POSITIVE integers.")
                self.hops.append(hop)
            }
            else {
                assert(head == "ε", "'\(value)' The root position is the empty sequence and denoted by ε.")
                break
            }
        }
    }
}



// MARK: - Array + Position

extension Array where Element:Node {
    /// Get term at position in array. (for convenience)
    /// array[[i]] := array[i-1]
    /// array[[i,j,...]] := array[i-1][j,...]
    subscript(position:Position)->Element? {
        guard let (head,tail) = position.decompose() else { return nil }        // position == [], but an array is not of type Node
        // position != []
        if head < 1 || head >= self.count { return nil }                        // array does not have element at given position
        
        let term = self[head-1]                                // subnode at position `first` is at index `first-1`
        return term[tail]
    }
}