//
//  Yices+Order.swift
//  NyTerms
//
//  Created by Alexander Maringele on 18.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol Mapper {
    associatedtype Symbol : Hashable
    associatedtype Value
    var vars : [Symbol : Value] { get set }
    var prefix : String { get }
    mutating func register(symbol:Symbol) -> Value
}

extension Mapper {
    subscript(symbol:Symbol) -> Value {
        return vars[symbol]!    // crashes if symbol was not registered
    }
}

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
    struct YicesTerms : Mapper {
        typealias Symbol = String
        typealias Value = term_t
        
        var vars = [String : term_t]()
        let prefix : String
        
        init(prefix:String) { self.prefix = prefix }
        
        mutating func register(symbol:String) -> term_t {
            
            guard let entry = vars[symbol] else {
                let newEntry = Yices.constant("\(prefix)\(symbol)", term_tau:Yices.int_tau)
                vars[symbol] = newEntry
                return newEntry
            }
            return entry
        }
        
        subscript(symbol:String) -> term_t {
            return vars[symbol]!    // crash if symbol is not registered!
        }
    }
    
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
        
        mutating func orientable<N:Node>(s:N, _ t:N) -> term_t {
            guard preconditional(s,t) else { return Yices.bot() }
            
            let ws = weight(s)
            let wt = weight(t)
            
            let ws_gt_wt = Yices.gt(ws, wt)
            let ws_eq_wt = Yices.eq(ws, wt)
            let condition = preferencable(s,t)
            
            let c = Yices.or(
                ws_gt_wt,
                Yices.and(ws_eq_wt, condition)
            )
            
            return c
        }
        
        private func preconditional<N:Node>(s:N, _ t:N) -> Bool {
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
        
        mutating private func preferencable<N:Node>(s:N, _ t:N) -> term_t {
            assert(preconditional(s,t), "preconditional was not called before")
            
            // we know preconditional(s,t) is holding, hence
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
                    si_gt_ti = orientable(si,ti)
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
    
    struct oldKBO {
        
        private var precedences = YicesTerms(prefix: "p⏑")
        private var weights = YicesTerms(prefix: "w⏑")
        var arities = [String : Int]()
        private var w0 = Yices.constant("𝛚₀", term_tau:Yices.int_tau)
        
        var atoms : [term_t] {
            return [w0] + Array(weights.vars.values) + Array(precedences.vars.values)
        }
        
        subscript(symbol:String) -> Int {
            get {
                guard let value = arities[symbol] else {
                    assert(false,"Function symbol \(symbol) has not registered arity.")
                    return -1
                }
                return value
            }
            set {
                guard let value = arities[symbol] else {
                    arities[symbol] = newValue
                    return
                }
                
                assert(value == newValue, "Function symbol \(symbol) must not be variadic (old=\(value),new=\(newValue))")
            }
        }
        
        
        
        
        
        
        mutating func weight<N:Node>(t:N) -> term_t {
            
            guard let nodes = t.nodes else {
                // w(t) = w_0 if t is a variable
                return w0
            }
            
            let symbol = t.symbolString()
            self[symbol] = nodes.count  // register arity
            
            // w(t) = w(f) + w(t_1) + ... w(t_n) if t = f(t_1,...,t_n)
            
            let w_f = self.weights.register(symbol)
            self.precedences.register(symbol)

            let summands = [ w_f ] + nodes.map { weight($0) }
            let sum = Yices.sum(summands)
            return sum
        }
        
        func comparable<N:Node>(s:N, _ t:N) -> Bool {
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
        
        mutating func orientable<N:Node>(s:N, _ t:N) -> term_t {
            guard comparable(s,t) else { return Yices.bot() }

            let ws = weight(s)
            let wt = weight(t)
            
            let ws_gt_wt = Yices.gt(ws, wt)
            let ws_eq_wt = Yices.eq(ws, wt)
            let condition = porientable(s,t)
            
            let c = Yices.or(
                ws_gt_wt,
                Yices.and(ws_eq_wt, condition)
            )
            
            return c
            
            
            
        }
        
        mutating func porientable<N:Node>(s:N, _ t:N) -> term_t {
            assert(comparable(s,t))
            
            // we know comparable(s,t) holds, hence
            // * s is not a variable
            // * s != t
            // * t does not increase the occurences of each variable
            
            let snodes = s.nodes!
            
            guard let tnodes = t.nodes else {
                return s.isFnX(s.symbol, t.symbol) ? Yices.top() : Yices.bot()
            }
            
            let pf = precedences[s.symbolString()]
            let pg = precedences[t.symbolString()]
            
            let pf_gt_pg = Yices.gt(pf,pg)
            let pf_eq_pg = Yices.eq(pf,pg)
            
            // let count = min(snodes.count,tnodes.count)
            
            var si_gt_ti = Yices.bot()
            
            for (si,ti) in zip(snodes,tnodes) {
                if si != ti {
                    si_gt_ti = orientable(si,ti)
                    break
                }
            }
            
            return Yices.or(
                pf_gt_pg,
                Yices.and(pf_eq_pg,si_gt_ti)
            )
        }
        
        
        
        var admissible : term_t {
            // w_0 > 0 (condition for weight function)
            let w0Condition = Yices.gt(w0,Yices.zero)
            
            let conditions = arities.map {
                (s,arity) -> term_t in
                if arity == 0 {
                    // w_c ≥ w_0
                    return Yices.ge(weights[s],w0)
                }
                else {
                    // w_f ≥ 0 (non-negative)
                    return Yices.ge(weights[s],Yices.zero)
                }
            }
            
            
            let unariesConditions = arities.filter { $0.1 == 1 }.map {
                (f,_) -> term_t in
                let wf_eq_0 = Yices.eq(weights[f], Yices.zero)
                let pf = precedences[f]
                let pg_ge_pf = precedences.vars.map {
                    (_,pg) -> term_t in
                    Yices.ge(pg,pf)
                }
                return Yices.implies(wf_eq_0, Yices.and(pg_ge_pf))
            }
            
            return Yices.and(w0Condition,
                             Yices.and(conditions),
                             Yices.and(unariesConditions)
            )
        }
    }
}
