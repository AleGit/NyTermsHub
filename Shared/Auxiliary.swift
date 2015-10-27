//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

// MARK: - additional operators

/// Is left-hand side a variant of righ-hand side? (unused)
infix operator ~~ {
associativity none
precedence 130
}

/// Construct unifier of left-hand side and right-hand side.
infix operator =?= {
associativity none
}

/// Construct unifier for clashing literals
infix operator ~?= {
    associativity none
}

/// `s ** t` substitutes all variables in `s` with term `t`.
infix operator ** {
associativity left
}

/// `t**` substitutes all veriables in `t` with constant `⊥`.
postfix operator ** { }

// MARK: - convenience extensions

extension Range where Element : Comparable {
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

extension Dictionary {
    func filteredKeys(predicate : (Element)->Bool) -> [Key] {
        return self.filter { predicate($0) }.map { $0.0 }
    }
    
    func filteredSetOfKeys(predicate : (Element)->Bool) -> Set<Key> {
        return Set(self.filteredKeys(predicate))
    }
}



extension String  {
    func contains(string:Symbol) -> Bool {
        return self.rangeOfString(string) != nil
    }
    func containsOne(strings:Set<Symbol>) -> Bool {
        return strings.reduce(false) { $0 || self.contains($1) }
    }
    func containsAll(strings:Set<Symbol>) -> Bool {
        return strings.reduce(true) { $0 && self.contains($1) }
    }
}