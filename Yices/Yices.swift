//
//  Yices.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation


public struct Yices {
    
    public static let version = String.fromCString(yices_version) ?? "yices_version: n/a"
    public static let buildArch = String.fromCString(yices_build_arch) ?? "yices_build_arch: n/a"
    public static let buildMode = String.fromCString(yices_build_mode) ?? "yices_build_mode: n/a"
    public static let buildDate = String.fromCString(yices_build_date) ?? "yices_build_date: n/a"
    
    public static let info = "yices \(version) (\(buildArch),\(buildMode),\(buildDate))"
    
    public static func newIntVar(name:String) -> term_t?  {
        var term: term_t? = nil
        
        let t_int = yices_int_type()
        let t = yices_new_uninterpreted_term(t_int)
        let code = yices_set_term_name(t, name)
    
        // If code is negative, something went wrong
        if code < 0 {
            print("Error \(code) in Yices.newIntVar\n")
            yices_print_error(stdout)
            fflush(stdout)
            term = nil
        } else {
            term = t

        }
    
    return term;
    }
    
    public static func newBoolVar(name:String) -> term_t?  {
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
    
    public static func top() -> term_t  {
        return yices_true()
    }
    
    public static func bot() -> term_t  {
        return yices_false()
    }
    
    public static func not(t:term_t) -> term_t  {
        return yices_not(t)
    }
    
    public static func and(t1:term_t, t2:term_t) -> term_t  {
        return yices_and2(t1,t2)
    }
    
    public static func and(t1:term_t, t2:term_t, t3:term_t) -> term_t  {
        return yices_and3(t1,t2,t3)
    }
    
    //public static func and(ts:[term_t]) -> term_t  {
    //    return yices_and(UInt32(ts.count), ts)
    //}
    
    public static func or(t1:term_t, t2:term_t) -> term_t  {
        return yices_or2(t1,t2)
    }
    
    public static func or(t1:term_t, t2:term_t, t3:term_t) -> term_t  {
        return yices_or3(t1,t2,t3)
    }
    
    public static func implies(t1:term_t, t2:term_t) -> term_t  {
        return yices_implies(t1,t2)
    }
    
    public static func ite(c:term_t, t:term_t, f:term_t) -> term_t  {
        return yices_ite(c,t,f)
    }
    
}

