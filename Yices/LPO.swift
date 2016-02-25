//
//  LPO.swift
//  NyTerms
//
//  Created by Sarah Winkler on 24/09/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation


extension Node {
    
    var subterms : [Self] {
        guard nodes != nil else { return [self] }
        return nodes!.reduce([self], combine: { return $0 + $1.subterms})
    }
    
    func is_subterm (t: Self) -> Bool {
      return t.subterms.contains(self)
    }
}



func &&(t1:term_t, t2:term_t) -> term_t {
    return Yices.and(t1,t2: t2)
}

func ||(t1:term_t, t2:term_t) -> term_t {
    return Yices.or(t1,t2: t2)
}

prefix func !(t:term_t) -> term_t {
    return Yices.not(t)
}

func >>(t1:term_t, t2:term_t) -> term_t {
    return Yices.gt(t1, t2: t2)
}

func >>=(t1:term_t, t2:term_t) -> term_t {
    return Yices.ge(t1, t2: t2)
}

func +(t1:term_t, t2:term_t) -> term_t {
    return Yices.add(t1, t2: t2)
}


func lex<T:Node>(ts:[T], ss:[T], gt:(T, T) -> term_t, ge:(T, T) -> term_t) -> term_t {
    let lex_fold = {(res: (term_t, term_t), ti_si : (T, T)) -> (term_t, term_t) in
        let (is_ge, is_gt) = res
        let (ti, si) = ti_si
        return (is_ge && ge(ti, si), is_gt || (is_ge && gt(ti, si)))
    }
    return zip(ss,ts).reduce((Yices.top(), Yices.bot()), combine: lex_fold).1
}

struct Precedence {
    
    var vars = [Symbol: term_t]() // precedence variables
    
    var count :Int? = nil          // counter value for this particular LPO instance
    
    init(count: Int, fs:[Symbol]){
        self.count = count
        for f in fs {
            let name = "prec" + String(count) + f
            self.vars[f] = Yices.newIntVar(name)
        }
    }
    
    func get(f:Symbol) -> term_t {
        return vars[f]!
    }
    
    /*
    func eval(model: model_t) -> [(Symbol, Int)] {
    return precedence.map({ (f, v) -> (Symbol, Int) in (f, Yices.eval_int(model, v)) })
    }*/
}


struct LPO {
    
    var prec: Precedence
    
    var count: Int          // counter value for this particular LPO instance
    
    init(count:Int, fs:[Symbol]) {
        self.count = count
        prec = Precedence(count: count, fs: fs)
    }
    
    func ge<T:Node>(l:T, r:T) -> term_t  {
        return l.isEqual(r) ? Yices.top() : Yices.bot()
    }
    
    func gt<T:Node>(l:T, r:T) -> term_t {
        guard l.isTerm else { return Yices.bot() }
        guard r.is_subterm(l) else { return Yices.top() }
        guard r.isTerm else { return Yices.bot() } // subterm case already handled
        
        let case1 = Yices.big_or(l.subterms.map({(li: T) -> term_t in gt(li, r: r)}))
        if l.symbol != r.symbol {
            let case2 = Yices.ge(prec.get(l.symbol), t2: prec.get(r.symbol)) &&
                        Yices.big_and(r.subterms.map({(ri: T) -> term_t in gt(l, r: ri)}))
            return case1 || case2
        } else {
            let case3: term_t = lex(l.nodes!, ss: r.nodes!, gt: gt, ge: ge)
            return case1 || case3
        }
        
    }
    
    /*
    func eval(model: model_t) -> [(Symbol, Int)] {
        return precedence.map({ (f, v) -> (Symbol, Int) in (f, Yices.eval_int(model, v)) })
    }*/
    
}

struct KBO {
    
    var prec: Precedence
    var weight_vars: [Symbol: term_t]
    var w0: term_t
    
    var count: Int
    
    init(count:Int, fs:[Symbol]) {
        self.count = count
        prec = Precedence(count: count, fs: fs)
        weight_vars = [Symbol: term_t]()
        w0 = Yices.one
        for f in fs {
            let name = "kbo" + String(count) + f
            self.weight_vars[f] = Yices.newIntVar(name)
        }
    }
    
    func weight<T:Node>(t:T) -> term_t {
        guard t.isTerm else { return w0 }
        let ws = t.nodes!.map(weight)
        return weight_vars[t.symbol]! + ws.reduce(0, combine: +)
    }
    
    func ge<T:Node>(l:T, r:T) -> term_t  {
        return l.isEqual(r) ? Yices.top() : Yices.bot()
    }
    
    func gt<T:Node>(l:T, r:T) -> term_t {
        guard l.isTerm else { return Yices.bot() }
        guard r.is_subterm(l) else { return Yices.top() }
        guard r.isTerm else { return Yices.bot() } // subterm case already handled
        
        let w_l = weight(l)
        let w_r = weight(r)
        let w_gt = w_l >> w_r, w_ge = w_l >>= w_r
        var dec: term_t
        if l.symbol != r.symbol {
            dec = Yices.gt(prec.get(l.symbol), t2: prec.get(r.symbol))
        } else {
            dec = lex(l.nodes!, ss: r.nodes!, gt: gt, ge: ge)
        }
        return w_gt || (w_ge && dec)
    }
    /*
    func eval(model: model_t) -> [(Symbol, Int)] {
    return precedence.map({ (f, v) -> (Symbol, Int) in (f, Yices.eval_int(model, v)) })
    }*/
    
}