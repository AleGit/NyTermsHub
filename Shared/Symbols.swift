//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

typealias Symbol = String
typealias SymbolQuadruple = (type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arities:Range<Int>)

func +<Key,Value>(var lhs:[Key:Value], rhs:[Key:Value]) -> [Key:Value]{
    for (key,value) in rhs {
        assert(lhs[key] == nil, "a key must not be redefined")
        lhs[key] = value
    }
    return lhs
}

// MARK: symbol table

/// Predefined symbols like auxilary, connective and equality symbols.
struct Symbols {
    
    static let EQUALS = "=" // →≈
    static let SEPARATOR = ","
    static let HOLE = "⬜︎"
    static let CombiningEnclosingCircle:Character = " ⃝"
    static let CombiningEnclosingSquare:Character = " ⃞"
    static let xsquare = "x" + String(CombiningEnclosingSquare)
    
    /// a collection of universal auxilary and function symbols
    static let universalSymbols : [Symbol:SymbolQuadruple] = [
        "" : (type:SymbolType.Invalid,category:SymbolCategory.Invalid, notation:SymbolNotation.Invalid, arities: Range(start:0,end:0)),
        "(" : (type:SymbolType.LeftParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: Range(start:0,end:0)),
        ")" : (type:SymbolType.RightParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: Range(start:0,end:0)),
        "⟨" : (type:SymbolType.LeftAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: Range(start:0,end:0)),
        "⟩" : (type:SymbolType.RightAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: Range(start:0,end:0)),
        "{" : (type:SymbolType.LeftCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: Range(start:0,end:0)),
        "}" : (type:SymbolType.RightCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: Range(start:0,end:0)),
        "[" : (type:SymbolType.LeftSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arities: Range(start:0,end:0)),
        "]" : (type:SymbolType.RightSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arities: Range(start:0,end:0)),
        
        // + − × ÷ (mathematical symbols)
        "+" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 1..<Int.max),      //  X, X+Y, X+...+Z
        "−" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arities: 1...2),            // -X, X-Y
        "×" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 1..<Int.max),      // X, X*Y, X*...*X
        "÷" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 2...2),
        
        // - (keyboard symbol)
        "-" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Minus, arities: 1...2),          // -X, X-Y
        
        "=" : (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities: 2...2)
        ]
    
    /// a collection of [TPTP Syntax](http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html) specific symbols
    static let tptpSymbols : [Symbol:SymbolQuadruple] = [
        
        // ⟨assoc_connective⟩ ::= ⟨vline⟩ | &
        "&" : (type:SymbolType.Conjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:Range(start:0, end:Int.max)),  // true; A; A & B; A & ... & Z
        "|" : (type:SymbolType.Disjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:0..<Int.max),  // false; A; A | B; A | ... & Z
        // ⟨unary_connective⟩ ::= ~
        "~" : (type:SymbolType.Negation, category:SymbolCategory.Connective, notation:SymbolNotation.Prefix, arities:1...1),          // ~A
        // ⟨binary_connective⟩  ::= <=> | => | <= | <~> | ~<vline> | ~&
        "=>" : (type:SymbolType.Implication, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),       // A => B
        "<=" : (type:SymbolType.Converse, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),          // A <= B
        "<=>" : (type:SymbolType.IFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),              // A <=> B
        "~&" : (type:SymbolType.NAND, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),              // A ~& B
        "~|" : (type:SymbolType.NOR, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),               // A ~| B
        "<~>" : (type:SymbolType.NIFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),             // A <~> B
        // ⟨fol_quantifier⟩ ::= ! | ?
        "!" : (type:SymbolType.Existential, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2),     // ! [X] : A
        "?" : (type:SymbolType.Universal, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2),       // ? [X] : A
        // ⟨gentzen_arrow⟩      ::= -->
        "-->" : (type:SymbolType.Sequent, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),          // A --> B
        // ⟨defined_infix_formula⟩  ::= ⟨term⟩ ⟨defined_infix_pred⟩ ⟨term⟩
        // ⟨defined_infix_pred⟩ ::= ⟨infix_equality⟩
        // ⟨infix_equality⟩     ::= =
//         "=" : (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2),        // s = t
        // ⟨fol_infix_unary⟩    ::= ⟨term⟩ ⟨infix_inequality⟩ ⟨term⟩
        // ⟨infix_inequality⟩   ::= !=
        "!=" : (type:SymbolType.Inequation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2),        // s != t
        
        "," : (type:SymbolType.Tuple, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:Range<Int>(start:1, end:Int.max)) // s; s,t; ...
    ]
    
    static let defaultSymbols = universalSymbols + tptpSymbols
    

}

// MARK: symbol enums

enum SymbolType {
    case LeftParenthesis, RightParenthesis
    case LeftCurlyBracket, RightCurlyBracket
    case LeftSquareBracket, RightSquareBracket
    case LeftAngleBracket, RightAngleBracket
    
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
    
    case Invalid
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
