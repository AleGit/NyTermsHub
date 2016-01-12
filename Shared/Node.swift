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
    var symbol : Symbol { get }
    var nodes : [Self]? { get }
    
    init (symbol:Symbol, nodes:[Self]?)
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
        
        if self.nodes == nil && rhs.nodes == nil { return true }     // both are nil (both are variables)
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

// MARK: CustomStringConvertible

extension Node {
    
    
    /// Representation of self:Node in TPTP Syntax.
    var tptpDescription : String {
        return buildDescription { $0.0 }
    }
    
    func buildDescription(decorate:(symbol:String,type:SymbolType)->String) -> String {
        
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((Symbols.defaultSymbols[self.symbol]?.type ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbol) is variable term with wrong type \(Symbols.defaultSymbols[self.symbol]!)")
            
            return decorate(symbol:self.symbol, type:SymbolType.Variable)
        }
        
        let decors = nodes.map { $0.buildDescription(decorate) }
        
        guard let quadruple = Symbols.defaultSymbols[self.symbol] else {
            // If the symbol is not defined in the global symbol table,
            // i.e. a function or predicate symbol
            let decor = decorate(symbol:self.symbol,type:SymbolType.Function)
            
            // we assume prefix notation for (constant) functions or predicates:
            switch nodes.count {
            case 0:
                return "\(decor)" // constant (or proposition)
            default:
                
                return "\(decor)(\(decors.joinWithSeparator(Symbols.SEPARATOR)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arities.contains(nodes.count), "'\(self.symbol)' has invalid number \(nodes.count) of subnodes  ∉ \(quadruple.arities).")
        
        let decor = decorate(symbol:self.symbol, type:quadruple.type)
        
        switch quadruple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(decor)[\(decors.first!)]:(\(decors.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
            
        case (_,_,.TptpSpecific,_):
            assertionFailure("'\(symbol)' has ambiguous notation \(quadruple).")
            return "\(decor)☇(\(decors.joinWithSeparator(Symbols.SEPARATOR)))"
            
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(decor)\(decors.first!) (\(decors.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where nodes.count == 0:
            return "\(decor)"
            
        case (_,_,.Prefix,_):
            return "\(decor)(\(decors.joinWithSeparator(Symbols.SEPARATOR)))"
            
        case (_,_,.Minus,_) where nodes.count == 1:
            return "\(decor)(\(decors.first!)"
            
        case (_,_,.Minus,_), (_,_,.Infix,_):
            return decors.joinWithSeparator(decor)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(symbol),\(decor)' uses unsupported postfix notation \(quadruple).")
            return "(\(decors.joinWithSeparator(Symbols.SEPARATOR)))\(decor)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(symbol),\(decor)' has invalid notation: \(quadruple)")
            return "☇\(decor)☇(\(decors.joinWithSeparator(Symbols.SEPARATOR)))"
            
        default:
            assertionFailure("'\(symbol)' has impossible notation: \(quadruple)")
            return "☇☇\(decor)☇☇(\(decors.joinWithSeparator(Symbols.SEPARATOR)))"
        }
    }
    
    var description : String {
        return tptpDescription
    }
}

extension Node {
    
    private func latexDecorate(symbol:String, type:SymbolType) -> String {
        switch(type) {
        case SymbolType.Variable:
            return symbol
        case SymbolType.Predicate, SymbolType.Function:
            return "{\\mathsf \(symbol)}"
        default:
            return Symbols.latexSymbolsDecoration[type] ?? symbol
        }
        
    }
    
    var laTeXDescription : String {
        return buildDescription(latexDecorate)
        
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

// MARK: Conversion between `Node` implemenations.

extension Node {
    init<T:Node>(_ s:T) {    // similar to Int(3.5)
        // self = convert(s)
        
        if let nodes = s.nodes {
            self = Self(symbol: s.symbol, nodes: nodes.map { Self($0) } )
        }
        else {
            self = Self(variable:s.symbol)
        }
    }
}



