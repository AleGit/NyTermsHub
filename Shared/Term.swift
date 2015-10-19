//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Abstract data type `Term`, e.g
///
/// * variable terms: X, Y, Zustand
/// * constant (function) terms: a, b, config
/// * functional terms: f(X,a)
/// * predicate terms: p(f(X,a)
/// * equational terms: a = X, b ~= f(X,a)
/// * clause terms: a=X | b ~= f(X,a)
/// * formuala terms: ...
public protocol Term : Hashable, CustomStringConvertible, StringLiteralConvertible {
    var symbol : Symbol { get }
    var terms : [Self]? { get }
    
    init (symbol:Symbol, terms:[Self]?)
}

// MARK: default implementation of convenience initializers

public extension Term {
    public init(variable symbol:Symbol) {
        self.init(symbol:symbol,terms: nil)
    }
    
    public init(constant symbol:Symbol) {
        self.init(symbol:symbol,terms: [Self]())
    }
    
    public init(function symbol:Symbol, terms:[Self]) {
        assert(terms.count>0)
        self.init(symbol:symbol,terms: terms)
    }
    
    public init(predicate symbol:Symbol, terms:[Self]) {
        self.init(symbol:symbol,terms: terms)
    }
    
    public init(equational symbol:Symbol, terms:[Self]) {
        assert(terms.count==2,"an equational term must have exactly two subterms.")
        self.init(symbol:symbol,terms: terms)
    }
    
    public init(connective symbol:Symbol, terms:[Self]) {
        assert(terms.count>0,"a connective term must have at least one subterm")
        self.init(symbol:symbol,terms: terms)
    }
}

// MARK: Hashable (==, hashValue) default implementation

public extension Term {
    public func isEqual(rhs:Self) -> Bool {
        if self.symbol != rhs.symbol  { return false }               // the symbols are equal
        
        if self.terms == nil && rhs.terms == nil { return true }     // both are nil (both are variables)
        if self.terms == nil || rhs.terms == nil { return false }    // one is nil, not both. (one is variable, the other is not)
        return self.terms! == rhs.terms!                             // none is nil (both are functions)
    }
    
    public func isVariant(rhs:Self) -> Bool {
        guard let mgu = (self =?= rhs) else { return false }
        
        return mgu.isRenaming
    }
    
    public func isUnifiable(rhs:Self) -> Bool {
        return (self =?= rhs) != nil
    }
}

public func ==<T:Term> (lhs:T, rhs:T) -> Bool {
    return lhs.isEqual(rhs)
}

public extension Term {
    public var hashValueDefault : Int {
        let val = self.symbol.hashValue //  &+ self.type.hashValue
        guard let terms = self.terms else { return val }
        
        return terms.reduce(val) { $0 &+ $1.hashValue }
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

extension Term {
    /// Representation of self:Term in TPTP Syntax.
    public var defaultDescription : String {
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let terms = self.terms else {
            // since self has not list of subterms at all,
            // self must be a variable term
            assert((Symbols.defined[self.symbol]?.type ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbol) is variable term with wrong type \(Symbols.defined[self.symbol]!)")
            
            return self.symbol
        }
        
        guard let quadruple = Symbols.defined[self.symbol] else {
            assert(Symbols.precachedSymbols[self.symbol] == nil, "\(self.symbol) is a predefined symbol \(Symbols.precachedSymbols[self.symbol)]")
            
            // If the symbol is not defined in the symbol table 
            // we assume prefix notation for (constant) funtions or predicates:
            switch terms.count {
            case 0:
                return "\(self.symbol)" // constant (or proposition)
            default:
                return "\(self.symbol)(\(terms.joinWithSeparator(Symbols.SEPARATOR)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arities.contains(terms.count), "'\(self.symbol)' has invalid number \(terms.count) of subterms  ∉ \(quadruple.arities).")
        
        switch quadruple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(self.symbol)[\(terms.first!)]:(\(terms.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
        
        case (_,_,.TptpSpecific,_):
            assertionFailure("'\(self.symbol)' has ambiguous notation \(quadruple).")
            return "\(self.symbol)☇(\(terms.joinWithSeparator(Symbols.SEPARATOR)))"
       
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(self.symbol)\(terms.first!) (\(terms.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where terms.count == 0:
            return "\(self.symbol)"
            
        case (_,_,.Prefix,_):
            return "\(self.symbol)(\(terms.joinWithSeparator(Symbols.SEPARATOR)))"
            
        case (_,_,.PreInfix,_) where terms.count == 1:
            return "\(self.symbol)(\(terms.first!)"
            
        case (_,_,.PreInfix,_), (_,_,.Infix,_):
            return terms.joinWithSeparator(self.symbol)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(self.symbol)' uses unsupported postfix notation \(quadruple).")
            return "(\(terms.joinWithSeparator(Symbols.SEPARATOR)))\(self.symbol)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(self.symbol)' has invalid notation: \(quadruple)")
            return "☇\(self.symbol)☇(\(terms.joinWithSeparator(Symbols.SEPARATOR)))"
            
        default:
            assertionFailure("'\(self.symbol)' has impossible notation: \(quadruple)")
            return "☇☇\(self.symbol)☇☇(\(terms.joinWithSeparator(Symbols.SEPARATOR)))"
        }
    }
    
    public var description : String {
        return defaultDescription
    }
}

// MARK: Conversion between different implemenations of prototocol term.

private func convert <S:Term,T:Term>(s:S) -> T {
    guard let terms = s.terms else { return T(variable:s.symbol) }
    
    return T(symbol: s.symbol, terms: terms.map { convert($0) } )
}

extension Term {
    public init<T:Term>(_ s:T) {    // similar to Int(3.5)
        self = convert(s)
    }
}

// MARK: StringLiteralConvertible (initialize term with string literal) partial default implementation

public extension Term {
    
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
    // have to be provided by protocol `Term`'s implementation
}



