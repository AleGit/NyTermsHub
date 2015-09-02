//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

// Three small sample implementations of protocol `Term` demonstrate protocol-based programming.
// Basically just the data representation has to be defined, but nearly no functions.
// All three are used to test basic features of terms provided by the protocol itself.

import Foundation
import NyTerms

// MARK: term dummy class

/// Class `TermSampleClass` is a sample implementation of protocol `Term` for testing purposes only.
final class TermSampleClass : Term {
    let symbol : String
    let terms : [TermSampleClass]?
    
    required init(symbol:String, terms:[TermSampleClass]?) {
        self.symbol = symbol
        self.terms = terms
    }
}


func ==(lhs:TermSampleClass, rhs:TermSampleClass) -> Bool {
    
    if lhs === rhs { return true }
    
    return lhs.isEqual(rhs)
    
}

extension TermSampleClass : StringLiteralConvertible {
    // TODO: Implementation of `StringLiteralConvertible` should not depend on `TptpTerm`.
    convenience init(stringLiteral value: StringLiteralType) {
        let term = TermSampleClass(TptpTerm(stringLiteral:value))
        self.init(symbol: term.symbol, terms: term.terms)
    }
}

// MARK: term dummy struct

/// Struct `TermSampleStruct` is a sample implementation of protocol `Term` for testing purposes only.
struct TermSampleStruct : Term {
    let symbol : String
    let terms : [TermSampleStruct]?
}


extension TermSampleStruct : StringLiteralConvertible {
    // TODO: Implementation of `StringLiteralConvertible` should not depend on `TptpTerm`.
    init(stringLiteral value: StringLiteralType) {
        self = TermSampleStruct(TptpTerm(stringLiteral:value))
    }
}

// MARK: term dummy enum

/// Enum `TermSampleEnum` is a sample implementation of protocol `Term` for testing purposes only.
enum TermSampleEnum : Term {
    case Variable (symbol:String)
    case Constant (symbol:String)
    case Function (symbol:String, terms:[TermSampleEnum])
    
    var symbol : String {
        switch self {
        case let .Variable(symbol):
            return symbol
        case let .Constant(symbol):
            return symbol
        case let .Function(symbol, _):
            return symbol
        }
    }
    
    var terms : [TermSampleEnum]? {
        switch self {
        case .Variable:
            return nil
        case .Constant:
            return [TermSampleEnum]()
        case let .Function(_,terms:terms):
            return terms
        }
    }
    
    init (symbol:String, terms:[TermSampleEnum]?) {
        guard let ts = terms else {
            self = Variable(symbol: symbol)
            return
        }
        
        if ts.count == 0 {
            self = Constant(symbol: symbol)
        }
        else {
            self = Function(symbol: symbol, terms: ts)
        }
    }
}

extension TermSampleEnum : StringLiteralConvertible {
    // TODO: Implementation of `StringLiteralConvertible` should not depend on `TptpTerm`.
    init(stringLiteral value: StringLiteralType) {
        self = TermSampleEnum(TptpTerm(stringLiteral:value))
    }
}
