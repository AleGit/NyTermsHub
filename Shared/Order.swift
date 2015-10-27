//
//  Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

/// (D.4.3.1) A *precedence* is a proper order on a signature
public typealias precedence = (Symbol,Symbol) -> Bool

public protocol Order {
    
    func greaterThan<T:Node>(s:T, t:T) -> Bool
}





/// (D.4.3.2) Let > be a precedence.
/// We define the *lexicographic path order* (LPO) on terms
/// inductivley as follows:
/// s = f(s<sub>1</sub>,...,s<sub>n</sub>) ><sub>LPO</sub> t
/// if one of the following alternatives hold
/// 1. t = f(t<sub>1</sub>,...,t<sub>n</sub>) and there exist an i in 1...n such that
/// * s<sub>j</sub> = t<sub>j</sub> for j in 1..<i
/// * s<sub>i</sub> ><sub>LPO</sub> t<sub>i</sub>
/// * s > t<sub>j</sub> for j in (i+1)...n
/// 2. t = g(t<sub>1</sub>,...,t<sub>m</sub>,
/// f>g, and s><sub>LPO</sub>t<sub>i</sub> for all i in 1...m
/// 3. s<sub>i</sub> = t or s<sub>i</sub> ><sub>LPO</sub> t for some i in 1...n
public struct LexicographicPathOrder : Order {
    let p:precedence
    
    public init(p:precedence) {
        self.p = p
    }
    
    public func greaterThan<T:Node>(s:T, t:T) -> Bool {
        assert(s.isTerm)
        assert(t.isTerm)

        // a variable can never be greater than a term
        guard let snodes = s.nodes else { return false }
        
        // now we know, that s is not a variable
        
        func checkCaseOne() -> Bool {
            guard s.symbol == t.symbol else { return false }
            guard let tnodes = t.nodes else { return false }
            guard snodes.count == tnodes.count else { return false }
            
            var equal = true
            for (sj,tj) in zip(snodes, tnodes) {
                if equal {
                    // we check: sj = tj for j in 1..<i
                    equal = (sj == tj)
                    
                    
                    if !equal {
                        // we check: si > ti
                        guard self.greaterThan(sj, t: tj) else { return false }
                    }
                    else {
                        // we check s > tj for j in (i+1)...n
                        guard self.greaterThan(s, t:tj) else { return false }
                        
                    }
                    
                }
            }
            
            return true
        }
        
        func checkCaseTwo() -> Bool {
            // we compare s=f(...,s_n) with t=g(...,t_m)
            guard let tnodes = t.nodes else { return false } // case is not applicable for a variable on the right side
            guard self.p(s.symbol,t.symbol) else { return false } // precedence f > g
            
            // we check s > tj for all j in 1...m
            return tnodes.reduce(true) { $0 && self.greaterThan(s, t: $1) }
        }
        
        func checkCaseThree() -> Bool {
            let matches = snodes.reduce(false) { $0 || $1 == t || self.greaterThan($1, t: t) }
            return matches
        }
        
        return checkCaseOne() || checkCaseTwo() || checkCaseThree()
    }
}

/// (D.4.4.1) A *weight function* for a signature *F* is a pair (*w*,w<sub>0</sub>)
/// of a mapping *w*: *F* -> **N** and constant w<sub>0</sub> such that
/// *w*(c) > w<sub>0</sub> for every constant c in *F*.
public typealias weight = (w:Symbol -> Int, w0:Int)

/// (D.4.4.2) Let *F* be a signature and (*w*,w<sub>0</sub> a weight function for *F*.
/// The weight of a term t is defined as follows:
/// 1. w(x) = w<sub>0</sub>
public typealias weighting = Node -> Int

public func makeWeighting<T:Node>(w: weight) -> ((T)->Int) {
    
    var wt: ((T)->Int)? = nil
    
    wt = {
        (t:T) -> Int in
        
        guard let tnodes = t.nodes else { return w.w0 } // t is variable
        
        return tnodes.reduce(w.w(t.symbol)) {
            $0 + wt!($1)
        }
    }
    return wt!
}

/// Let > be a precedence and (*w*,w<sub>0</sub>) a weight function.
/// We define the Knuth-Bendix order (KBO for short) ><sub>KBO</sub> on terms
/// inductively as follows:
///
/// s ><sub>kbo</sub> t
///
// if |s|<sub>x</sub> >= |t|<sub>x</sub> for all x ∈ V and either
/// 1. w(s) > w(t), or
/// 2. w(s) = w(t) and one of the following alternatives holds:
/// * t∈V and s=f<sup>n</sup>(t) for some unary function symbol f and n>0,
/// * s = f(s<sub>1</sub>,...,s<sub>n<sub>),
/// t = f(t<sub>1</sub>,...,t<sub>n<sub>),
/// and there exists an i ∈ {1,...,n} such that
/// s<sub>j</sub> = t<sub>j</sub>
/// forall j<i and s<sub>i</sub> ><sub>kbo</sub> t<sub>i</sub>,or
/// * s = f(s<sub>1</sub>,...,s<sub>n</sub>), t = g(t<sub>1</sub>,...,t<sub>m</sub>), and f > g.
public struct KnuthBendixOrder : Order {
    let p:precedence
    let w:weighting
    
    public init(p:precedence, w:weighting) {
        self.p = p
        self.w = w
    }
    
    public func greaterThan<T:Node>(s:T, t:T) -> Bool {
        assert(s.isTerm)
        assert(t.isTerm)
        
        let scvs = s.countedVariableSymbols
        let tcvs = s.countedVariableSymbols
        
        // we check: |s|<sub>x</sub> >= |t|<sub>x</sub> for all x ∈ V
        for (symbol, tcount) in tcvs {
            guard let scount = scvs[symbol] else { return false }
            guard scount > tcount else { return false }
        }
        
        let ws = w(s)
        let wt = w(t)
        
        if ws > wt {
            return true
        }
        else {
            guard ws == wt else { return false }
            
            func checkSubCaseOne() -> Bool {
                guard t.isVariable else { return false }
                guard s.isTerm else { return false }
                var u = s
                while u.nodes?.count == 1 {
                    u = u.nodes![0]
                }
                return u == t
            }
            
            func checkSubCaseTwo() -> Bool {
                guard let snodes = s.nodes else { return false }
                guard let tnodes = t.nodes else { return false }
                guard s.symbol == t.symbol else { return false }
                guard snodes.count == tnodes.count else { return false }
                
                for (sj,tj) in zip(snodes,tnodes) {
                    if sj != tj {
                        return self.greaterThan(sj, t: tj)
                    }
                }
                // sj == tj for all j in 1...n
                return false
            }
            
            func checkSubCaseThree() -> Bool {
                guard s.isTerm && t.isTerm else { return false }
                return p(s.symbol, t.symbol)
            }
            
            return checkSubCaseOne() || checkSubCaseTwo() || checkSubCaseThree()
            
        }
    }
    
}