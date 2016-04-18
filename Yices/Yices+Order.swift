//
//  Yices+Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {
    struct Precedence {
        private let vars : [String : term_t]
        
        init(symbols:[String]) {
            var tempvars = [String : term_t]()
            for f in symbols {
                tempvars[f] = Yices.constant("p_\(f)", term_tau:Yices.int_tau)
            }
            self.vars = tempvars
        }
        
        subscript(symbol:String) -> term_t {
            return self.vars[symbol]!
        }
    }
    
    struct KBO {
        private let w_0 : term_t
        private let precedence : Precedence
        private let vars : [String : term_t]
        
        init(symbols:[String]) {
            self.w_0 = Yices.constant("w_0", term_tau:Yices.int_tau)
            self.precedence = Precedence(symbols: symbols)
            
            var tempvars = [String : term_t]()
            for f in symbols {
                let name = "kbo_\(f)"
                tempvars[f] = Yices.constant(name, term_tau:Yices.int_tau)
                
            }
            self.vars = tempvars
        }
        
        subscript(symbol:String) -> term_t {
            return self.vars[symbol]!
        }
        
        func weight<N:Node>(node:N) -> term_t {
            guard let nodes = node.nodes else {
                return self.w_0
            }
            let w_f = vars[node.symbolString()]!
            let weights = [w_f] + nodes.map { weight($0) }
            
            return Yices.sum(weights)
        }
        
        private func countedVariablesDoNotMatch<N:Node>(lhs:N,_ rhs:N) -> Bool {
            let lcv = lhs.countedVariables
            
            for (key,rvalue) in rhs.countedVariables {
                guard let lvalue = lcv[key] where lvalue >= rvalue
                    else { return true }
            }
            return false
            
        }
        
        func gt<N:Node>(s:N,_ t:N) -> term_t {
            
            if s.isVariable || s == t || countedVariablesDoNotMatch(s,t) {
                return Yices.bot()
            }
            
            // we know
            // s is not a variable
            // s is not equal to t
            // |s|_x >= |t|_x for all variables x
            
            let ws = weight(s)
            let wt = weight(t)
            
            let wsgtwt = Yices.gt(ws,wt)
            let wseqwt = Yices.eq(ws,wt)
            return Yices.or(
                wsgtwt,
                Yices.and(wseqwt, gt2(s,t))
            )
            
            
        }
        
        private func gt2<N:Node>(s:N, _ t:N) -> term_t {
            guard let snodes = s.nodes else {
                assert(false, "\(#function)(\(s),_) first argument must not be a variable.")
                return Yices.bot()
            }
            
            // we know: s is not a variable
            
            guard let tnodes = t.nodes else {
                let cs = s.countedSymbols
                if (Set(cs.keys) == Set([s.symbol, t.symbol])) {
                    return Yices.top()
                }
                return Yices.bot()
            }
            
            // we know: t is not a variable
            
            
            let ps = precedence[s.symbolString()]
            let pt = precedence[t.symbolString()]
            
            let psgtpt = Yices.gt( ps, pt )
            let pseqpt = Yices.eq( ps, pt )
            
            let count = min(snodes.count,tnodes.count)
            
            let pairs = zip(snodes[0..<count],tnodes[0..<count])
            
            for (si,ti) in pairs {
                if si != ti {
                    let sigtti = self.gt(si,ti)
                    return Yices.or(
                        psgtpt,
                        Yices.and(pseqpt, sigtti)
                    )
                }
            }
            
            return Yices.bot()
            
            
        }
        
        
    }
    
}
