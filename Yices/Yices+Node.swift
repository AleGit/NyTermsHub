//
//  Yices+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {
    static var free_tau : type_t {
        return yices_int_type()
    }
    
    static var bool_tau : type_t {
        return yices_bool_type()
    }
    
    static var 🚧 : term_t {
        return Yices.constant("⊥", term_tau: free_tau)
    }
}

extension Yices {
    private static func constant(symbol:String, term_tau:type_t) -> term_t {
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            t = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(t, symbol)
        }
        return t
    }
}

extension Yices {
    static func clause<N:Node>(clause:N) -> (literals:[N], yicesClause: type_t, yicesLiterals:[type_t], selected:Int?) {
        assert(clause.isClause,"\(clause) must be a clause, but is not.")
        
        guard let literals = clause.nodes where literals.count > 0 else {
            return ([N](), Yices.top(), [term_t](), nil)
        }
        
        return Yices.literals(literals)
    }
    
    static func literals<N:Node>(literals:[N]) -> (literals:[N], yicesClause: type_t, yicesLiterals:[type_t], selected:Int?) {
        
        var yicesLiterals = literals.map { self.literal($0) }
        
        
        let permuter = literals.permuter()(before:yicesLiterals)
        
        let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
        // yices_or might change the order of the array
        
        
        return (
            permuter(after:yicesLiterals),
            yicesClause,
            yicesLiterals,
            nil
        )
        
        
        
    }
    
    /// Build boolean term from literal, i.e.
    /// - a negation
    /// - an equation
    /// - an inequation
    /// - a predicatate term or a proposition constant
    static func literal<N:Node>(literal:N) -> term_t {
        assert(literal.isLiteral,"'\(literal)' is not a literal.")
        
        guard let nodes = literal.nodes
            else {
                return yices_false()
        }
        
        let type = literal.symbolType ?? SymbolType.Predicate
        
        switch type {
        case .Negation:
            assert(nodes.count == 1)
            return yices_not( Yices.literal(nodes.first! ))
            
        case .Inequation:
            assert(nodes.count == 2)
            let args = nodes.map { Yices.term($0) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2)
            let args = nodes.map { Yices.term($0) }
            return yices_eq(args.first!, args.last!)
            
        case .Predicate:
            // proposition or predicate term
            return Yices.application(literal.symbolString(), nodes:nodes, term_tau: Yices.bool_tau)
            
        default:
            assert(false, "This must not happen.")
            return yices_false()
        }
    }
    
    /// Build uninterpreted function term from term.
    static func term<N:Node>(term:N) -> term_t {
        assert(term.isTerm,"'\(term)' is not a term.")
        guard let nodes = term.nodes else {
            return Yices.🚧 // substitute all variables with global constant '⊥'
        }
        
        // function or constant term
        return Yices.application(term.symbolString(), nodes:nodes, term_tau:Yices.free_tau)
    }
    
    /// Build predicate or function.
    static func application<N:Node>(symbol:String, nodes:[N], term_tau:type_t) -> term_t {
        
        guard nodes.count > 0 else {
            return constant(symbol,term_tau: term_tau)
        }
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            let domain_taus = [type_t](count:nodes.count, repeatedValue:Yices.free_tau)
            let func_tau = yices_function_type(UInt32(nodes.count), domain_taus, term_tau)
            t = yices_new_uninterpreted_term(func_tau)
            yices_set_term_name(t,symbol)
        }
        
        
        let args = nodes.map { Yices.term($0) }
        let appl = yices_application(t, UInt32(args.count), args)
        return appl
        
    }
    
    
    
}
