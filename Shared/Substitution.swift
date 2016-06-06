//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

extension Dictionary where Key:Node, Value:Node { // , Key == Value does not work
    /// Do the runtime types of keys and values match?
    private var isHomogenous : Bool {
        return self.keys.first?.dynamicType == self.values.first?.dynamicType
    }
    
    /// Are *variables* mapped to terms?
    private var allKeysAreVariables : Bool {
        return Array(self.keys).reduce(true) {
            $0 && $1.nodes == nil
        }
    }
    
    /// Are terms mapped to *variables*?
    private var allValuesAreVariables : Bool {
        return Array(self.values).reduce(true) {
            $0 && $1.nodes == nil
        }
    }
    
    /// Are distinct terms mapped to *distinguishable* terms?
    private var isInjective : Bool {
        return self.keys.count == Set(self.values).count
    }
    
    /// A substitution maps variables to terms.
    ///
    /// see **Definition 2.1.23.** in
    var isSubstitution : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables
    }
    
    /// A variable substitution maps variables to variables.
    var isVariableSubstitution : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables
    }
    
    /// A (variable) renaming maps distinct variables to distinguishable variables.
    var isRenaming : Bool {
        assert(self.isHomogenous)
        return allKeysAreVariables && allValuesAreVariables && isInjective
    }
}

/// 'lhs =?= rhs' constructs most common unifier mgu(lhs,rhs)
/// iff terms lhs and rhs are unifiable.
/// Otherwise it returns *nil*.
/// The functions assumes variable distinct terms.
func =?=<T:Node>(lhs:T, rhs:T) -> [T:T]? {
    
    //    if lhs == rhs {
    //        return [T:T]() // trivially unifiable
    //    }
    //   assert(lhs != rhs, "terms are variable distinct, hence they cannot be equal")
    
    switch(lhs.isVariable,rhs.isVariable) {
    case (true, true):
        assert(lhs != rhs, "Terms are variable distinct, hence variables cannot be equal")
        return [lhs:rhs]
    case (true,_):
        guard !rhs.allVariables.contains(lhs) else { return nil }
        assert(!rhs.allVariables.contains(lhs),"\(lhs) \(rhs)") // occur check
        return [lhs:rhs]
    case (_,true):
        guard !lhs.allVariables.contains(rhs) else { return nil }
        assert(!lhs.allVariables.contains(rhs),"\(lhs) \(rhs)") // occur check
        return [rhs:lhs]
    case (_, _) where lhs.symbol == rhs.symbol:
        
        // f(s1,s2,s3) =?= f(t1,t2,t3)
        
        var mgu = [T:T]()
        
        guard var lnodes = lhs.nodes, var rnodes = rhs.nodes
            where lnodes.count == rnodes.count
            else { return nil }
        
        while lnodes.count > 0 {
            guard let unifier = lnodes[0] =?= rnodes[0] else { return nil }
            
            lnodes.removeFirst()
            rnodes.removeFirst()
            
            lnodes = lnodes.map { $0 * unifier }
            rnodes = rnodes.map { $0 * unifier }
            
            mgu *= unifier
            
            for (key,value) in unifier {
                if let term = mgu[key] where term != value  { return nil }
                mgu[key] = value
                
            }
            
        }
        
        var decomposition = zip(lhs.nodes!, rhs.nodes!)
        
        for (s,t) in decomposition {
            guard let unifier = s =?= t else { return nil }
            
            mgu *= unifier
            
            
            
        }
        
        
        return mgu
        
    case (_,_) where lhs.symbol == rhs.symbol:
        //        assert(lhs.symbol == "|", "\(lhs.symbol) must not be variadic (\(lhs.nodes!.count),\(rhs.nodes!.count)")
        return nil
    default:
        return nil
    }
}

extension Node {
    /// If `self` is not P then P will be returned,
    /// if `self` is A != B then A = B will be returned.
    /// Otherwise nil will be returned.
    /// To do: find better name for this property
    var unnegatedNode : Self? {
        guard let nodes = self.nodes else { return nil }    // a variable is not negated
        
        /// guard let type = Symbols.defaultSymbols[self]?.type else { return nil } // the type of the node must be known !!! accumulates memory ???
        
        guard let type = self.symbolType else { return nil } // workaround
        
        switch type {
        case SymbolType.Negation:
            assert (nodes.count == 1, "a negation with \(nodes.count) subnodes!")
            return nodes.first
        case SymbolType.Inequation:
            assert (nodes.count == 2, "an inequation with \(nodes.count) subnodes!")
            return Self(equational: Self.symbol(.Equation), nodes: nodes)
        default:
            return nil
        }
    }
    
    var negated : Self? {
        guard let nodes = self.nodes else { return self } // a variable is not negatable
        
        let type = self.symbolType ?? SymbolType.Predicate // assume that unregisterd symbols are predicates
        
        
        switch type {
        case SymbolType.Negation:
            assert (nodes.count == 1, "a negation with \(nodes.count) subnodes!")
            return nodes.first
        case SymbolType.Inequation:
            assert (nodes.count == 2, "an inequation with \(nodes.count) subnodes!")
            return Self(equational: Self.symbol(.Equation), nodes: nodes)
        case SymbolType.Equation:
            assert (nodes.count == 2, "an equation with \(nodes.count) subnodes!")
            return Self(equational: Self.symbol(.Inequation), nodes: nodes)
            
        case .Predicate:
            return Self(connective: Self.symbol(.Negation), nodes:[self])
            
        default:
            return nil
        }
        
        
    }
}

/// 'lhs ~?= rhs' contstructs mgu(~lhs,rhs) or mgu(lhs,~rhs) iff lhs and rhs are clashing,
/// i.e. the negation of one is unifiable with the other.
/// Otherwise it returns *nil*.
func ~?=<T:Node>(lhs:T, rhs:T) -> [T:T]? {
    
    if let l = lhs.unnegatedNode {
        return l =?= rhs
    }
    else if let r = rhs.unnegatedNode {
        return lhs =?= r
    }
    else {
        return nil
    }
}



/// 't * σ' applies substitution σ on term t.
func *<T:Node>(t:T, σ:[T:T]) -> T {
    assert(σ.isSubstitution)
    
    if let tσ = σ[t] { return tσ }      // t is (variable) in σ.keys
    
    guard let nodes = t.nodes else { return t }
    
    return T(symbol:t.symbol, nodes: nodes.map { $0 * σ })
}

/// 't ** s' replaces all variables in t with term s.
func **<T:Node>(t:T, s:T) -> T {
    guard let nodes = t.nodes else { return s }
    
    return T(symbol:t.symbol, nodes: nodes.map { $0 ** s })
}

/// 't ** i' appends `@i` to any variable name.
func **<T:Node where T.Symbol==String>(t:T, idx:Int) -> T {
    guard let nodes = t.nodes else { return T(variable:"\(t.symbol)_\(idx)") }
    return T(symbol:t.symbol, nodes: nodes.map { $0 ** idx })
}

/// 't⊥' replaces all variables in t with constant '⊥'.
postfix func ⊥<T:Node where T.Symbol == String>(t:T) -> T {
    return t ** T(constant:"⊥")
}

/// 'σ * ρ' concatinates substitutions σ and ρ.
func *<T:Node> (lhs:[T:T], rhs:[T:T]) -> [T:T] {
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


func *=<T:Node>(inout lhs:[T:T], rhs:[T:T]) {
    for (key,value) in lhs {
        lhs[key] = value * rhs
    }
}





