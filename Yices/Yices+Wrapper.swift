//
//  Yices.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

// MARK: types and terms

extension Yices {
    
    /// Boolean type for predicates and connectives (built-in)
    static var bool_tau = yices_bool_type()
    /// Integer type for linear integer arithmetic (build-in)
    static var int_tau = yices_int_type()
    
    /// Uninterpreted global type - the return type of uninterpreted terms
    /// (functions or constants).
    static var free_tau : type_t {
        return namedType("𝛕")
    }
    
    
    /// Uninterpreted global constant (i.e. variable) of uninterpreted type.
    static var 🚧 : term_t {
        return Yices.typedSymbol("⊥", term_tau: free_tau)
    }
    
    /// Get or create (uninterpreted) type `name`.
    static func namedType(name:String) -> type_t {
        assert(!name.isEmpty, "a type name must not be empty")
        var tau = yices_get_type_by_name(name)
        if tau == NULL_TYPE {
            tau = yices_new_uninterpreted_type()
            yices_set_type_name(tau,name)
        }
        return tau
    }
    
    /// Get or create uninterpreted global `symbol` of type `term_tau`.
    static func typedSymbol(symbol:String, term_tau:type_t) -> term_t {
        assert(!symbol.isEmpty, "a symbol must not be empty")
        
        var c = yices_get_term_by_name(symbol)
        if c == NULL_TERM {
            c = yices_new_uninterpreted_term(term_tau)
            yices_set_term_name(c, symbol)
        }
        else {
            assert (term_tau == yices_type_of_term(c))
        }
        return c
    }
    
    static func function(symbol:String, count:Int, term_tau:type_t) -> term_t {
        let domain_taus = [type_t](count:count, repeatedValue:Yices.free_tau)
        let f_tau = yices_function_type(UInt32(count), domain_taus, term_tau)
        
        return typedSymbol(symbol, term_tau: f_tau)
    }
    
    /// Create uninterpreted global (predicate) function `symbol` application
    /// with uninterpreted arguments `args` of implicit global type `free_type`
    /// and explicit return type `term_tau`:
    /// * `free_tau` - the symbol is a constant/function symbol
    /// * `bool_tau` - the symbol is a proposition/predicate symbol
    static func application(symbol:String, args:[term_t], term_tau:type_t) -> term_t {
        assert(!symbol.isEmpty, "a function or predicate symbol must not be empty")
        
        let f = function(symbol, count: args.count, term_tau: term_tau)
        return yices_application(f, UInt32(args.count), args)
    }
    
    /// Get yices children of a yices term.
    static func children(term:term_t) -> [term_t] {
        return (0..<yices_term_num_children(term)).map { yices_term_child(term, $0) }
    }
}

extension Yices {

    
    
    static func top() -> term_t  {
        return yices_true()
    }
    
    static func bot() -> term_t  {
        return yices_false()
    }
    
    static func not(t:term_t) -> term_t  {
        return yices_not(t)
    }
    
    static func and(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_and2(t1,t2)
    }
    
    static func and(t1:term_t, _ t2:term_t, _ t3:term_t) -> term_t  {
        return yices_and3(t1,t2,t3)
    }
    
    static func and(ts:[term_t]) -> term_t  {
        var copy = ts // array must be mutable
        return yices_and(UInt32(ts.count), &copy)
    }
    
    static func or(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_or2(t1,t2)
    }
    
    static func or(t1:term_t, _ t2:term_t, _ t3:term_t) -> term_t  {
        return yices_or3(t1,t2,t3)
    }
    
    static func or(ts:[term_t]) -> term_t  {
        var copy = ts // array must be mutable
        return yices_or(UInt32(ts.count), &copy)
    }
    
    static func implies(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_implies(t1,t2)
    }
    
    static func ite(c:term_t, t:term_t, f:term_t) -> term_t  {
        return yices_ite(c,t,f)
    }
    
    @available(*, deprecated=1.0, message="use `or(ts: [term_t]` instead.")
    static func big_or(ts : [term_t]) -> term_t {
      return ts.reduce(bot(), combine: or)
    }
    
    @available(*, deprecated=1.0, message="use `and(ts: [term_t]` instead.")
    static func big_and(ts : [term_t]) -> term_t {
        return ts.reduce(top(), combine: and)
    }
    
    static func gt(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_arith_gt_atom(t1,t2)
    }
    
    static func ge(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_arith_geq_atom(t1,t2)
    }
    
    static func eq(t1:term_t, _ t2:term_t) -> term_t {
        return yices_eq(t1,t2)
    }
    
    static func add(t1:term_t, _ t2:term_t) -> term_t  {
        return yices_add(t1, t2)
    }
    
    static func sum(ts:[term_t]) -> term_t {
        var copy = ts
        return yices_sum(UInt32(copy.count), &copy)
    }
    
    static var zero: term_t {
        return yices_int32(0)
    }
    
    static var one: term_t {
        return yices_int32(1)
    }
}

// MARK: - eval

extension Yices {
    
    static func getValue(t: term_t, mdl: COpaquePointer) -> Bool? {
        var val : Int32 = 0;
        if Yices.check (yices_get_int32_value(mdl, t, &val), label:"\(#function) : Bool") {
            return val == 0 ? false : true
        }
        else {
            return nil
        }
    }

    static func getValue(t: term_t, mdl: COpaquePointer) -> Int32? {
        var val : Int32 = 0;
        if Yices.check (yices_get_int32_value(mdl, t, &val), label:"\(#function) : Int32") {
            return val
        }
        else {
            return nil
        }
    }
}

// MARK: - variables

extension Yices {
    @available(*, deprecated=1.0, message="unused")
    static func newIntVar(name:String) -> term_t?  {
        var term: term_t? = nil
        
        let t_int = Yices.int_tau
        let t = yices_new_uninterpreted_term(t_int)
        let code = yices_set_term_name(t, name)
        
        // If code is negative, something went wrong
        if code < 0 {
            print("Error \(code) in \(#function).")
            yices_print_error(stdout)
            fflush(stdout)
            term = nil
        } else {
            term = t
            
        }
        
        return term;
    }
    
    @available(*, deprecated=1.0, message="unused")
    static func newBoolVar(name:String) -> term_t?  {
        var term: term_t? = nil
        
        let t_int = Yices.bool_tau
        let t = yices_new_uninterpreted_term(t_int)
        let code = yices_set_term_name(t, name)
        
        // If code is negative, something went wrong
        if code < 0 {
            print("Error \(code) in \(#function)\n")
            yices_print_error(stdout)
            fflush(stdout)
            term = nil
        } else {
            term = t
        }
        
        return term;
    }
}



