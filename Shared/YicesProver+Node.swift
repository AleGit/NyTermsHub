//
//  YicesProver+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 08.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol YicesProver {
    var free_tau : type_t { get }
    var bool_tau : type_t { get }
    var 🚧 : term_t { get }
    
    var runtime : CFTimeInterval { get }
}

extension YicesProver {
    private func term(symbol:Symbol, term_tau:type_t) -> term_t {
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            t = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(t, symbol)
        }
        return t
        
    }
    
    private func term<N:Node>(symbol:Symbol, nodes:[N], term_tau:type_t) -> term_t {
        
        guard nodes.count > 0 else {
            return term(symbol,term_tau: term_tau)
        }
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            let domain_taus = [type_t](count:nodes.count, repeatedValue:term_tau)
            let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, term_tau)
            t = yices_new_uninterpreted_term(func_tau)
            yices_set_term_name(t,symbol)
        }
        
        
        let args = nodes.map { $0.yicesTerm(self) }
        let appl = yices_application(t, UInt32(args.count), args)
        return appl
        
    }
}

extension Node {
    /// Build yices clause from clause `self`
    func yicesClause<Y:YicesProver>(y:Y) -> (clause:term_t,literals:[term_t]) {
        assert(self.isClause,"\(self) is not a clause.")
        
        guard let literals = self.nodes where literals.count > 0 else {
            // an empty clause represents a contradiction
            return (clause:yices_false(), literals:[term_t]())
        }
        
        var yicesLiterals = literals.map { $0.yicesLiteral(y) }
        let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
        
        return (yicesClause, yicesLiterals)
    }
    
    func yicesLiteral<Y:YicesProver>(y:Y) -> term_t {
        assert(self.isLiteral,"\(self) is not a literal")
        
        guard let nodes = self.nodes
            else {
                return yices_false()
        }
        
        let type = self.symbol.type ?? SymbolType.Predicate
        
        switch type {
        case .Negation:
            assert(nodes.count == 1)
            return yices_not( nodes.first!.yicesLiteral(y))
            
        case .Inequation:
            assert(nodes.count == 2)
            let args = nodes.map { $0.yicesTerm(y) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2)
            let args = nodes.map { $0.yicesTerm(y) }
            return yices_eq(args.first!, args.last!)
           
        case .Predicate:
            // proposition or predicate term
            return y.term(self.symbol, nodes:nodes, term_tau: y.bool_tau)
            
        default:
            assert(false, "This must not happen.")
            return yices_false()
        }
    }
    
    /// Build a yices term from term `self`.
    func yicesTerm<Y:YicesProver>(y:Y) -> term_t {
        assert(self.isTerm,"\(self) is not a term.")
        guard let nodes = self.nodes else {
            return y.🚧 // substitute all variables with global constant '⊥'
        }
        
        // function or constant term
        return y.term(self.symbol, nodes:nodes, term_tau:y.free_tau)
    }
}