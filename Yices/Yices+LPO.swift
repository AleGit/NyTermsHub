//
//  Yices+LPO.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {

    struct LPO {
        let pPrefix = "p⏑"
        
        var symbols = [String : (precedence:term_t, arity: Int)]()
        
        var precedences : [term_t] {
            return symbols.map { $0.1.precedence }
        }
        
        mutating func register(symbol:String, arity:Int) -> term_t {
            guard let (p,a) = symbols[symbol] else {
                let precedence = Yices.typedSymbol("\(pPrefix)\(symbol)", term_tau:Yices.int_tau)
                symbols[symbol] = (precedence,arity)
                return precedence
            }
            
            assert(a == arity, "\(symbol) must not be variadic: \(a) ≠ \(arity)")
            
            return p
            
        }
        
        mutating func leftRightCondition<N:Node>(s:N, _ t:N) -> term_t {
            guard s.nodes != nil else {
                // variables must not be on the left hand side
                return Yices.bot()
            }
            
            // s = f(s_1,...,s_n) >_lpo t if one of three holds
            
            return Yices.or ([case1(s,t), case2(s,t), case3(s,t)])
        }
        
        
        mutating private func case1<N:Node>(s:N, _ t:N) -> term_t {
            guard s.symbol == t.symbol else {
                // case 1 is not applicable if symbols are different
                return Yices.bot()
            }
            
            guard let snodes = s.nodes, let tnodes = t.nodes
                where snodes.count == tnodes.count else {
                    // this must not happen because symbols are equal,
                    // hence t cannot be a variable or
                    // a function symbol with different arity
                    assert(false,"\(#function)(\(s),\(t)) - mismatch in type or arity of root symbols.")
                    return Yices.bot()
            }
            
            var conditions = [term_t]()
            var lastWereEqual = true
            for (sj,tj) in zip(snodes,tnodes) {
                if lastWereEqual && sj==tj {
                    // currents are Equal
                    continue
                }
                else if lastWereEqual {
                    // sj != tj
                    let si_gt_ti = leftRightCondition(sj,tj)
                    conditions.append(si_gt_ti)
                    lastWereEqual = false
                }
                else {
                    let s_gt_tj = leftRightCondition(s,tj)
                    conditions.append(s_gt_tj)
                }
            }
            
            if lastWereEqual {
                // all were equal, hence s == t, hence not (s > t)
                return Yices.bot()
            }
            else {
                return Yices.and(conditions)
            }
        }
        
        mutating private func case2<N:Node>(s:N, _ t:N) -> term_t {
            guard let tnodes = t.nodes where s.symbol != t.symbol else {
                // case 2 is not applicable if t is a variable
                // case 2 is not applicable if symbols are the same
                return Yices.bot()
            }
            
            let f = s.symbolString()
            let g = t.symbolString()
            
            guard let snodes = s.nodes else {
                assert(false,"\(#function)(\(s),_) - must not be called with a variable as first argument.")
                return Yices.bot()
            }
            
            let pf = register(f, arity: snodes.count)
            let pg = register(g, arity: tnodes.count)
            
            let pf_gt_pg = Yices.gt(pf,pg)
            
            let conditions = [pf_gt_pg] + tnodes.map {
                leftRightCondition(s,$0)
            }
            
            return Yices.and(conditions)
        }
        
        mutating private func case3<N:Node>(s:N, _ t:N) -> term_t {
            guard let snodes = s.nodes else {
                assert(false,"\(#function)(\(s),_) - must not be called with a variable as first argument.")
                return Yices.bot()
            }
            
            let conditions = snodes.map {
                (si) -> term_t in
                if si == t { return Yices.top() }
                else {
                    return leftRightCondition(si,t)
                }
            }
            
            return Yices.or(conditions)
        }
    }
}