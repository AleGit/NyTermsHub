//
//  Node+Position.swift
//  NyTerms
//
//  Created by Alexander Maringele on 03.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

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
    var positions : [Position<Int>] {
        var positions = [Position](arrayLiteral: Position<Int>())
        
        guard let nodes = self.nodes else { return positions }
        
        let list = nodes.map { $0.positions }
        
        for (index, poss) in list.enumerate() {
            positions += poss.map { Position(arrayLiteral:index+1) + $0 }
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
    subscript (position: Position<Int>) -> Self? {
        guard let (head,tail) = position.decompose() else { return self }       // position == []
        guard let nodes = self.nodes else { return nil }                        // position != [], but variables has no subnodes at all
        if head < 1 || head > nodes.count { return nil }                        // node does not have a subnode at given position
        // node is not a constant or variable and has a subnode at given position
        return nodes[head-1][tail]
    }
    
    /// Construct a new term by replacing the subterm at position.
    ///
    /// see [AM2015TRS,*Definition 2.1.22*]
    subscript (term: Self, position:Position<Int>) -> Self? {
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