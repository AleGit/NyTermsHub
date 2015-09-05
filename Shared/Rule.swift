//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

public typealias SymbolCountArityDictonary = Dictionary<String,(count:Int,arity:Set<Int>)>
public typealias VariableSymbolCountDictonary = Dictionary<String,Int>

public func ==(lhs:SymbolCountArityDictonary,rhs:SymbolCountArityDictonary) -> Bool {
    if lhs.count != rhs.count { return false }
    
    for (symbol,(count:occurs,arity:arity)) in lhs {
        guard let (ro,ra) = rhs[symbol] else { return false }
        
        if ro != occurs || ra != arity { return false }
    }
    
    return true
}

public extension Term {
    /// Get the set of all variable terms.
    public var allVariables : Set<Self> {
        guard let ts = self.terms else { return Set(arrayLiteral: self) }
        
        return Set(ts.flatMap { $0.allVariables })
    }
    
    /// **(tentative)** Get a dictionary of all symbols as keys and
    /// the number of the occurencies and arities of each symbol as values
    var countedSymbols : SymbolCountArityDictonary {
        guard let terms = self.terms else { return [self.symbol:(1,Set<Int>())] } // variables has no arity at all
        
        var soas = [self.symbol:(count:1,arity:Set(arrayLiteral: terms.count))]
        
        let tsoas = terms.flatMap { $0.countedSymbols }
        
        for (symbol, (count:occurs,arity:arity)) in tsoas {
            if let (ao,aa) = soas[symbol] {
                assert(arity == aa,"symbol \(symbol) with variadic arguments \(aa)!=\(arity) are not supported")
                soas[symbol] = (count:occurs+ao,arity:arity.union(aa))
            }
            else {
                soas[symbol] = (count:occurs,arity:arity)
            }
        }
        
        return soas
    }
    
    /// **(tentative)** Get a dictionary of all variable symbols as keys and
    /// the number of the occurencies of each variable as values.
    var countedVariableSymbols : VariableSymbolCountDictonary {
        assert(!self.symbol.isEmpty)
        
        guard let terms = self.terms else { return [self.symbol:1] }    // variable
        
        var vscd = VariableSymbolCountDictonary()
        
        let tvscd = terms.flatMap { $0.countedVariableSymbols }
        
        for (symbol, subcount) in tvscd {
            if let count = vscd[symbol] {
                vscd[symbol] = subcount + count
            }
            else {
                vscd[symbol] = subcount
            }
        }
        
        return vscd
    }
    
    /// A rewrite rule is an equation that satifies the follwong conditions
    /// - the left-hand side is not a variable
    /// - Vars(r) is a subset of Vars(l)
    static public func Rule(lhs:Self, _ rhs:Self) -> Self? {
        
        if lhs.terms == nil { return nil }  // the left-hand side is a variable, hence the equation is not a rule
        
        if !(rhs.allVariables.isSubsetOf(lhs.allVariables)) { return nil }  // allVariables(rhs) is not a subset of allVariables(lhs), hence the equation is not a rule
        
        return Self(symbol: SymbolTable.EQUALS, terms: [lhs,rhs]) // the equation is a rule
    }
    
    
}

// MARK: overlaps, critical pairs, critical peaks

extension Term {
    /// Pair with position p and unifier σ:
    /// - p in Pos(`self`)
    /// - `self`|<sub>p</sub>.σ = `other`.σ
    /// - σ = mgu(`self`|<sub>p</sub>,`other`)
    typealias PositionUnifier = (position:Position,unifier:[Self:Self])
    
    /// An *overlap* of TRS(*F*,*R*) is a triple (l<sub>1</sub>->r<sub>1</sub>,p,l<sub>2</sub>->r<sub>2</sub>) satisfying:
    ///
    /// - l<sub>1</sub>->r<sub>1</sub>, l<sub>2</sub>->r<sub>2</sub> are variants of rewrite rules of *R* without common variables,
    /// - p in Pos<sub>F</sub>(l<sub>2</sub>), i.e. p is the position of a non-variable term,
    /// - l<sub>1</sub> and l<sub>2</sub>|<sub>p</sub> are unifiable,
    /// i.e. l<sub>2</sub>|<sub>p</sub>.σ == l<sub>1</sub>.σ with σ = mgu(l<sub>1</sub>,l<sub>2</sub>|<sub>p</sub>)
    /// - if p = [] then l<sub>1</sub>->r<sub>1</sub> and l<sub>2</sub>->r<sub>2</sub> are not variants
    typealias Overlap = (l1r1:Self, position:Position, l2r2:Self)
    
    
    /// We call the quadruple (l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub>, p, l<sub>2</sub>σ, r<sub>2</sub>σ) a
    /// *critical peak* obtained from overlap (l<sub>1</sub>->r<sub>1</sub>,p,l<sub>2</sub>->r<sub>2</sub>).
    public typealias CriticalPeak = (l2r1:Self,positon:Position,l2:Self,r2:Self)
    
    /// Find all *non-variable* positions p where subterm `self`|p and term `other` are unifiable
    /// and return the (possible empty) list of positons with unifiers.
    ///
    ///     { (p,σ) | self[p].σ = other.σ }
    func unifiablePositions(other:Self) -> [Position] {
        assert(self.allVariables.intersect(other.allVariables).count == 0)
        
        return self.positionUnifiers(Position(), other: other).map { $0.position }
    }
    
    /// Find all of `self`'s *non-variable* subterms which are unifiable with term `other`
    /// and return a (possible empty) list of pairs with positions and unifiers.
    private func positionUnifiers(actual:Position, other:Self) -> [PositionUnifier] {
        
        var positionUnifiers = [ PositionUnifier ]()
        
        guard let terms = self.terms else { return positionUnifiers }   // variables do not have non-variable subterms
        
        if let mgu = (self =?= other) {
            positionUnifiers.append(position: actual, unifier: mgu)
        }
        
        for (index,term) in terms.enumerate() {
            guard let mgu = term =?= other where !term.isVariable else { continue }
            
            // array index is i, then position is i+1.
            positionUnifiers.append((position:actual+[index+1], unifier:mgu))
        }
        return positionUnifiers
    }
    
    /// Find all critical peaks (l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub>, p, l<sub>2</sub>σ, r<sub>2</sub>σ)
    /// originating in left-hand side of rule `other` = l<sub>2</sub>->r<sub>2</sub>
    /// and induced by left-hand side of rule `self` = l<sub>1</sub>->r<sub>1</sub>.
    public func criticalPeaks(other:Self) -> [CriticalPeak] {
        assert(other.isRewriteRule,self.description)
        assert(self.isRewriteRule,self.description)
        assert(self.allVariables.intersect(other.allVariables).isEmpty)
        
        // self is rule l1->r1
        guard let l1 = self.terms?.first else { return [CriticalPeak]() }
        guard let r1 = self.terms?.last else { return [CriticalPeak]() }
        // other is rule l2->r2
        guard let l2 = other.terms?.first else { return [CriticalPeak]() }
        guard let r2 = other.terms?.last else { return [CriticalPeak]() }
        
        return l2.positionUnifiers([], other: l1).filter {
            // - if p = [] then l1->r1 and l2</sub>->r2</sub> are not variants
            $0.position != [] || !self.isVariant(other)
        }.map { (p,σ) -> CriticalPeak in
            let l2σ = l2 * σ                      // _σ == l2[p]σ == l1σ -> r1σ
            let l2r1σ = l2σ[r1 * σ,p]             // l2σ[l1σ,p] -> l2σ[r1σ,p]
            let peak = (l2r1: l2r1σ!, positon: p, l2: l2σ, r2: r2 * σ)
            return peak
        }
    }
}




