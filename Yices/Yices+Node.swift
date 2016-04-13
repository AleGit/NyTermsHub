//
//  Yices+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {
    /// built-in type for terms
    static var free_tau = yices_int_type()
    
    /// built-in type for predicates and connectives
    static var bool_tau = yices_bool_type()
    
    /// Distinct global constant that substitues all variables in terms.
    /// Since yices_exit() or yices_reset() could have been fired between calls
    /// of `🚧` it has to be a calculated property.
    static var 🚧 : term_t {
        return Yices.constant("⊥", term_tau: free_tau)
    }
    
    static func constant(symbol:String, term_tau:type_t) -> term_t {
        assert(!symbol.isEmpty, "a constant symbol must not be empty")
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            t = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(t, symbol)
        }
        return t
    }
    
    static func application(symbol:String, args:[term_t], term_tau:type_t) -> term_t {
        assert(!symbol.isEmpty, "a function or predicate symbol must not be empty")
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            let domain_taus = [type_t](count:args.count, repeatedValue:Yices.free_tau)
            let func_tau = yices_function_type(UInt32(args.count), domain_taus, term_tau)
            t = yices_new_uninterpreted_term(func_tau)
            yices_set_term_name(t,symbol)
        }
        
        return yices_application(t, UInt32(args.count), args)
    }
}

extension Yices {
    static func clause<N:Node>(clause:N) -> (
        yicesClause: term_t,
        yicesLiterals:[term_t],
        yicesLiteralsBefore:[type_t]) {
        
            assert(clause.isClause,"\(clause) must be a clause, but is not.")
            
            guard let literals = clause.nodes where literals.count > 0 else {
                return (Yices.bot(), [term_t](), [term_t]())
            }
            
            return Yices.clause(literals)
    }
    
    static func clause<N:Node>(literals:[N]) -> (
        yicesClause: type_t,
        yicesLiterals:[type_t],
        yicesLiteralsBefore:[type_t]) {
            
            let yicesLiteralsBefore = literals.map { self.literal($0) }
            var yicesLiterals = yicesLiteralsBefore
            
            // `yices_or` might change the order and content of the array
            
            let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)

            
            return (
                yicesClause,
                yicesLiterals,
                yicesLiteralsBefore
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
        
        // By default a symbol is a predicate symbol
        // if it is not predefined or registered.
        let type = literal.symbolType ?? SymbolType.Predicate
        
        switch type {
        case .Negation:
            assert(nodes.count == 1, "A negation must have exactly one child.")
            return yices_not( Yices.literal(nodes.first! ))
            
        case .Inequation:
            assert(nodes.count == 2, "An inequation must have exactly two children.")
            let args = nodes.map { Yices.term($0) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2, "An equation must have exactly two children.")
            let args = nodes.map { Yices.term($0) }
            return yices_eq(args.first!, args.last!)
            
        case .Predicate:
            // proposition or predicate term (an application of Boolean type)
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
        
        // function or constant term (an application of uninterpreted type)
        return Yices.application(term.symbolString(), nodes:nodes, term_tau:Yices.free_tau)
    }
    
    /// Build (constant) predicate or function.
    static func application<N:Node>(symbol:String, nodes:[N], term_tau:type_t) -> term_t {
        
        guard nodes.count > 0 else {
            return constant(symbol,term_tau: term_tau)
        }
        
        return application(symbol, args: nodes.map { Yices.term($0) }, term_tau: term_tau)
    }
}
