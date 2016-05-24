//
//  Yices+Node.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension Yices {
    
    typealias Tuple = (
        yicesClause: type_t,
        yicesLiterals: Set<type_t>,
        alignedYicesLiterals: [type_t]
    )
    

    
//    static func clause<N:Node, S:SymbolTable where N.Symbol == S.Symbol>(clause:N, symbolTable:S) {
//        let type = symbolTable[clause.symbol]?.type ?? SymbolType.Predicate
//        symbolTable[clause.symbol] = nil
//        
//    }
    
    /// Return a yices clause and yices literals from a node clause.
    /// The children of `yicesClause` are often different from `yicesLiterals`.
    static func clause<N:Node>(clause:N) -> Tuple /* (
        yicesClause: term_t,
        yicesLiterals:[type_t],
        alignedYicesLiterals:[type_t]) */ {
        
            // assert(clause.isClause,"'\(#function)(\(clause))' Argument must be a clause, but it is not.")
            
            let type = clause.symbolType ?? SymbolType.Predicate
            
            switch type {
            case .Disjunction:
                guard let literals = clause.nodes where literals.count > 0 else {
                    return (Yices.bot, Set<term_t>(), [term_t]())
                }
                
                return Yices.clause(literals)
               
                // unit clause
            case .Predicate, .Negation, .Equation, .Inequation:
                let message = "\(#function)(\(clause)) Argument node was not a clause, but a literal."
                print(message)
                assert(false, message)
                
                let yicesLiteral = literal(clause)
                return (yicesLiteral,[yicesLiteral],[yicesLiteral])
                
                // not a clause at all
            default:
                assert(false,"\(#function)(\(clause)) Argument is of type \(type)")
                return (Yices.bot, Set<term_t>(), [term_t]())
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
    static func clause<N:Node>(literals:[N]) -> Tuple /* (
        yicesClause: type_t,
        yicesLiterals:[type_t],
        alignedYicesLiterals:[type_t]) */ {
            
            let alignedYicesLiterals = literals.map { self.literal($0) }
            var yicesLiterals = alignedYicesLiterals
            
            // `yices_or` might change the order and content of the array
            
            let yicesClause = yices_or( UInt32(yicesLiterals.count), &yicesLiterals)
            
            return (
                yicesClause,
                Set(yicesLiterals),
                alignedYicesLiterals
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
            // literal.register(.Negation, category: .Functor, notation:.Prefix, arity:.Fixed(1))
            return yices_not( Yices.literal(nodes.first! ))
            
        case .Inequation:
            assert(nodes.count == 2, "An inequation must have exactly two children.")
            literal.register(.Inequation, category: .Equational, notation:.Infix, arity:.Fixed(2))
            
            let args = nodes.map { Yices.term($0) }
            return yices_neq(args.first!, args.last!)
            
        case .Equation:
            assert(nodes.count == 2, "An equation must have exactly two children.")
            literal.register(.Equation, category: .Equational, notation:.Infix, arity:.Fixed(2))
            let args = nodes.map { Yices.term($0) }
            return yices_eq(args.first!, args.last!)
            
        case .Predicate:
            literal.register(.Predicate, category:.Functor, notation:.Prefix, arity:.Fixed(nodes.count))
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
        
        term.register(.Function, category:.Functor, notation:.Prefix, arity:.Fixed(nodes.count))
        
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
    
    /// Uninterpreted global constant (i.e. variable) of uninterpreted type.
    static var 🚧 : term_t {
        return Yices.constant("⊥", term_tau: free_tau)
    }
}
