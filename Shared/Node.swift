//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Abstract data type `Node`, 
// a tree can represent a term, e.g
///
/// * (leaf) variable terms: X, Y, Zustand
/// * (leaf) constant terms: a, b, config
/// * (tree) functional terms: f(X,a)
/// * (tree) predicate terms: p(f(X,a)
/// * (tree) equational terms: a = X, b ~= f(X,a)
/// * (root) clause terms: a=X | b ~= f(X,a)
/// * (root) formuala terms: ...
public protocol Node : Hashable, CustomStringConvertible, StringLiteralConvertible {
    var symbol : Symbol { get }
    var nodes : [Self]? { get }
    
    init (symbol:Symbol, nodes:[Self]?)
}

// MARK: default implementation of convenience initializers

public extension Node {
    public init(variable symbol:Symbol) {
        self.init(symbol:symbol,nodes: nil)
    }
    
    public init(constant symbol:Symbol) {
        self.init(symbol:symbol,nodes: [Self]())
    }
    
    public init(function symbol:Symbol, nodes:[Self]) {
        assert(nodes.count>0)
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public init(predicate symbol:Symbol, nodes:[Self]) {
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public init(equational symbol:Symbol, nodes:[Self]) {
        assert(nodes.count==2,"an equational term must have exactly two subnodes.")
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public init(connective symbol:Symbol, nodes:[Self]) {
        assert(nodes.count>0,"a connective term must have at least one subnode")
        self.init(symbol:symbol,nodes: nodes)
    }
}

// MARK: Hashable (==, hashValue) default implementation

public extension Node {
    public func isEqual(rhs:Self) -> Bool {
        if self.symbol != rhs.symbol  { return false }               // the symbols are equal
        
        if self.nodes == nil && rhs.nodes == nil { return true }     // both are nil (both are variables)
        if self.nodes == nil || rhs.nodes == nil { return false }    // one is nil, not both. (one is variable, the other is not)
        return self.nodes! == rhs.nodes!                             // none is nil (both are functions)
    }
    
    public func isVariant(rhs:Self) -> Bool {
        guard let mgu = (self =?= rhs) else { return false }
        
        return mgu.isRenaming
    }
    
    public func isUnifiable(rhs:Self) -> Bool {
        return (self =?= rhs) != nil
    }
}

public func ==<T:Node> (lhs:T, rhs:T) -> Bool {
    return lhs.isEqual(rhs)
}

public extension Node {
    public var hashValueDefault : Int {
        let val = self.symbol.hashValue //  &+ self.type.hashValue
        guard let nodes = self.nodes else { return val }
        
        return nodes.reduce(val) { $0 &+ $1.hashValue }
    }
    
    public var hashValue : Int {
        return self.hashValueDefault
    }
}

// MARK: CustomStringConvertible (description, pretty printing) default implementation

extension Array where Element : CustomStringConvertible {
    /// Concatinate descriptions of elements separated by separator.
    func joinWithSeparator(separator:String) -> String {
        return self.map { $0.description }.joinWithSeparator(separator)
    }
}

extension Node {
    /// Representation of self:Node in TPTP Syntax.
    public var defaultDescription : String {
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((Symbols.defined[self.symbol]?.type ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbol) is variable term with wrong type \(Symbols.defined[self.symbol]!)")
            
            return self.symbol
        }
        
        guard let quadruple = Symbols.defined[self.symbol] else {
            assert(Symbols.precachedSymbols[self.symbol] == nil, "\(self.symbol) is a predefined symbol \(Symbols.precachedSymbols[self.symbol)]")
            
            // If the symbol is not defined in the symbol table 
            // we assume prefix notation for (constant) funtions or predicates:
            switch nodes.count {
            case 0:
                return "\(self.symbol)" // constant (or proposition)
            default:
                return "\(self.symbol)(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arities.contains(nodes.count), "'\(self.symbol)' has invalid number \(nodes.count) of subnodes  ∉ \(quadruple.arities).")
        
        switch quadruple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(self.symbol)[\(nodes.first!)]:(\(nodes.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
        
        case (_,_,.TptpSpecific,_):
            assertionFailure("'\(self.symbol)' has ambiguous notation \(quadruple).")
            return "\(self.symbol)☇(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))"
       
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(self.symbol)\(nodes.first!) (\(nodes.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where nodes.count == 0:
            return "\(self.symbol)"
            
        case (_,_,.Prefix,_):
            return "\(self.symbol)(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))"
            
        case (_,_,.PreInfix,_) where nodes.count == 1:
            return "\(self.symbol)(\(nodes.first!)"
            
        case (_,_,.PreInfix,_), (_,_,.Infix,_):
            return nodes.joinWithSeparator(self.symbol)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(self.symbol)' uses unsupported postfix notation \(quadruple).")
            return "(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))\(self.symbol)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(self.symbol)' has invalid notation: \(quadruple)")
            return "☇\(self.symbol)☇(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))"
            
        default:
            assertionFailure("'\(self.symbol)' has impossible notation: \(quadruple)")
            return "☇☇\(self.symbol)☇☇(\(nodes.joinWithSeparator(Symbols.SEPARATOR)))"
        }
    }
    
    public var description : String {
        return defaultDescription
    }
}

// MARK: Conversion between different implemenations of protocol `Node`.

private func convert <S:Node,T:Node>(s:S) -> T {
    guard let nodes = s.nodes else { return T(variable:s.symbol) }
    
    return T(symbol: s.symbol, nodes: nodes.map { convert($0) } )
}

extension Node {
    public init<T:Node>(_ s:T) {    // similar to Int(3.5)
        self = convert(s)
    }
}

// MARK: StringLiteralConvertible (initialize term with string literal) partial default implementation

public extension Node {
    
    // UnicodeScalarLiteralConvertible
    // typealias UnicodeScalarLiteralType = StringLiteralType
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    // ExtendedGraphemeClusterLiteralConvertible:UnicodeScalarLiteralConvertible
    // typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    // StringLiteralConvertible:ExtendedGraphemeClusterLiteralConvertible
    // typealias StringLiteralType
    // public init(stringLiteral value: Self.StringLiteralType)
    // have to be provided by protocol `Node`'s implementation
}



