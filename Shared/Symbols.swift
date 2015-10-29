//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

public typealias Symbol = String
public typealias SymbolQuadruple = (type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arities:Range<Int>)

func +<Key,Value>(var lhs:[Key:Value], rhs:[Key:Value]) -> [Key:Value]{
    for (key,value) in rhs {
        assert(lhs[key] == nil, "a key must not be redefined")
        lhs[key] = value
    }
    return lhs
}

// MARK: symbol table

struct Symbols {
    
    static let EQUALS = "=" // →≈
    static let SEPARATOR = ","
    
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
        
        "×" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: Range(start:1, end:Int.max)),
        "+" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: Range(start:1, end:Int.max)),    //  X, X+Y, X+...+Z
        "-" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.PreInfix, arities: 1...2),          // -X, X-Y
        "=" : (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities: 2...2)
        ]
    
    static let tptpSymbols : [Symbol:SymbolQuadruple] = [
        
        // <assoc_connective> ::= <vline> | &
        "&" : (type:SymbolType.Conjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:Range(start:0, end:Int.max)),  // true; A; A & B; A & ... & Z
        "|" : (type:SymbolType.Disjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:0..<Int.max),  // false; A; A | B; A | ... & Z
        // <unary_connective> ::= ~
        "~" : (type:SymbolType.Negation, category:SymbolCategory.Connective, notation:SymbolNotation.Prefix, arities:1...1),          // ~A
        // <binary_connective>  ::= <=> | => | <= | <~> | ~<vline> | ~&
        "=>" : (type:SymbolType.Implication, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),       // A => B
        "<=" : (type:SymbolType.Converse, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),          // A <= B
        "<=>" : (type:SymbolType.IFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),              // A <=> B
        "~&" : (type:SymbolType.NAND, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),              // A ~& B
        "~|" : (type:SymbolType.NOR, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),               // A ~| B
        "<~>" : (type:SymbolType.NIFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),             // A <~> B
        // <fol_quantifier> ::= ! | ?
        "!" : (type:SymbolType.Existential, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2),     // ! [X] : A
        "?" : (type:SymbolType.Universal, category:SymbolCategory.Connective, notation:SymbolNotation.TptpSpecific, arities:2...2),       // ? [X] : A
        // <gentzen_arrow>      ::= -->
        "-->" : (type:SymbolType.Sequent, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:2...2),          // A --> B
        // <defined_infix_formula>  ::= <term> <defined_infix_pred> <term>
        // <defined_infix_pred> ::= <infix_equality>
        // <infix_equality>     ::= =
//         "=" : (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2),        // s = t
        // <fol_infix_unary>    ::= <term> <infix_inequality> <term>
        // <infix_inequality>   ::= !=
        "!=" : (type:SymbolType.Inequation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arities:2...2),        // s != t
        
        "," : (type:SymbolType.Tuple, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arities:Range<Int>(start:1, end:Int.max)) // s; s,t; ...
    ]
    
    // static var defined : [Symbol:SymbolQuadruple] { return universalSymbols + tptpSymbols }
    
    static let defaultSymbols = universalSymbols + tptpSymbols
    

}

// MARK: symbol enums

public enum SymbolType {
    case LeftParenthesis, RightParenthesis
    case LeftCurlyBracket, RightCurlyBracket
    case LeftSquareBracket, RightSquareBracket
    case LeftAngleBracket, RightAngleBracket
    
    /* CNF */
    
    /// <disjunction> ::= <literal> | <disjunction> <vline> <literal>
    // Clause,          // ( ... | ... | ... )
    
    /* FOF */
    
    /// <unary_connective>   ::= ~
    case Negation   // ~    NOT
    
    /// <assoc_connective>   ::= <vline> | &
    case Disjunction    // |    OR                          // <fof_or_formula>
    case Conjunction    // &    AND                         // <fof_and_formula>
    
    /// <binary_connective> ::= <=> | => | <= | <~> | ~<vline> | ~&
    case Implication    // =>   IMPLY
    case Converse       // <=   YLPMI
    
    case IFF    // <=>  IFF
    case NIFF   // <~>  XOR NIFF
    case NOR    // ~|   NOR
    case NAND   // ~&   NAND
    
    ///  The seqent arrow <gentzen_arrow> ::= -->
    case Sequent         // -->  GANTZEN
    
    /// n-ary list
    case Tuple           // [ ... , ... ]
    
    /// <fol_quantifier> ::= ! | ?
    case Universal       // !    FORALL
    case Existential     // ?    EXISTS
    
    // general terms
    /// 0-ary
    // Proposition,    // (0-ary)
    /// n-ary prefix
    /// Predicate,      // (n-ary prefix)
    /// <defined_infix_pred> ::= <infix_equality> ::= =
    case Equation               // =    EQUAL
    /// <infix_inequality>  ::= !=
    case Inequation             // !=   NEQ
    
    /// <plain_atomic_formula> ::= <plain_term>
    /// <plain_term> ::= <constant> | <functor>(<arguments>)
    ///
    /// <plain_atomic_formula> :== <proposition> | <predicate>(<arguments>)
    /// <proposition> :== <predicate>
    /// <predicate> :== <atomic_word>
    /// <predicate> :== <atomic_word>
    case Predicate              // proposition and predicate symbols
    
    /// <constant> ::= <functor>
    /// <functor> ::= <atomic_word>
    case Function               // constant and function symbols
    /// <variable> ::= <upper_word>
    case Variable
    
    case Invalid
}

public enum SymbolCategory {
    case Auxiliary
    
    case Variable       //
    case Functor        // constants, functions, proposition, predicates
    case Equational     // equations, inequations, rewrite rules
    case Connective
    
    case Invalid
}

public enum SymbolNotation {
    case TptpSpecific   // ! […]:(…)
    
    case Prefix     // f(…,…)
    case PreInfix   // prefix with single argument, infix notation with multiple arguments, e.g.: -4
    case Infix      // … + …
    
    case Postfix
    
    case Invalid
}

#if USE_STATIC_SYMBOL_TABLE

// MARK: - obsolete
private extension Symbols {
    
    /// no arity at all, arities: 0..<0,
    /// i.e. variable.nodes == nil
    private static func _add(variable symbol: Symbol) {
        guard let quadruple = Symbols.defaultSymbols[symbol] else {
            cachedSymbols[symbol] = (type:SymbolType.Variable, category:SymbolCategory.Variable, notation:SymbolNotation.Prefix, arities:Range(start:0, end:0))
            return
        }
        
        // we know: the symbol was allreday in the symbol table
        // we check: is our variable symbol consistent with the symbol in the table
        
        assert(quadruple.type == SymbolType.Variable)
        assert(quadruple.category == SymbolCategory.Variable)
        assert(quadruple.notation == SymbolNotation.Prefix)
        assert(quadruple.arities.isEmpty)
    }
    
    /// aritiy is zero, arities: 0...0 == 0..<1,
    /// i.e. constant.nodes.count == 0
    private static func _add(constant symbol: Symbol) {
        // a constant is just a constant function, hence it has arity zero
        Symbols._add(function: symbol, arity: 0)
    }
    
    /// arity is greater than zero, arities: value...value == value..<value+1,
    /// i.e. function.nodes.count == value > 0
    private static func _add(function symbol: Symbol, arity value:Int) {
        guard var quadruple = Symbols.defaultSymbols[symbol] else {
            cachedSymbols[symbol] = ( type:SymbolType.Function, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arities:Range(start:value,end:value+1))
            return
        }
        
        // we know: the symbol was allread in the symbol table
        // we check: is our function symbol consitent with the symbol in the table
        // remark: a function symbol, more specifically a symbol of category functor can be a predicate symbol
        
        assert(quadruple.type == SymbolType.Function || quadruple.type == SymbolType.Predicate)
        assert(quadruple.category == SymbolCategory.Functor)
        
        // we check: variadic function/predicate symbols are not supported yet.
        assert(quadruple.arities.startIndex==value)
        assert(quadruple.arities.endIndex==value+1)
        
        quadruple.arities.insert(value)
        cachedSymbols[symbol] = quadruple
    }
    
    /// /// aritiy is zero, arities: 0...0 == 0..<1,
    /// i.e. proposition.nodes.count == 0
    private static func _add(proposition symbol:Symbol) {
        Symbols._add(predicate:symbol,arity:0)
    }
    
    /// arities is greater than zero: value...value == value..<value+1,
    /// i.e. predicate == value > 0
    private static func _add(predicate symbol: Symbol, arity value:Int) {
        guard var quadruple = Symbols.defaultSymbols[symbol] else {
            cachedSymbols[symbol] = (type:SymbolType.Predicate, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arities:Range(start:value,end:value+1))
            return
        }
        // we know: the symbol was allread in the symbol table
        // we check: is our function symbol consitent with the symbol in the table
        // remark: a predicate symbol, more specifically a functor could be added as function symbol before
        assert(quadruple.type == SymbolType.Function || quadruple.type == SymbolType.Predicate)
        assert(quadruple.category == SymbolCategory.Functor)
        assert(quadruple.notation == SymbolNotation.Prefix)
        
        // we check: variadic predicate symbols are not supported yet.
        assert(quadruple.arities.startIndex==value)
        assert(quadruple.arities.endIndex==value+1)
        
        quadruple.arities.insert(value)
        cachedSymbols[symbol] = quadruple
    }
    
}

#endif
