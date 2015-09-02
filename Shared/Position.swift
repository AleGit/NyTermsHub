//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// A position is a finite sequence of positive integers.
/// The root position is the empty sequence and denoted by ε 
/// and pq denotes the concatenation of positions p and q.
public typealias Position = [Int]

public extension Term {
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
        
        guard let terms = self.terms else { return positions }
        
        let list = terms.map { $0.allPositions }
        
        for (index, element) in list.enumerate() {
            for var e in element {
                e.insert(index+1, atIndex: 0)
                positions.append(e)
            }
        }
        return positions
    }
}

public extension Array where Element:Term {
    /// Get term at position in array. (for convenience)
    /// array[[i]] := array[i-1]
    /// array[[i,j,...]] := array[i-1][j,...]
    public subscript(position:Position)->Element? {
        
        guard let first = position.first else { return nil }
        
        if first < 1 || first >= self.count { return nil }
        
        let term = self[first-1]
        let tail = Array<Int>(position[1..<position.count])
        
        return term[tail]
    }
}

public extension Term {
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

private func subterm<T:Term>(root:T, position: Position) -> T? {
    
    guard let first = position.first else { return root }   // position == []
    
    guard let terms = root.terms else { return nil }        // postiion != 0, but variables has no subterms at all
    
    if first < 1 || first > terms.count { return nil }     // function (constant) does not have a subterm at given position
    
    // term cannot be a variable or constant at this point
    let tail = Array<Int>(position[1..<position.count])
    
    return subterm(terms[first-1], position:tail)
}

private func replace<T:Term>(root:T, position:Position, term:T) -> T? {
    
    guard let first = position.first else { return term }   // position == []
    
    guard var terms = root.terms else { return nil }        // postiion != 0, but variables has no subterms at all
    
    if first < 1 || first > terms.count { return nil }      // function (constant) does not have a subterm at given position
    
    // term cannot be a variable or constant at this point
    let tail = Array<Int>(position[1..<position.count])
    
    guard let replacement = replace(terms[first-1], position: tail, term:term) else { return nil }
    
    terms[first-1] = replacement
    
    return T(function:root.symbol, terms:terms)
}

