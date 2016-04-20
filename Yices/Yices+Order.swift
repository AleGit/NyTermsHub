//
//  Yices+Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node {
    func isFnX(f:Symbol, _ X:Symbol) -> Bool {
        guard let nodes = self.nodes else {
            return self.symbol == X // f^0(X)
        }
        guard self.symbol == f && nodes.count == 1 else {
            return false
        }
        
        return nodes.first!.isFnX(f, X)
    }
}

extension Yices {
    struct KBO {
        let w0 = Yices.constant("𝛚₀", term_tau:Yices.int_tau)
        let pPrefix = "p⏑"
        let wPrefix = "w⏑"
        
        var symbols = [String : (weight:term_t, precedence:term_t, arity: Int)]()
        
        var atoms : [term_t] {
            let ws = symbols.values.map { $0.weight }
            let ps = symbols.values.map { $0.precedence }
            return [w0] + ws + ps
        }

        /// Register symbol with arity and create global weight and preference constants (i.e. variables).
        /// Return weight constant. (If symbol is allready registered check if arity is consistent.)
        mutating func register(symbol:String, arity:Int) -> term_t {
            guard let (w,_,a) = symbols[symbol] else {
                let weight = Yices.constant("\(wPrefix)\(symbol)", term_tau:Yices.int_tau)
                let preference = Yices.constant("\(pPrefix)\(symbol)", term_tau:Yices.int_tau)
                symbols[symbol] = (weight,preference,arity)
                return weight
            }
            
            assert(a == arity, "\(symbol) must not be variadic: \(a) ≠ \(arity)")
            
            return w
            
        }
        
        /// Returns a yices weight term for the given tptp term.
        /// Registers occurring symbols on the way.
        mutating func weight<N:Node>(node:N) -> term_t {
            guard let nodes = node.nodes else {
                // w(t) = w_0 if t is a variable
                return w0
            }
            
            let symbol = node.symbolString()
            let wf = register(symbol, arity: nodes.count)
            
            let summands = [ wf ] + nodes.map { weight($0) }
            
            return Yices.sum(summands)
        }
        
        mutating func leftRightCondition<N:Node>(s:N, _ t:N) -> term_t {
            guard leftRightPrerequisite(s,t) else { return Yices.bot() }
            
            let ws = weight(s)
            let wt = weight(t)
            
            let ws_gt_wt = Yices.gt(ws, wt)
            let ws_eq_wt = Yices.eq(ws, wt)
            let condition = leftRightPrecedence(s,t)
            
            let c = Yices.or(
                ws_gt_wt,
                Yices.and(ws_eq_wt, condition)
            )
            
            return c
        }
        
        private func leftRightPrerequisite<N:Node>(s:N, _ t:N) -> Bool {
            guard !s.isVariable && s != t else { return false }
            
            // false if |s|_x < |t|_x for some variable x
            
            let sxs = s.countedVariables
            for (x,tcount) in t.countedVariables {
                guard let scount = sxs[x] where scount >= tcount else {
                    return false // |s|_x < |t|_x
                }
                // |s|_x ≥ |t|_x, continue with next variable
            }
            
            // all variables in t occur in s, at least as many times as in t.
            return true
        }
        
        mutating private func leftRightPrecedence<N:Node>(s:N, _ t:N) -> term_t {
            assert(leftRightPrerequisite(s,t), "leftRightPrerequisite was not called before")
            
            // we know leftRightPrerequisite(s,t) is holding, hence
            // * s is not a variable
            // * s != t
            // * t does not increase the occurences of each variable
            
            let snodes = s.nodes!
            
            guard let tnodes = t.nodes else {
                return s.isFnX(s.symbol, t.symbol) ? Yices.top() : Yices.bot()
            }
            
            let pf = symbols[s.symbolString()]!.precedence
            let pg = symbols[t.symbolString()]!.precedence
            
            let pf_gt_pg = Yices.gt(pf,pg)
            let pf_eq_pg = Yices.eq(pf,pg)
            
            // let count = min(snodes.count,tnodes.count)
            
            var si_gt_ti = Yices.bot()
            
            for (si,ti) in zip(snodes,tnodes) {
                if si != ti {
                    si_gt_ti = leftRightCondition(si,ti)
                    break
                }
            }
            
            return Yices.or(
                pf_gt_pg,
                Yices.and(pf_eq_pg,si_gt_ti)
            )
        }
        
        var admissible : term_t {
            let w0gt0 = Yices.gt(w0,Yices.zero)
            
            let conditions = symbols.map {
                (_,wpa) -> term_t in
                let (w,_,a) = wpa
                if a == 0 { return Yices.ge(w,w0) }
                else { return Yices.ge(w,Yices.zero) }
            }
            
            let unariesConditions = symbols.filter {
                $0.1.arity == 1
                }.map {
                    (_,wpaf) -> term_t in
                    let (wf,pf,_) = wpaf
                    
                    let wf_eq_0 = Yices.eq(wf,Yices.zero)
                    
                    let pg_ge_pf = symbols.map {
                        (_,wpag) -> term_t in
                        let (_,pg,_) = wpag
                        return Yices.ge(pg,pf)
                    }
                    return Yices.implies(wf_eq_0, Yices.and(pg_ge_pf))
            }
            
            return Yices.and (w0gt0, Yices.and(conditions), Yices.and(unariesConditions))
        }
    }
}

extension Yices {
    struct LPO {
        let pPrefix = "p⏑"
        
        var symbols = [String : (precedence:term_t, arity: Int)]()
        
        var precedences : [term_t] {
            return symbols.map { $0.1.precedence }
        }
        
        mutating func register(symbol:String, arity:Int) -> term_t {
            guard let (p,a) = symbols[symbol] else {
                let precedence = Yices.constant("\(pPrefix)\(symbol)", term_tau:Yices.int_tau)
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
