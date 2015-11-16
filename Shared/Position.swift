//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// **Definition 2.1.14.** A position is a finite sequence of positive integers.
/// The *root* position is the empty sequence and denoted by `ε`
/// and `p+q` denotes the concatenation of positions `p` and `q`.
/// We define binary relations <= , <, and || on positions as follows.
/// We say that position `p` is above position `q 
/// if there exists a (necessarily unique) position `r` such that `p+r = q`.
/// In that case wedefine `q\p` as the position r.
/// If `p` is above q we also say that `q` is below p or p is a *prefix* of `q`, and we write `p` <= `q`.
/// We write `p < q` if `p <= q` and `p != q`. If `p < q` we say that `p` is a proper prefix of `q`.
/// Positions `p`, q are parallel, denoted by `p || q`, if neither `p <= q` nor `q <= p`.
public typealias Position = [Int]

public func -<T:Equatable>(lhs:[T], rhs:[T]) -> [T]? {
    guard rhs <= lhs else { return nil }
    
    return Array(lhs.suffixFrom(rhs.count))
}

public func <= <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    // lhs must not be longer then rhs
    guard lhs.count <= rhs.count else { return false }
    
    return lhs[0..<lhs.count] == rhs[0..<lhs.count]
}

public func >= <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return rhs <= lhs
}

public func < <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    // lhs must be shorter then rhs
    guard lhs.count < rhs.count else { return false }
    
    return lhs[0..<lhs.count] == rhs[0..<lhs.count]
}

public func > <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return rhs < lhs
}

public func || <T:Equatable> (lhs:[T], rhs:[T]) -> Bool {
    return !( lhs <= rhs || lhs >= rhs)
}

public extension Node {
    /// Get all positions of a term, i.e. all paths from root to nodes.
    /// "P(f(x),f(g(x,y))" yields the positions:
    ///
    ///     []      P(f(x),f(g(x,y))
    ///     [1]     f(x)
    ///     [1,2]   x
    ///     [2]     f(g(x,y))
    ///     [2,1]   g(x,y)
    ///     [2,1,1] x
    ///     [2,1,2] y
    public var allPositions : [Position] {
        var positions = [Position](arrayLiteral: Position())
        
        guard let nodes = self.nodes else { return positions }
        
        let list = nodes.map { $0.allPositions }
        
        for (index, element) in list.enumerate() {
            for var e in element {
                e.insert(index+1, atIndex: 0)
                positions.append(e)
            }
        }
        return positions
    }
}

public extension Array where Element:Node {
    /// Get term at position in array. (for convenience)
    /// array[[i]] := array[i-1]
    /// array[[i,j,...]] := array[i-1][j,...]
    public subscript(position:Position)->Element? {
        
        guard let first = position.first else { return nil }
        
        if first < 1 || first >= self.count { return nil }
        
        let term = self[first-1]
        let tail = Position(position.suffixFrom(1))
        
        return term[tail]
    }
}

public extension Node {
    /// Get term at position.
    /// With [] the term itself is returned.
    /// With [i] the the subterm with index (i-1) is returned.
    subscript (position: Position) -> Self? {
        return subterm(self, position: position)
    }
    
    /// Construct a new term by replacing the subterm at position.
    subscript (term: Self, position:Position) -> Self? {
        return replace(self, position: position, term: term)
    }
}

private func subterm<T:Node>(root:T, position: Position) -> T? {
    
    guard let first = position.first else { return root }   // position == []
    
    guard let nodes = root.nodes else { return nil }        // postiion != 0, but variables has no subnodes at all
    
    if first < 1 || first > nodes.count { return nil }     // function (constant) does not have a subterm at given position
    
    // term cannot be a variable or constant at this point
    let tail = Array(position.suffixFrom(1))
    
    return subterm(nodes[first-1], position:tail)
}

private func replace<T:Node>(root:T, position:Position, term:T) -> T? {
    
    guard let first = position.first else { return term }   // position == []
    
    guard var nodes = root.nodes else { return nil }        // postiion != 0, but variables has no subnodes at all
    
    if first < 1 || first > nodes.count { return nil }      // function (constant) does not have a subterm at given position
    
    // term cannot be a variable or constant at this point
    let tail = Array(position.suffixFrom(1))
    
    guard let replacement = replace(nodes[first-1], position: tail, term:term) else { return nil }
    
    nodes[first-1] = replacement
    
    return T(function:root.symbol, nodes:nodes)
}

