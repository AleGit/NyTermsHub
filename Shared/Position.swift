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

struct Position : Hashable, CustomStringConvertible {
    private var sequence = [Int]()
    
    init() {
    
    }
    
    init(array:[Int]) {
        sequence += array
    }

    func decompose() -> (Int, Position)? {
        guard let (head, array) = sequence.decompose else { return nil }
        
        var tail = Position()
        tail.sequence += array
        return (head,tail)
    }
    
    var hashValue : Int {
        return sequence.description.hashValue
    }
    
    var description : String {
        guard !sequence.isEmpty else  { return "ε" }
        
        return sequence.joinWithSeparator(".")
    }
    
    var isEmpty : Bool {
        return sequence.isEmpty
    }
}

//extension Position : StringLiteralConvertible {
//    
//    // UnicodeScalarLiteralConvertible
//    // typealias UnicodeScalarLiteralType = StringLiteralType
//    init(unicodeScalarLiteral value: StringLiteralType) {
//        self.init(stringLiteral: value)
//    }
//    
//    // ExtendedGraphemeClusterLiteralConvertible:UnicodeScalarLiteralConvertible
//    // typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
//    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
//        self.init(stringLiteral: value)
//    }
//    
//    // StringLiteralConvertible:ExtendedGraphemeClusterLiteralConvertible
//    // typealias StringLiteralType
//    init(stringLiteral value: Self.StringLiteralType) {
//        
//    
//    }
//}

let ε = Position()

func ==(lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence == rhs.sequence
}

func +(lhs:Position, rhs:Int) -> Position {
    return Position(array: lhs.sequence + [rhs])
}

func +(lhs:Int, rhs:Position) -> Position {
    return Position(array: [lhs] + rhs.sequence)
}

func +(lhs:Position, rhs: Position) -> Position {
    return Position(array: lhs.sequence + rhs.sequence)
}

func -(lhs:Position, rhs:Position) -> Position? {
    guard let sequence = lhs.sequence - rhs.sequence else { return nil }
    
    return Position(array: sequence)
}

func <= (lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence <= rhs.sequence
}

func >= (lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence >= rhs.sequence
}

func < (lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence < rhs.sequence
}

func > (lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence > rhs.sequence
}

func || (lhs:Position, rhs:Position) -> Bool {
    return lhs.sequence || rhs.sequence
}

// MARK: - Node + Position

extension Node {
    
    /// Get all positions of a term, i.e. all paths from root to nodes.
    /// **`P(f(x),f(g(x,y))`** yields the positions:
    ///
    ///     []      P(f(x),f(g(x,y))
    ///     [1]     f(x)
    ///     [1,2]   x
    ///     [2]     f(g(x,y))
    ///     [2,1]   g(x,y)
    ///     [2,1,1] x
    ///     [2,1,2] y
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