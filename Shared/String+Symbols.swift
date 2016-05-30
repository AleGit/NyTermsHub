//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

typealias StringSymbol = String

// MARK: symbol enums




typealias SymbolQuadruple = (type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity)

enum SymbolType {
    
    // @available(*,deprecated=1.0)
    case
    LeftParenthesis, RightParenthesis,
    LeftCurlyBracket, RightCurlyBracket,
    LeftSquareBracket, RightSquareBracket,
    LeftAngleBracket, RightAngleBracket
    
    /* CNF */
    
    /// ⟨disjunction⟩ ::= ⟨literal⟩ | ⟨disjunction⟩ ⟨vline⟩ ⟨literal⟩
    // Clause,          // ( ... | ... | ... )
    
    /* FOF */
    
    /// ⟨unary_connective⟩ ::= ~
    case Negation   // ~    NOT
    
    /// ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
    case Disjunction    // |    OR                          // ⟨fof_or_formula⟩
    case Conjunction    // &    AND                         // ⟨fof_and_formula⟩
    
    /// ⟨binary_connective⟩ ::= <=> | => | ⟨= | <~> | ~<vline> | ~&
    case Implication    // =>   IMPLY
    case Converse       // <=   YLPMI
    
    case IFF    // <=>  IFF
    case NIFF   // <~>  XOR NIFF
    case NOR    // ~|   NOR
    case NAND   // ~&   NAND
    
    /// ⟨gentzen_arrow⟩ ::= -->
    case Sequent         // -->  GANTZEN
    
    /// n-ary list
    case Tuple           // [ ... , ... ]
    
    /// ⟨fol_quantifier⟩ ::= ! | ?
    case Universal       // !    FORALL
    case Existential     // ?    EXISTS
    
    // general terms
    // 0-ary
    // Proposition,    // (0-ary)
    // n-ary prefix
    // Predicate,      // (n-ary prefix)
    
    /// ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩ ::= =
    case Equation               // =    EQUAL
    /// ⟨infix_inequality⟩  ::= !=
    case Inequation             // !=   NEQ
    
    /// Propositional and predicate symbols
    /// - ⟨plain_atomic_formula⟩ ::= ⟨plain_term⟩
    /// - ⟨plain_atomic_formula⟩ :== ⟨proposition⟩ | ⟨predicate⟩(⟨arguments⟩)
    /// - ⟨proposition⟩ :== ⟨predicate⟩
    /// - ⟨predicate⟩ :== ⟨atomic_word⟩
    case Predicate
    
    /// constant and function symbols
    /// - ⟨plain_term⟩ ::= ⟨constant⟩ | ⟨functor⟩(⟨arguments⟩)
    /// - ⟨constant⟩ ::= ⟨functor⟩
    /// - ⟨functor⟩ ::= ⟨atomic_word⟩
    case Function               // constant and function symbols
    
    /// Variable symbols
    /// - ⟨variable⟩ ::= ⟨upper_word⟩
    case Variable
    
    /// * for term paths
    case Wildcard
    
    case Invalid
}

extension SymbolType {
    var isPredicational : Bool {
        switch self {
        case .Predicate,.Equation,.Inequation:
            return true
        default:
            return false
        }
    }
}

enum SymbolCategory {
    case Auxiliary
    
    case Variable       //
    case Functor        // constants, functions, proposition, predicates
    case Equational     // equations, inequations, rewrite rules
    case Connective
    
    case Invalid
}

enum SymbolNotation {
    case TptpSpecific   // ! […]:(…)
    
    case Prefix     // f(…,…)
    case Minus   // -1, 1-2
    case Infix      // … + …
    
    case Postfix
    
    case Invalid
}

enum SymbolArity : Equatable {
    case None   // variable, auxiliary symbols
    case Fixed(Int) // constant, function, predicate, equaitinal, connective symbols
    case Variadic(Range<Int>)   // associative connectives
    
    func contains(value:Int) -> Bool {
        switch self {
        case .None:
            return false
        case .Fixed(let arity):
            return arity == value
        case .Variadic(let range):
            return range.contains(value)
        }
    }
    func contains(value:SymbolArity) -> Bool {
        switch (self,value) {
        case (.None,.None):
            return true
        case (_, .Fixed(let arity)):
            return self.contains(arity)
        case (.Variadic(let outer), .Variadic(let inner)):
            return outer.startIndex <= inner.startIndex && inner.endIndex <= outer.endIndex
        default:
            return false
        }
    }
}

func ==(lhs:SymbolArity, rhs:SymbolArity) -> Bool {
    switch (lhs,rhs) {
    case (.None,.None):
        return true
    case (.Fixed(let l),.Fixed(let r)):
        return l == r
    case (.Variadic(let lr), .Variadic(let rr)):
        return lr == rr
    default:
        return false
    }
}
