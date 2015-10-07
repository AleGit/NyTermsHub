//
//  Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

/// A *precedence* is a proper order on a signature
public typealias precedence = (Symbol,Symbol) -> Bool

/// We define the lexicographic path order (LPO) on terms
/// inductivley as follows:
/// s = f(s<sub>1</sub>,...,s<sub>n</sub>) ><sub>LPO</sub> t
/// if one of the following alternatives hold
/// 1. t = f(t<sub>1</sub>,...,t<sub>n</sub>) and there exist an i in 1...n such that
/// * s<sub>j</sub> = t<sub>j</sub> for j in 1..<i
/// * s<sub>i</sub> ><sub>LPO</sub> t<sub>i</sub>
/// * s > t<sub>j</sub> for j in (i+1)...n
/// 2.
/// 3.
public struct LexicographicPathOrder {
    let p:precedence
    
    public init(p:precedence) {
        self.p = p
    }
    
    public func greaterThan<T:Term>(s:T, t:T) -> Bool {
        guard let sterms = s.terms else { return false } // a variable is never greater than a term
        
        func checkCaseOne() -> Bool {
            guard s.symbol == t.symbol else { return false }
            guard let tterms = t.terms else { return false }
            guard sterms.count == tterms.count else { return false }
            
            var equal = true
            for (sj,tj) in zip(sterms, tterms) {
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
            guard let tterms = t.terms else { return false } // case is not applicable for a variable on the right side
            guard self.p(s.symbol,t.symbol) else { return false } // precedence f > g
            
            // we check s > tj for all j in 1...m
            return tterms.reduce(true) { $0 && self.greaterThan(s, t: $1) }
        }
        
        func checkCaseThree() -> Bool {
            let matches = sterms.reduce(false) { $0 || $1 == t || self.greaterThan($1, t: t) }
            return matches
        }

        return checkCaseOne() || checkCaseTwo() || checkCaseThree()
    }
    
    
}