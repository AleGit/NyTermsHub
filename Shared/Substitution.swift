//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

extension Dictionary where Key:Term, Value:Term { // , Key == Value does not work
    ///
    private var isHomogenous : Bool {
        return self.keys.first?.dynamicType == self.values.first?.dynamicType
    }
    
    /// Are *variables* mapped to terms?
    private var allKeysAreVariables : Bool {
        return Array(self.keys).reduce(true) {
            $0 && $1.terms == nil
        }
    }
    
    /// Are terms mapped to *variables*?
    private var allValuesAreVariables : Bool {
        return Array(self.values).reduce(true) {
            $0 && $1.terms == nil
        }
    }
    
    /// Are distinct terms mapped to *distinguishable* terms?
    private var isInjective : Bool {
        return self.keys.count == Set(self.values).count
    }
    
    /// A substitution maps variables to terms.
    public var isSubstitution : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables
    }
    
    /// A variable substitution maps variables to variables.
    public var isVariableSubstitution : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables
    }
    
    /// A (variable) renaming maps distinct variables to distinguishable variables.
    public var isRenaming : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables && isInjective
    }
}

/// 's =?= t' constructs most common unifier iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*.
public func =?=<T:Term>(lhs:T, rhs:T) -> [T:T]? {
    
    switch(lhs.isVariable,rhs.isVariable) {
    case (true, true):
        return [lhs:rhs]
    case (true,_):
        assert(!rhs.allVariables.contains(lhs)) // occur check
        return [lhs:rhs]
    case (_,true):
        assert(!lhs.allVariables.contains(rhs)) // occur check
        return [rhs:lhs]
    case (_, _) where lhs.terms!.count == rhs.terms!.count:
        var result = [T:T]()
        
        for (s,t) in zip(lhs.terms!, rhs.terms!) {
            guard let mappings = s =?= t else { return nil }
            for (variable, term) in mappings {
                let value = result[variable]
                if value == nil { result[variable] = term }
                else if value != term { return nil }
            }
        }
        return result
    default:
        return nil
    }
}

/// 't * σ' applies substitution σ on term t.
public func *<T:Term>(t:T, σ:[T:T]) -> T {
    assert(σ.isSubstitution)
    
    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys
    
    guard let terms = t.terms else { return t }
    
    return T(symbol:t.symbol, terms: terms.map { $0 * σ })
    
}

/// 't ** s' replaces all variables in t with term s.
public func **<T:Term>(t:T, s:T) -> T {
    guard let terms = t.terms else { return s }
    
    return T(symbol:t.symbol, terms: terms.map { $0 ** s })
}

/// 't**' replaces all variables in t with constant '⊥'.
public postfix func **<T:Term>(t:T) -> T {
    return t ** T(constant:"⊥")
}

/// 'σ * ρ' concatinates substitutions σ and ρ.
public func *<T:Term> (lhs:[T:T], rhs:[T:T]) -> [T:T] {
    var concat = [T:T]()
    for (lkey,lvalue) in lhs {
        concat[lkey] = lvalue * rhs
    }
    for (rkey, rvalue) in rhs {
        if lhs[rkey] == nil {
            concat[rkey] = rvalue
        }
    }
    return concat
}



