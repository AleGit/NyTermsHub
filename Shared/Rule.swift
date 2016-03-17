//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation



func ==<S:Hashable>(lhs:[S:(count:Int,arities:Set<Int>)],rhs:[S:(count:Int,arities:Set<Int>)]) -> Bool {
    if lhs.count != rhs.count { return false }
    
    for (symbol,(count:occurs,arities:arities)) in lhs {
        guard let (ro,ra) = rhs[symbol] else { return false }
        
        if ro != occurs || ra != arities { return false }
    }
    
    return true
}

extension Node
{
    typealias SymbolCensus = [ Symbol : (count:Int,arities:Set<Int>)]
    typealias VariableCensus = [Symbol : Int]
    /// Get the set of all variable terms.
    var allVariables : Set<Self> {
        guard let ts = self.nodes else { return Set(arrayLiteral: self) }
        
        return Set(ts.flatMap { $0.allVariables })
    }
    
    private func fill(inout census:SymbolCensus) {
        var arities = Set<Int>()
        
        if let nodes = self.nodes {
            arities.insert(nodes.count)
            
            for node in nodes {
                node.fill(&census)
            }
        }
        
        if var entry = census[self.symbol] {
            entry.count += 1
            entry.arities.unionInPlace(arities)
            census[self.symbol] = entry
        }
        else {
            census[self.symbol] = (count:1, arities:arities)
        }
        
        
    }
    
    /// **(tentative)** Get a dictionary of all symbols as keys and
    /// the number of the occurencies and arities of each symbol as values
    var countedSymbols : SymbolCensus {
        var census = SymbolCensus()
        self.fill(&census)
        return census
    }
    
    /// **(tentative)** Get a dictionary of all variable symbols as keys and
    /// the number of the occurencies of each variable as values
    var countedVariables : VariableCensus {
        var census = VariableCensus()
        let list = countedSymbols.filter { $0.1.arities.isEmpty }.map { ($0.0,$0.1.count) }
        for (key,value) in list {
            census[key] = value
        }
        return census
    }
    
    /// A rewrite rule is an equation that satifies the follwong conditions
    /// - the left-hand side is not a variable
    /// - Vars(r) is a subset of Vars(l)
    static func Rule(lhs:Self, _ rhs:Self) -> Self? {
        
        if lhs.nodes == nil { return nil }  // the left-hand side is a variable, hence the equation is not a rule
        
        if !(rhs.allVariables.isSubsetOf(lhs.allVariables)) { return nil }  // allVariables(rhs) is not a subset of allVariables(lhs), hence the equation is not a rule
        
        return Self(symbol: Self.symbol(.Equation), nodes: [lhs,rhs]) // the equation is a rule
    }
    
    
}

// MARK: overlaps, critical pairs, critical peaks

extension Node {
    /// Pair with position p and unifier σ:
    /// - p in Pos(`self`)
    /// - `self`|<sub>p</sub>.σ = `other`.σ
    /// - σ = mgu(`self`|<sub>p</sub>,`other`)
    typealias PositionUnifier = (position:[Int],unifier:[Self:Self])
    
    /// **(unused)** An *overlap* of TRS(*F*,*R*) is a triple (l<sub>1</sub>->r<sub>1</sub>,p,l<sub>2</sub>->r<sub>2</sub>) satisfying:
    ///
    /// - l<sub>1</sub>->r<sub>1</sub>, l<sub>2</sub>->r<sub>2</sub> are variants of rewrite rules of *R* without common variables,
    /// - p in Pos<sub>F</sub>(l<sub>2</sub>), i.e. p is the position of a non-variable term,
    /// - l<sub>1</sub> and l<sub>2</sub>|<sub>p</sub> are unifiable,
    /// i.e. l<sub>2</sub>|<sub>p</sub>.σ == l<sub>1</sub>.σ with σ = mgu(l<sub>1</sub>,l<sub>2</sub>|<sub>p</sub>)
    /// - if p = [] then l<sub>1</sub>->r<sub>1</sub> and l<sub>2</sub>->r<sub>2</sub> are not variants
    typealias Overlap = (l1r1:Self, position:[Int], l2r2:Self)
    
    
    /// We call the quintuple (l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub>, p, l<sub>2</sub>σ, r<sub>2</sub>σ) 
    /// a *critical peak*
    /// and the equation l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub> = r<sub>2</sub>σ a *critical pair*,
    /// obtained from overlap (l<sub>1</sub>→r<sub>1</sub>,p,l<sub>2</sub>→r<sub>2</sub>).
    typealias CriticalPeak = (l2r1:Self,positon:[Int],l2:Self,r2:Self)
    
    /// Find all *non-variable* positions p where subterm `self`|p and term `other` are unifiable
    /// and return the (possible empty) list of positons.
    ///
    ///     { (p,σ) | self[p].σ = other.σ }
    func unifiablePositions(other:Self) -> [[Int]] {
        assert(self.allVariables.intersect(other.allVariables).count == 0)
        
        return self.positionUnifiers([Int](), other: other).map { $0.position }
    }
    
    /// Find all of `self`'s *non-variable* subterms which are unifiable with term `other`
    /// and return a (possible empty) list of pairs with positions and unifiers.
    private func positionUnifiers(actual:[Int], other:Self) -> [PositionUnifier] {
        
        var positionUnifiers = [ PositionUnifier ]()
        
        guard let nodes = self.nodes else { return positionUnifiers }   // variables do not have non-variable subnodes
        
        if let mgu = (self =?= other) {
            positionUnifiers.append(position: actual, unifier: mgu)
        }
        
        for (index,term) in nodes.enumerate() {
            positionUnifiers += term.positionUnifiers(actual+[index], other: other)
        }
        return positionUnifiers
    }
    
    /// Find all critical peaks (l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub>, p, l<sub>2</sub>σ, r<sub>2</sub>σ)
    /// originating in left-hand side of rule `other` = l<sub>2</sub>->r<sub>2</sub>
    /// and induced by left-hand side of rule `self` = l<sub>1</sub>->r<sub>1</sub>.
    func criticalPeaks(other:Self) -> [CriticalPeak] {
        assert(other.isRewriteRule,self.description)
        assert(self.isRewriteRule,self.description)
        assert(self.allVariables.intersect(other.allVariables).isEmpty)
        
        // self is rule l1->r1
        guard let l1 = self.nodes?.first else { return [CriticalPeak]() }
        guard let r1 = self.nodes?.last else { return [CriticalPeak]() }
        // other is rule l2->r2
        guard let l2 = other.nodes?.first else { return [CriticalPeak]() }
        guard let r2 = other.nodes?.last else { return [CriticalPeak]() }
        
        return l2.positionUnifiers(ε, other: l1).filter {
            // - if p = [] then l1->r1 and l2</sub>->r2</sub> are not variants
            $0.position != ε || !self.isVariant(other)
        }.map { (p,σ) -> CriticalPeak in
            let l2σ = l2 * σ                      // _σ == l2[p]σ == l1σ -> r1σ
            let l2r1σ = l2σ[r1 * σ,p]             // l2σ[l1σ,p] -> l2σ[r1σ,p]
            let peak = (l2r1: l2r1σ!, positon: p, l2: l2σ, r2: r2 * σ)
            return peak
        }
    }
    
    /// We call the equation l<sub>2</sub>σ[r<sub>1</sub>σ]<sub>p</sub> = r<sub>2</sub>σ a *critical pair*,
    /// obtained from overlap (l<sub>1</sub>→r<sub>1</sub>,p,l<sub>2</sub>→r<sub>2</sub>).
    func criticalPairs(other:Self) -> [Self] {
        return self.criticalPeaks(other).map {
            Self(equational:Self.symbol(.Equation), nodes: [$0.l2r1, $0.r2])
        }
    }
    
    func hasOverlap(at position:[Int], with rule2: Self) -> Bool {
        assert(self.allVariables.intersect(rule2.allVariables).count == 0)
        
        guard let l1 = self.nodes?.first else { return false }
        guard let l2p = rule2.nodes?.first?[position] else { return false }        
        return l1.isUnifiable(l2p) && !(position.isEmpty && self.isVariant(rule2))
    }
}




