//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

public typealias Symbol = String
public typealias SymbolQuadruple = (type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:Range<Int>)

// MARK: symbol properties

public extension Symbol {
    
    public var type : SymbolType? {
        return SymbolTable.definedSymbols[self]?.type
    }
    
    public var category : SymbolCategory? {
        return SymbolTable.definedSymbols[self]?.category
    }
    
    public var notation : SymbolNotation? {
        return SymbolTable.definedSymbols[self]?.notation
    }
    
    public var arity : Range<Int>? {
        return SymbolTable.definedSymbols[self]?.arity
    }
    
    public var quadruple : SymbolQuadruple? {
        return SymbolTable.definedSymbols[self]
    }
}

// MARK: symbol table

struct SymbolTable {
    
    static let REWRITES = "⟶" // →≈
    static let SEPARATOR = ","
    
    /// arity is empty == 0..<0
    static func add(variable symbol: Symbol) {
        guard let quadruple = symbol.quadruple else {
            definedSymbols[symbol] = (type:SymbolType.Variable, category:SymbolCategory.Variable, notation:SymbolNotation.Prefix, arity:Range(start:0, end:0))
            return
        }
        
        assert(quadruple.type == SymbolType.Variable)
        assert(quadruple.category == SymbolCategory.Variable)
        assert(quadruple.notation == SymbolNotation.Prefix)
        assert(quadruple.arity.isEmpty)
    }
    
    /// arity == 0 == 0...0 == 0..<1
    static func add(constant symbol: Symbol) {
        SymbolTable.add(function: symbol, arity: 0)
    }
    
    /// arity == value...value == value..<value+1
    static func add(function symbol: Symbol, arity value:Int) {
        guard let quadruple = symbol.quadruple else {
            definedSymbols[symbol] = ( type:SymbolType.Function, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arity:Range(start:value,end:value+1))
            return
        }
        assert(quadruple.type == SymbolType.Function || quadruple.type == SymbolType.Predicate)
        assert(quadruple.category == SymbolCategory.Functor)
        
        assert(quadruple.arity.startIndex==value)
        assert(quadruple.arity.endIndex==value+1)
        quadruple.arity.insert(value)
        definedSymbols[symbol] = (type:quadruple.type, category:quadruple.category, notation:quadruple.notation, arity: quadruple.arity)
    }
    
    static func add(proposition symbol:Symbol) {
        SymbolTable.add(predicate:symbol,arity:0)
    }
    
    /// arity == value...value == value..<value+1
    static func add(predicate symbol: Symbol, arity value:Int) {
        guard let quadruple = symbol.quadruple else {
            #if FUNCTION_TABLE || FULL_TABLE
                assertionFailure("predicates has to be added as functions first")
            #endif
            definedSymbols[symbol] = (type:SymbolType.Predicate, category:SymbolCategory.Functor, notation:SymbolNotation.Prefix, arity:Range(start:value,end:value+1))
            return
        }
        // assert(quadruple.type == SymbolType.Function)
        assert(quadruple.type == SymbolType.Function || quadruple.type == SymbolType.Predicate)
        assert(quadruple.category == SymbolCategory.Functor)
        assert(quadruple.notation == SymbolNotation.Prefix)
        assert(quadruple.arity.startIndex==value)
        assert(quadruple.arity.endIndex==value+1)
        quadruple.arity.insert(value)
        definedSymbols[symbol] = (type:SymbolType.Predicate, category:quadruple.category, notation:quadruple.notation, arity: quadruple.arity)
    }
    
    static let predefinedSymbols : [Symbol:SymbolQuadruple] = [
        "" : (type:SymbolType.Invalid,category:SymbolCategory.Invalid, notation:SymbolNotation.Invalid, arity: Range(start:0,end:0)),
        "(" : (type:SymbolType.LeftParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: 0...0),
        ")" : (type:SymbolType.RightParenthesis,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: 0...0),
        "⟨" : (type:SymbolType.LeftAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: 0...0),
        "⟩" : (type:SymbolType.RightAngleBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: 0...0),
        "{" : (type:SymbolType.LeftCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: 0...0),
        "}" : (type:SymbolType.RightCurlyBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: 0...0),
        "[" : (type:SymbolType.LeftSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Prefix, arity: 0...0),
        "]" : (type:SymbolType.RightSquareBracket,category:SymbolCategory.Auxiliary, notation:SymbolNotation.Postfix, arity: 0...0),
        
        "+" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arity: 1..<Int.max),    //  X, X+Y, X+...+Z
        "-" : (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arity: 1...2),          // -X, X-Y
        "⟶" : (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity: 2...2),
        "=" : (type:SymbolType.Equation,category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity: 2...2),
    ]
    
       
    static private var definedSymbols = SymbolTable.predefinedSymbols
    
    static func setup(dictionary dictionary:[Symbol:SymbolQuadruple]) {
        SymbolTable.definedSymbols = SymbolTable.predefinedSymbols
        
        for (key,value) in dictionary {
            assert(SymbolTable.definedSymbols[key] == nil, "predefined symbol \(key) must not be overwritten.")
            SymbolTable.definedSymbols[key] = value
        }
        
        SymbolTable.symbolsByCategory.removeAll()
        SymbolTable.symbolsByType.removeAll()
    }
    
    static func symbols(category category: SymbolCategory) -> Set<Symbol> {
        guard let symbols = symbolsByCategory[category] else {
            let s = SymbolTable.definedSymbols.filteredSetOfKeys { $0.1.category == category }
            symbolsByCategory[category] = s
            return s
        }
        return symbols
    }
    
    static func symbols(type type: SymbolType) -> Set<Symbol> {
        guard let symbols = symbolsByType[type] else {
            let s = SymbolTable.definedSymbols.filteredSetOfKeys { $0.1.type == type }
            symbolsByType[type] = s
            return s
        }
        return symbols
    }
    
    private static var symbolsByCategory = [SymbolCategory:Set<Symbol>]()
    private static var symbolsByType = [SymbolType:Set<Symbol>]()
    
    /// Build Settings : Swift Compiler - Custom Flags : Other Swift Flags
    ///
    /// - FULL_TABLE
    /// - VARIABLE_TABLE    collect variable symbols
    /// - FUNCTION_TABLE    collect function symbols which includes constants
    /// - PREDICATE_TABLE   collect predicate symbols which includes propositions
    static var info : String {
        // Other Swift Flages
        var tables = [String]()
        
        tables.append("(\(SymbolTable.definedSymbols.count))")
        
        #if FULL_TABLE
            tables.append("full")
        #endif
        
        #if VARIABLE_TABLE || FULL_TABLE
            tables.append("variable")
        #endif
        
        #if CONSTANT_TABLE || FULL_TABLE
            tables.append("constant")
        #endif
        
        #if FUNCTION_TABLE || FULL_TABLE
            tables.append("function")
        #endif
        
        #if PREDICATE_TABLE || FULL_TABLE
            tables.append("predicate")
        #endif
        
        return tables.joinWithSeparator(",")
    }
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
    
    case Variable
    case Functor    // constants, functions, proposition, predicates
    case Equational  // equations, inequations, rewrite rules
    case Connective
    
    case Invalid
}

public enum SymbolNotation {
    case Specific   // ! […]:(…)
    
    case Prefix     // f(…,…)
    case Infix      // … + …
    case Postfix    // …++
    case Invalid
}
