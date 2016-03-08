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
    
    /// Build yices disjunction from clause.
    func clause<N:Node>(clause:N) -> (clause:term_t,literals:[term_t]) {
        assert(clause.isClause,"\(clause) is not a clause.")
        
        guard let literals = clause.nodes where literals.count > 0 else {
            // an empty clause represents a contradiction
            return (clause:yices_false(), literals:[term_t]())
        }
        
        var yicesLiterals = literals.map { self.literal($0) }
        let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
        
        return (yicesClause, yicesLiterals)
    }
    
    /// Build boolean term from literal.
    private func literal<N:Node>(literal:N) -> term_t {
        assert(literal.isLiteral,"\(literal) is not a literal")
        
        guard let nodes = literal.nodes
            else {
                return yices_false()
        }
        
        let type = literal.symbol.type ?? SymbolType.Predicate
        
        switch type {
        case .Negation:
            assert(nodes.count == 1)
            return yices_not( self.literal(nodes.first! ))
            
        case .Inequation:
            assert(nodes.count == 2)
            let args = nodes.map { self.term($0) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2)
            let args = nodes.map { self.term($0) }
            return yices_eq(args.first!, args.last!)
            
        case .Predicate:
            // proposition or predicate term
            return self.application(literal.symbol, nodes:nodes, term_tau: self.bool_tau)
            
        default:
            assert(false, "This must not happen.")
            return yices_false()
        }
    }
    
    /// Build uninterpreted function term from term.
    private func term<N:Node>(term:N) -> term_t {
        assert(term.isTerm,"\(term) is not a term.")
        guard let nodes = term.nodes else {
            return self.🚧 // substitute all variables with global constant '⊥'
        }
        
        // function or constant term
        return self.application(term.symbol, nodes:nodes, term_tau:self.free_tau)
    }
    
    /// Build predicate or function.
    private func application<N:Node>(symbol:Symbol, nodes:[N], term_tau:type_t) -> term_t {
        
        guard nodes.count > 0 else {
            return constant(symbol,term_tau: term_tau)
        }
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            let domain_taus = [type_t](count:nodes.count, repeatedValue:self.free_tau)
            let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, term_tau)
            t = yices_new_uninterpreted_term(func_tau)
            yices_set_term_name(t,symbol)
        }
        
        
        let args = nodes.map { self.term($0) }
        let appl = yices_application(t, UInt32(args.count), args)
        return appl
        
    }
    
    /// Build proposition or constant.
    private func constant(symbol:Symbol, term_tau:type_t) -> term_t {
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            t = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(t, symbol)
        }
        return t
        
    }
}