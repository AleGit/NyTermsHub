//
//  MingyProver.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol YicesProver {
    var free_tau : type_t { get }
    var bool_tau : type_t { get }
    var 🚧 : term_t { get }
    
    var runtime : CFTimeInterval { get }
}

extension Node {
    func yicesClause<Y:YicesProver>(y:Y) -> (clause:term_t,literals:[term_t]) {
        
        guard let literals = self.nodes where literals.count > 0 else {
            // an empty clause represents a contradiction
            return (clause:yices_false(), literals:[term_t]())
        }
        
        var yicesLiterals = literals.map { $0.yicesTerm(y, term_tau:y.bool_tau) }
        let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
        
        return (yicesClause, yicesLiterals)
        
    
    }
    
    func yicesTerm<Y:YicesProver>(y:Y, term_tau:type_t) -> term_t {
        guard let nodes = self.nodes else {
            assert(term_tau == y.free_tau)
            return y.🚧 // substitute all variables with global constant '⊥'
        }
        
        guard let type = self.symbol.type else {
            // proposition : bool, predicate : (free^n) -> bool,
            // constant : free, or function : (free^n) -> free.
            
            var t = yices_get_term_by_name(self.symbol)
            
            if t == NULL_TERM {
                if nodes.count == 0 {
                    // proposition : bool (term_tau)
                    // or constant : free (term_tau)
                    t = yices_new_uninterpreted_term(term_tau)
                    yices_set_term_name(t, self.symbol)
                }
                else {
                    // predicate    : (free^n) -> bool (term_tau)
                    // or function  : (free^n) -> free (term_tau)
                    let domain_taus = [type_t](count:nodes.count, repeatedValue:y.free_tau)
                    let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, term_tau)
                    t = yices_new_uninterpreted_term(func_tau)
                    yices_set_term_name(t, self.symbol)
                    
                }
                
            }
            
            if nodes.count > 0 {
                // application: ((free^n) -> range) . (free^n)
                
                let args = nodes.map { $0.yicesTerm(y, term_tau:y.free_tau) }
                let appl = yices_application(t, UInt32(args.count), args)
                return appl // : range
            }
            else {
                return t // : range
            }
            
        }
        
        assert(term_tau == y.bool_tau)
        
        switch type {
        case .Negation:
            assert(nodes.count == 1)
            return yices_not( nodes.first!.yicesTerm(y, term_tau:y.bool_tau))
            
        case .Inequation:
            assert(nodes.count == 2)
            let args = nodes.map { $0.yicesTerm(y, term_tau:y.free_tau) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2)
            let args = nodes.map { $0.yicesTerm(y, term_tau:y.free_tau) }
            return yices_eq(args.first!, args.last!)
            
          
        default:
            assert(false)
            return yices_false()
            
        }
    }
}

class MingyProver<T:Node> : YicesProver {
    
    private let ctx : COpaquePointer
    let free_tau = yices_int_type()
    let bool_tau = yices_bool_type()
    let 🚧 : term_t
    
    private let literalsTrie = TrieClass<SymHop,Int>()
    private let clausesTrie = TrieClass<SymHop,Int>()
    
    private var repository = [(T, literalIndex:Int?, yices:(clause:term_t,literals:[term_t]))]()
    
    private lazy var startTime : CFAbsoluteTime = CFAbsoluteTimeGetCurrent()
    var runtime : CFTimeInterval {
        return CFAbsoluteTimeGetCurrent() - startTime
    }
    
    init<S:SequenceType where S.Generator.Element == T> (clauses:S) {
        // Create yices context. yices_init() must have been called allready.
        self.ctx = yices_new_context(nil)
        
        self.🚧 = yices_new_uninterpreted_term(free_tau)
        yices_set_term_name(self.🚧, "⊥")
        
        self.repository += clauses.map {
            ($0, nil, $0.yicesClause(self))
        }
    }
    
    deinit {
        // Destroy yices context. `yices_exit()` should be called eventually.
        yices_free_context(ctx)
    }
}

extension MingyProver {
    
    func run(maxRuntime:CFTimeInterval = 1) -> smt_status {
        initialYicesAssert()
        
        while runtime < maxRuntime && yices_check_context(ctx,nil) == STATUS_SAT {
                // derive()
        }
        
        return yices_check_context(ctx,nil)
    }
    
}

extension MingyProver {
    func initialYicesAssert() {
        let unasserted = self.clauses.map {
            $0.yices.clause
        }
        yices_assert_formulas(self.ctx, UInt32(unasserted.count), unasserted)
    }
}
