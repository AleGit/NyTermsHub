//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Abstract data type `Node`.
/// A tree of nodes can represent a term, e.g
///
/// * (leaf) variable terms: X, Y, Zustand
/// * (leaf) constant terms: a, b, config
/// * (tree) functional terms: f(X,a)
/// * (tree) predicate terms: p(f(X,a)
/// * (tree) equational terms: a = X, b ~= f(X,a)
/// * (root) clause terms: a=X | b ~= f(X,a)
/// * (root) formuala terms: ...
protocol Node : Hashable, CustomStringConvertible, StringLiteralConvertible {
    associatedtype Symbol : Hashable
    
    var symbol : Symbol { get }
    var nodes : [Self]? { get }
    
    init (symbol:Symbol, nodes:[Self]?)
    
    var symbolString : () -> String { get }
    var symbolQuadruple : () -> SymbolQuadruple? { get }
    
    static func symbol(type:SymbolType) -> Symbol
}

extension Node {
    
//    var symbolString: String {
//        assert(false, "this is the most generic implementation of \(#function).")
//        return "\(self.symbol)"
//    }
//    
//    var symbolQuadruple() : SymbolQuadruple? {
//        assert(false, "this is the most generic implementation of \(#function).")
//        return nil
//    }
    
    var symbolDebugString : String {
        guard let quartuple = self.symbolQuadruple() else {
            return "'\(self.symbolString)' (\(self.symbol)) n/a"
        }
        
        return "'\(self.symbolString)' (\(self.symbol)) {\(quartuple)}"
    }
    
    var symbolType : SymbolType? {
        return self.symbolQuadruple()?.type
    }
    
    var symbolCategory : SymbolCategory? {
        return self.symbolQuadruple()?.category
    }
    
    var symbolArities : SymbolArity? {
        return self.symbolQuadruple()?.arity
    }
    
    var symbolNotation : SymbolNotation? {
        return self.symbolQuadruple()?.notation
    }
}

// MARK: convenience initializers

extension Node {
    init(variable symbol:Symbol) {
        self.init(symbol:symbol,nodes: nil)
    }
    
    init(constant symbol:Symbol) {
        self.init(symbol:symbol,nodes: [Self]())
    }
    
    init(function symbol:Symbol, nodes:[Self]) {
        assert(nodes.count>0)
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(predicate symbol:Symbol, nodes:[Self]) {
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(equational symbol:Symbol, nodes:[Self]) {
        assert(nodes.count==2,"an equational term must have exactly two subnodes.")
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(connective symbol:Symbol, nodes:[Self]) {
        // assert(nodes.count>0,"a connective \(symbol) \(nodes)term must have at least one subnode")
        self.init(symbol:symbol,nodes: nodes)
    }
}

// MARK: Hashable : Equatable

extension Node {
    func isEqual(rhs:Self) -> Bool {
        if self.symbol != rhs.symbol  { return false }               // the symbols are equal
        
        if self.nodes == nil && rhs.nodes == nil { return true }     // both are nil. (both are variables)
        if self.nodes == nil || rhs.nodes == nil { return false }    // one is nil, not both. (one is variable, the other is not)
        return self.nodes! == rhs.nodes!                             // none is nil (both are functions)
    }
    
    func isVariant(rhs:Self) -> Bool {
        guard let mgu = (self =?= rhs) else { return false }
        
        return mgu.isRenaming
    }
    
    func isUnifiable(rhs:Self) -> Bool {
        return (self =?= rhs) != nil
    }
}

func ==<T:Node> (lhs:T, rhs:T) -> Bool {
    return lhs.isEqual(rhs)
}

extension Node {
    var defaultHashValue : Int {
        let val = self.symbol.hashValue //  &+ self.type.hashValue
        guard let nodes = self.nodes else { return val }
        
        return nodes.reduce(val) { $0 &+ $1.hashValue }
    }
    
    var hashValue : Int {
        return self.defaultHashValue
    }
}

// MARK: StringLiteralConvertible : ExtendedGraphemeClusterLiteralConvertible : UnicodeScalarLiteralConvertible

extension Node {
    
    init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    /*
    // implemenations of the protocol must provide this initializer
    init(stringLiteral value: StringLiteralType) {
    self.init(constant:"failed")
    }
    */
}

// MARK: Conversion between `Node<S:Symbol>` implemenations with matching symbol types.

extension Node {
    init<N:Node where N.Symbol == Symbol>(_ s:N) {    // similar to Int(3.5)
        
        // no conversion between same types
        if let t = s as? Self {
            self = t
        }
        else if let nodes = s.nodes {
            self = Self(symbol: s.symbol, nodes: nodes.map { Self($0) } )
        }
        else {
            self = Self(variable:s.symbol)
        }
    }
}

extension Node {
    
    var subterms : [Self] {
        guard let terms = self.nodes else { return [self] }
        return terms.reduce([self]) { $0 + $1.subterms }
    }
    
    func is_subterm (t: Self) -> Bool {
        return t.subterms.contains(self)
    }
}





