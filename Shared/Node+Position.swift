//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

public extension Node {
    /// see **Definition 2.1.16**
    ///
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

public extension Node {
    /// Get subterm at position.
    /// With [] the term itself is returned.
    /// With [i] the the subterm with index (i-1) is returned.
    subscript (position: Position) -> Self? {
        guard let first = position.first else { return self }   // position == []
        guard let nodes = self.nodes else { return nil }        // position != [], but variables has no subnodes at all
        if first < 1 || first > nodes.count { return nil }      // node does not have subnode at given position
        // node is not a constant or variable and has a subnode at given position
        let tail = Array(position.suffixFrom(1))
        return nodes[first-1][tail]
    }
    
    /// Construct a new term by replacing the subterm at position.
    subscript (term: Self, position:Position) -> Self? {
        guard let first = position.first else { return term }   // position == []
        guard var nodes = self.nodes else { return nil }        // position != [], but variables has no subnodes at all
        if first < 1 || first > nodes.count { return nil }      // node does not have subnode at given position
        // node is not a constant or variable and has a subnode at given position
        let tail = Array(position.suffixFrom(1))
        guard let subnode = nodes[first-1][term, tail] else { return nil }
        nodes[first-1] = subnode
        return Self(function:self.symbol, nodes: nodes)
    }
}


