//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Abstract data type `Term`
public protocol Term : Hashable, CustomStringConvertible, StringLiteralConvertible {
    var symbol : Symbol { get }
    var terms : [Self]? { get }
    
    init (symbol:Symbol, terms:[Self]?)
}

// MARK: convenience initializer

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

// MARK: Hashable

public extension Term {
    public func isEqual(rhs:Self) -> Bool {
        if self.symbol != rhs.symbol  { return false }
        
        if self.terms == nil && rhs.terms == nil { return true }     // both are nil (both are variables)
        if self.terms == nil || rhs.terms == nil { return false }    // one is nil, not both. (one is variable, the other is not)
        return self.terms! == rhs.terms!                             // none is nil (both are functions)
    }
    
    public func isVariant(rhs:Self) -> Bool {
        guard let mgu = (self =?= rhs) else { return false }
        
        return mgu.isRenaming
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

// MARK: CustomStringConvertible (pretty printing)

extension Array where Element : Term {
    /// Concatinate descriptions of elements separated by separator.
    func description(separator:String) -> String {
        let descriptions = self.map { t in t.description }
        return descriptions.joinWithSeparator(separator)
    }
}

extension Term {
    /// Representation of self:Term in TPTP Syntax.
    public var defaultDescription : String {
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let terms = self.terms else { return self.symbol }       // variable
        
        guard let quadruple = self.symbol.quadruple else {
            // assume prefix notation 
            switch terms.count {
            case 0:
                return "\(self.symbol)" // constant (or proposition)
            default:
                return "\(self.symbol)(\(terms.description(SymbolTable.SEPARATOR)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arity.contains(terms.count))
        
        switch quadruple {
            
        case (.Universal,_,.Specific,_), (.Existential,_,.Specific,_):
            return "(\(self.symbol)[\(terms.first!)]:(\(terms.last!)))"
            
        case (_,_,.Specific,_):
            assert(false)
            return "\(self.symbol)☇(\(terms.description(SymbolTable.SEPARATOR)))"
            
        case (_,_,.Prefix,_) where terms.count == 0:
            return "\(self.symbol)"
            
        case (_,_,.Prefix,_):
            return "\(self.symbol)(\(terms.description(SymbolTable.SEPARATOR)))"
            
        case (_,_,.Infix,_):
            return terms.description(self.symbol)
            
        case (_,_,.Postfix,_):
            return "(\(terms.description(SymbolTable.SEPARATOR)))\(self.symbol)"
            
        case (_,_,.Invalid,_):
            assert(false)
            return "☇\(self.symbol)☇(\(terms.description(SymbolTable.SEPARATOR)))"

        }
    }
    
    public var description : String {
        return defaultDescription
    }
}

// MARK: conversion to different type

private func convert <S:Term,T:Term>(s:S) -> T {
    guard let terms = s.terms else { return T(variable:s.symbol) }
    
    return T(symbol: s.symbol, terms: terms.map { convert($0) } )
}

extension Term {
    public init<T:Term>(_ s:T) {    // similar to Int(3.5)
        self = convert(s)
    }
}

// MARK: StringLiteralConvertible (initialize term with string literal)

public extension Term {
    //public typealias UnicodeScalarLiteralType = StringLiteralType
    /// UnicodeScalarLiteralConvertible
    public init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    //public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    /// ExtendedGraphemeClusterLiteralConvertible
    public init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
}



