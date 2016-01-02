//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

// MARK: - Position

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

struct Position : Hashable, CustomStringConvertible, StringLiteralConvertible {
    private var hops : [Int]
    
    init() {
        hops = [Int]()
    }
    
    func decompose() -> (Int, Position)? {
        guard let (head, array) = hops.decompose else { return nil }
        
        var tail = Position()
        tail.hops += array
        return (head,tail)
    }
    
    var hashValue : Int {
        return hops.description.hashValue
    }
    
    var description : String {
        guard !hops.isEmpty else  { return "ε" }
        
        return hops.joinWithSeparator(".")
    }
    
    var isEmpty : Bool {
        return hops.isEmpty
    }
}

extension Position {
//    init(_ sequence:Array<Int>) {
//        self.init()
//        self.hops += sequence
//    }
    
    init<S: SequenceType where S.Generator.Element == Int>(_ sequence:S) {
        self.init()
        self.hops += sequence
    }
}

//extension Position : ArrayLiteralConvertible {
//    
//    init(arrayLiteral elements:Int...) {
//        hops = elements
//    }
//}

extension Position {
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
                self.hops.append(hop)
            }
            else {
                break
            }
        }
    }
}

let ε = Position()

func ==(lhs:Position, rhs:Position) -> Bool {
    return lhs.hops == rhs.hops
}

func +(lhs:Position, rhs:Int) -> Position {
    return Position(lhs.hops + [rhs])
}

func +(lhs:Int, rhs:Position) -> Position {
    return Position([lhs] + rhs.hops)
}

func +(lhs:Position, rhs: Position) -> Position {
    return Position(lhs.hops + rhs.hops)
}

func -(lhs:Position, rhs:Position) -> Position? {
    guard let hops = lhs.hops - rhs.hops else { return nil }
    
    return Position(hops)
}

func <= (lhs:Position, rhs:Position) -> Bool {
    return lhs.hops <= rhs.hops
}

func >= (lhs:Position, rhs:Position) -> Bool {
    return lhs.hops >= rhs.hops
}

func < (lhs:Position, rhs:Position) -> Bool {
    return lhs.hops < rhs.hops
}

func > (lhs:Position, rhs:Position) -> Bool {
    return lhs.hops > rhs.hops
}

func || (lhs:Position, rhs:Position) -> Bool {
    return lhs.hops || rhs.hops
}

// MARK: - Node + Position

extension Node {
    
    /// Get all positions of a term, i.e. all paths from root to nodes.
    /// **`P(f(x),f(g(x,y))`** yields the positions:
    ///
    ///     []      P(f(x),f(g(x,y))
    ///     [1]     f(x)
    ///     [1.2]   x
    ///     [2]     f(g(x,y))
    ///     [2.1]   g(x,y)
    ///     [2.1.1] x
    ///     [2.1.2] y
    ///
    /// see [AM2015TRS,*Definition 2.1.16*]
    var allPositions : [Position] {
        var positions = [Position](arrayLiteral: Position())
        
        guard let nodes = self.nodes else { return positions }
        
        let list = nodes.map { $0.allPositions }
        
        for (index, poss) in list.enumerate() {
            positions += poss.map { (index+1) + $0 }
        }
        return positions
    }
}

extension Node {
    /// Get subterm at position.
    /// With [] the term itself is returned.
    /// With [i] the the subterm with index (i-1) is returned.
    ///
    /// see [AM2015TRS,*Definition 2.1.22*]
    subscript (position: Position) -> Self? {
        guard let (head,tail) = position.decompose() else { return self }       // position == []
        guard let nodes = self.nodes else { return nil }                        // position != [], but variables has no subnodes at all
        if head < 1 || head > nodes.count { return nil }                        // node does not have a subnode at given position
        // node is not a constant or variable and has a subnode at given position
        return nodes[head-1][tail]
    }
    
    /// Construct a new term by replacing the subterm at position.
    ///
    /// see [AM2015TRS,*Definition 2.1.22*]
    subscript (term: Self, position:Position) -> Self? {
        guard let (head,tail) = position.decompose() else { return term }       // position == []
        guard var nodes = self.nodes else { return nil }                        // position != [], but variables has no subnodes at all
        if head < 1 || head > nodes.count { return nil }                        // node does not have a subnode at given position
        // node is not a constant or variable and has a subnode at given position
        let index = head-1
        guard let subnode = nodes[index][term, tail] else { return nil }
        nodes[index] = subnode
        return Self(function:self.symbol, nodes: nodes)
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