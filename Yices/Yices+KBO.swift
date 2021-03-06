//
//  Yices+Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Node {

    /// self == f<sup>n</sup>(X), n ≥ 0 ?
    /// 1. f<sup>0</sup>(X)    := Xx
    /// 2. f<sup>n+1</sup>(X)  := f(f<sup>n</sup>(X))
    func isFnX(f:Symbol, _ X:Symbol) -> Bool {
        guard let nodes = self.nodes else {
             // case 1. self == X ?
            
            return self.symbol == X
        }
        
        // case 2.: self == f(f^(n+1)(X)) ?
        
        guard self.symbol == f && nodes.count == 1 else {
            return false
        }
        
        return nodes.first!.isFnX(f, X)
    }
}

extension Yices {
    static func integerVariable(symbol:String) -> term_t {
        return Yices.typedSymbol(symbol, term_tau:Yices.int_tau)
    }
    
    static func weightVariable(symbol:String) -> term_t {
        return Yices.integerVariable("w⏑\(symbol)")
    }
    
    static func precedenceVariable(symbol:String) -> term_t {
        return Yices.integerVariable("p⏑\(symbol)")
    }
}

extension Yices {
    struct KBO {
        let w0 = Yices.integerVariable("𝛚₀")
        
        var symbols = [String : (weight:term_t, precedence:term_t, arity: Int)]()
        
        var atoms : [term_t] {
            let ws = symbols.values.map { $0.weight }
            let ps = symbols.values.map { $0.precedence }
            return [w0] + ws + ps
        }

        /// Register symbol with arity and create global weight and preference typedTerms (i.e. variables).
        /// Return weight of typedSymbol. (If symbol is allready registered check if arity is consistent.)
        mutating func register(symbol:String, arity:Int) -> term_t {
            guard let (w,_,a) = symbols[symbol] else {
                let weight = Yices.weightVariable(symbol)
                let preference = Yices.precedenceVariable(symbol)
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
            guard leftRightPrerequisite(s,t) else { return Yices.bot }
            
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
                return s.isFnX(s.symbol, t.symbol) ? Yices.top : Yices.bot
            }
            
            let pf = symbols[s.symbolString()]!.precedence
            let pg = symbols[t.symbolString()]!.precedence
            
            let pf_gt_pg = Yices.gt(pf,pg)
            let pf_eq_pg = Yices.eq(pf,pg)
            
            // let count = min(snodes.count,tnodes.count)
            
            var si_gt_ti = Yices.bot
            
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
                    (f,wpaf) -> term_t in
                    let (wf,pf,_) = wpaf
                    
                    let wf_eq_0 = Yices.eq(wf,Yices.zero)
                    
                    let pf_gt_pg = symbols.map {
                        (g,wpag) -> term_t in
                        let (_,pg,_) = wpag
                        return f == g ? Yices.top : Yices.gt(pf,pg)
                    }
                    return Yices.implies(wf_eq_0, Yices.and(pf_gt_pg))
            }
            
            return Yices.and (w0gt0, Yices.and(conditions), Yices.and(unariesConditions))
        }
    }
}


