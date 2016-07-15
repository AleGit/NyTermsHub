//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

typealias StringSymbol = String

typealias SymbolQuadruple = (type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity)

enum SymbolType {
    
    // @available(*,deprecated=1.0)
    case
    leftParenthesis, rightParenthesis,
    leftCurlyBracket, rightCurlyBracket,
    leftSquareBracket, rightSquareBracket,
    leftAngleBracket, rightAngleBracket
    
    /* CNF */
    
    /// ⟨disjunction⟩ ::= ⟨literal⟩ | ⟨disjunction⟩ ⟨vline⟩ ⟨literal⟩
    // Clause,          // ( ... | ... | ... )
    
    /* FOF */
    
    /// ⟨unary_connective⟩ ::= ~
    case negation   // ~    NOT
    
    /// ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
    case disjunction    // |    OR                          // ⟨fof_or_formula⟩
    case conjunction    // &    AND                         // ⟨fof_and_formula⟩
    
    /// ⟨binary_connective⟩ ::= <=> | => | ⟨= | <~> | ~<vline> | ~&
    case implication    // =>   IMPLY
    case converse       // <=   YLPMI
    
    case iff    // <=>  IFF
    case niff   // <~>  XOR NIFF
    case nor    // ~|   NOR
    case nand   // ~&   NAND
    
    /// ⟨gentzen_arrow⟩ ::= -->
    case sequent         // -->  GANTZEN
    
    /// n-ary list
    case tuple           // [ ... , ... ]
    
    /// ⟨fol_quantifier⟩ ::= ! | ?
    case universal       // !    FORALL
    case existential     // ?    EXISTS
    
    // general terms
    // 0-ary
    // Proposition,    // (0-ary)
    // n-ary prefix
    // Predicate,      // (n-ary prefix)
    
    /// ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩ ::= =
    case equation               // =    EQUAL
    /// ⟨infix_inequality⟩  ::= !=
    case inequation             // !=   NEQ
    
    /// Propositional and predicate symbols
    /// - ⟨plain_atomic_formula⟩ ::= ⟨plain_term⟩
    /// - ⟨plain_atomic_formula⟩ :== ⟨proposition⟩ | ⟨predicate⟩(⟨arguments⟩)
    /// - ⟨proposition⟩ :== ⟨predicate⟩
    /// - ⟨predicate⟩ :== ⟨atomic_word⟩
    case predicate
    
    /// constant and function symbols
    /// - ⟨plain_term⟩ ::= ⟨constant⟩ | ⟨functor⟩(⟨arguments⟩)
    /// - ⟨constant⟩ ::= ⟨functor⟩
    /// - ⟨functor⟩ ::= ⟨atomic_word⟩
    case function               // constant and function symbols
    
    /// Variable symbols
    /// - ⟨variable⟩ ::= ⟨upper_word⟩
    case variable
    
    /// * for term paths
    case wildcard
    
    case invalid
}

extension SymbolType {
    var isPredicational : Bool {
        switch self {
        case .predicate,.equation,.inequation:
            return true
        default:
            return false
        }
    }
}

enum SymbolCategory {
    case auxiliary
    
    case variable       //
    case functor        // constants, functions, proposition, predicates
    case equational     // equations, inequations, rewrite rules
    case connective
    
    case invalid
}

enum SymbolNotation {
    case tptpSpecific   // ! […]:(…)
    
    case prefix     // f(…,…)
    case minus   // -1, 1-2
    case infix      // … + …
    
    case postfix
    
    case invalid
}

enum SymbolArity : Equatable {
    case none   // variable, auxiliary symbols
    case fixed(Int) // constant, function, predicate, equaitinal, connective symbols
    case variadic(CountableRange<Int>)   // associative connectives
    
    func contains(_ value:Int) -> Bool {
        switch self {
        case .none:
            return false
        case .fixed(let arity):
            return arity == value
        case .variadic(let range):
            return range.contains(value)
        }
    }
    func contains(_ value:SymbolArity) -> Bool {
        switch (self,value) {
        case (.none,.none):
            return true
        case (_, .fixed(let arity)):
            return self.contains(arity)
        case (.variadic(let outer), .variadic(let inner)):
            return outer.startIndex <= inner.startIndex && inner.endIndex <= outer.endIndex
        default:
            return false
        }
    }
    
    var max : Int {
        switch self {
        case .none:
            return 0
        case .fixed(let arity):
            return arity
        case .variadic(let range):
            return range.endIndex
        }
    }
}

func ==(lhs:SymbolArity, rhs:SymbolArity) -> Bool {
    switch (lhs,rhs) {
    case (.none,.none):
        return true
    case (.fixed(let l),.fixed(let r)):
        return l == r
    case (.variadic(let lr), .variadic(let rr)):
        return lr == rr
    default:
        return false
    }
}

var globalStringSymbols = [String:SymbolQuadruple]()

func resetGlobalStringSymbols() {
    globalStringSymbols.removeAll()
}



