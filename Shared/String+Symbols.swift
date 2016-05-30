//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

typealias StringSymbol = String

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

extension String {
    static func tptpSymbols() -> [String:SymbolQuadruple] {
        return [
            
            // 'universal' symbols
            
            "" : (type:SymbolType.Invalid,category:SymbolCategory.Invalid, notation:SymbolNotation.Invalid, arity: .None),
            "(" : (type:SymbolType.LeftParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: .None),
            ")" : (type:SymbolType.RightParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: .None),
            "⟨" : (type:SymbolType.LeftAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: .None),
            "⟩" : (type:SymbolType.RightAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: .None),
            "{" : (type:SymbolType.LeftCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: .None),
            "}" : (type:SymbolType.RightCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: .None),
            "[" : (type:SymbolType.LeftSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: .None),
            "]" : (type:SymbolType.RightSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: .None),
            
            // + − × ÷ (mathematical symbols)
            "+" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arity: .Variadic(0..<Int.max)),      //  X, X+Y, X+...+Z
            "−" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arity: .Variadic(1...2)),            // -X, X-Y
            "×" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arity: .Variadic(0..<Int.max)),      // X, X*Y, X*...*X
            "÷" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arity: .Fixed(2)),
            
            // - (keyboard symbol)
            "-" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arity: .Variadic(1...2)),          // -X, X-Y
            
            "=" : (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity: .Fixed(2)),
            
            // tptp symbols
            
            // ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
            "&" : (type:SymbolType.Conjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Variadic(0..<Int.max)),  // true; A; A & B; A & ... & Z
            "|" : (type:SymbolType.Disjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Variadic(0..<Int.max)),  // false; A; A | B; A | ... & Z
            // ⟨unary_connective⟩ ::= ~
            "~" : (type:SymbolType.Negation, category:SymbolCategory.Connective, notation:SymbolNotation.Prefix, arity:.Fixed(1)),          // ~A
            // ⟨binary_connective⟩  ::= <=> | => | <= | <~> | ~<vline> | ~&
            "=>" : (type:SymbolType.Implication, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),       // A => B
            "<=" : (type:SymbolType.Converse, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),          // A <= B
            "<=>" : (type:SymbolType.IFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),              // A <=> B
            "~&" : (type:SymbolType.NAND, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),              // A ~& B
            "~|" : (type:SymbolType.NOR, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),               // A ~| B
            "<~>" : (type:SymbolType.NIFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),             // A <~> B
            // ⟨fol_quantifier⟩ ::= ! | ?
            "!" : (type:SymbolType.Existential, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arity:.Fixed(2)),     // ! [X] : A
            "?" : (type:SymbolType.Universal, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arity:.Fixed(2)),       // ? [X] : A
            // ⟨gentzen_arrow⟩      ::= -->
            "-->" : (type:SymbolType.Sequent, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Fixed(2)),          // A --> B
            // ⟨defined_infix_formula⟩  ::= ⟨term⟩ ⟨defined_infix_pred⟩ ⟨term⟩
            // ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩
            // ⟨infix_equality⟩     ::= =
            //         "=" : (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity:.Fixed(2)),        // s = t
            // ⟨fol_infix_unary⟩    ::= ⟨term⟩ ⟨infix_inequality⟩ ⟨term⟩
            // ⟨infix_inequality⟩   ::= !=
            "!=" : (type:SymbolType.Inequation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity:.Fixed(2)),        // s != t
            
            "," : (type:SymbolType.Tuple, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:.Variadic(1..<Int.max)) // s; s,t; ...
        ]
    }
}

var globalStringSymbols = String.tptpSymbols()

func resetGlobalStringSymbols() {
    globalStringSymbols = String.tptpSymbols()
}



