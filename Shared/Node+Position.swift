//
//  Node+Position.swift
//  NyTerms
//
//  Created by Alexander Maringele on 03.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

/**
A position is a finite sequence of non-negative integers. 
The *root* position is the empty sequence and denoted by `ε`
and `p+q` denotes the concatenation of positions `p` and `q`.
We define binary relations <= , <, and || on positions as follows.
We say that position `p` is above position `q
if there exists a (necessarily unique) position `r` such that `p+r = q`.
In that case wedefine `q\p` as the position r.
If `p` is above q we also say that `q` is below p or p is a *prefix* of `q`, and we write `p` <= `q`.
We write `p < q` if `p <= q` and `p != q`. If `p < q` we say that `p` is a proper prefix of `q`.
Positions `p`, q are parallel, denoted by `p || q`, if neither `p <= q` nor `q <= p`.
**/

typealias Position = [Int]
let ε = Position()

extension Node {
    
    /// Get all positions of a term, i.e. all paths from root to nodes.
    /// **`P(f(x),f(g(x,y))`** yields the positions:
    ///
    ///     []      P(f(x),f(g(x,y))
    ///     [0]     f(x)
    ///     [0,1]   x
    ///     [1]     f(g(x,y))
    ///     [1,0]   g(x,y)
    ///     [1,0,0] x
    ///     [1,0,1] y
    ///
    /// see [AM2015TRS,*Definition 2.1.16*]
    var positions : [Position] {
        var positions = [ε] // the root position always exists
        
        guard let nodes = self.nodes else { return positions }
        
        let list = nodes.map { $0.positions }
        
        for (hop, tails) in list.enumerate() {
            positions += tails.map { [hop] + $0 }
        }
        return positions
    }
}

extension Node {
    /// Get subterm at position.
    /// With [] the term itself is returned.
    /// With [i] the the subterm with array index i is returned.
    subscript (position: Position) -> Self? {
        guard let (head,tail) = position.decompose else { return self }       // position == []
        guard let nodes = self.nodes else { return nil }                        // position != [], but variables has no subnodes at all
        guard 0 <= head && head < nodes.count else { return nil }               // node does not have a subnode at given position
        // node is not a constant or variable and has a subnode at given position
        
        return nodes[head][tail]
    }
    
    /// Construct a new term by replacing the subterm at position.
    subscript (term: Self, position:Position) -> Self? {
        guard let (head,tail) = position.decompose else { return term }       // position == []
        guard var nodes = self.nodes else { return nil }                        // position != [], but variables has no subnodes at all
        guard 0 <= head && head < nodes.count else { return nil }               // node does not have a subnode at given position
        // node is not a constant or variable and has a subnode at given position
        guard let subnode = nodes[head][term, tail] else { return nil }
        nodes[head] = subnode
        
        return Self(function:self.symbol, nodes: nodes)
    }
}

// MARK: - Array<Node> + Position

extension Array where Element:Node {
    /// Get term at position in array. (for convenience)
    /// array[[i]] := array[i]
    /// array[[i,j,...]] := array[i][j,...]
    subscript(position:Position)->Element? {
        guard let (head,tail) = position.decompose else { return nil }        // position == [], but an array is not of type Node
        guard 0 <= head && head < self.count else { return nil }                // node does not have a subnode at given position
        
        return self[head][tail]
    }
}