//
//  Yices.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

// MARK: yices info
struct Yices {
    
    static let version = String.fromCString(yices_version) ?? "yices_version: n/a"
    static let buildArch = String.fromCString(yices_build_arch) ?? "yices_build_arch: n/a"
    static let buildMode = String.fromCString(yices_build_mode) ?? "yices_build_mode: n/a"
    static let buildDate = String.fromCString(yices_build_date) ?? "yices_build_date: n/a"
    
    static let info = "yices \(version) (\(buildArch),\(buildMode),\(buildDate))"
}

// MARK: - yices + LIA
extension Yices {

    static func newIntVar(name:String) -> term_t?  {
        var term: term_t? = nil
        
        let t_int = yices_int_type()
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
    
    static func newBoolVar(name:String) -> term_t?  {
        var term: term_t? = nil
        
        let t_int = yices_bool_type()
        let t = yices_new_uninterpreted_term(t_int)
        let code = yices_set_term_name(t, name)
        
        // If code is negative, something went wrong
        if code < 0 {
            print("Error \(code) in Yices.newBoolVar\n")
            yices_print_error(stdout)
            fflush(stdout)
            term = nil
        } else {
            term = t
        }
        
        return term;
    }
    
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
    
    static func big_or(ts : [term_t]) -> term_t {
      return ts.reduce(bot(), combine: or)
    }
    
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
    
    static func eval_int(t: term_t, m: COpaquePointer) -> Int32 {
        var val : Int32 = 0;
        yices_get_int32_value(m, t, &val)
        return val;
    }
    
}

