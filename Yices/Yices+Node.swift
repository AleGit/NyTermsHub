//
//  Yices+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {
    
    /// Boolean type for predicates and connectives (built-in)
    static var bool_tau = yices_bool_type()
    
    /// Uninterpreted global type - the return type of uninterpreted terms 
    /// (functions or constants).
    static var free_tau : type_t {
        return type("𝛕")
    }
    
    /// Uninterpreted global constant of uninterpreted type.
    static var 🚧 : term_t {
        return Yices.constant("⊥", term_tau: free_tau)
    }
    
    static func type(name:String) -> type_t {
        assert(!name.isEmpty, "a type name must not be empty")
        var tau = yices_get_type_by_name(name)
        if tau == NULL_TYPE {
            tau = yices_new_uninterpreted_type()
            yices_set_type_name(tau,name)
        }
        return tau
    }
    
    /// Create uninterpreted global constant of type `term_tau`.
    static func constant(symbol:String, term_tau:type_t) -> term_t {
        assert(!symbol.isEmpty, "a constant symbol must not be empty")
        
        var t = yices_get_term_by_name(symbol)
        if t == NULL_TERM {
            t = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(t, symbol)
        }
        return t
    }
    
    /// Create uninterpreted global (predicate) function with uninterpreted arguments `args`
    /// of global type `free_type` (implicit) and return type `term_tau`.
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
    
    static func children(term:term_t) -> [term_t] {
        return (0..<yices_term_num_children(term)).map { yices_term_child(term, $0) }
    }
}

// MARK - Yices + Node

extension Yices {
    /// Return a yices clause and yices literals from a node clause.
    /// The children of `yicesClause` are often different from `yicesLiterals`.
    static func clause<N:Node>(clause:N) -> (
        yicesClause: term_t,
        yicesLiterals:[type_t],
        yicesLiteralsBefore:[type_t]) {
        
            // assert(clause.isClause,"'\(#function)(\(clause))' Argument must be a clause, but it is not.")
            
            let type = clause.symbolType ?? SymbolType.Predicate
            
            switch type {
            case .Disjunction:
                guard let literals = clause.nodes where literals.count > 0 else {
                    return (Yices.bot(), [term_t](), [term_t]())
                }
                
                return Yices.clause(literals)
               
                // unit clause
            case .Predicate, .Negation, .Equation, .Inequation:
                print("\(#function)(\(clause)) Argument node was not a clause, but a literal.")
                let yicesLiteral = literal(clause)
                return (yicesLiteral,[yicesLiteral],[yicesLiteral])
                
                // not a clause at all
            default:
                assert(false,"\(#function)(\(clause)) Argument is of type \(type)")
                return (Yices.bot(), [term_t](), [term_t]())
            }
            
            
    }
    
    /// Return a yices clause and yices literals from an array of node literals.
    /// The children of `yicesClause` are often different from `yicesLiterals`.
    /// `yicesLiterals` are a mapping from `literals` to yices terms, while 
    /// `yicesClause` is just equivalent to the conjunction of the `yicesLiterals`.
    /// * `true ≡ [ ⊥ = ⊥, ... ]`
    /// * `true ≡ [ p, ~p ]`
    /// * `true ≡ [ ⊥ = ⊥, ⊥ ~= ⊥ ]`
    /// * `p ≡ [ p, p ]`
    /// * `p ≡ [ ⊥ ~= ⊥, p ]`
    /// * `[p,q,q,q,q] ≡ [ p, q, ⊥ ~= ⊥, p,q ]`
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
        assert(literal.isLiteral,"'\(#function)(\(literal))' Argument must be a literal, but it is not.")
        
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
            assert(false, "'\(#function)(\(literal))' Argument must not be a \(type).")
            return yices_false()
        }
    }
    
    /// Build uninterpreted function term from term.
    static func term<N:Node>(term:N) -> term_t {
        assert(term.isTerm,"'\(#function)(\(term))' Argument must be a term, but it is not.")
        
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
