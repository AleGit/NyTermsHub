//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

/// Class `TptpTerm` is the generic bridging implementation of protocol `Term` (Swift) to the *TPTP* parser (C).
/// The root node of an abstract syntax tree with TptpTerms represents one of the follwing TPTP types:
/// - cnf_formula
/// - fof_formula
public final class TptpTerm: NSObject, Term {
    public let symbol: String
    public var terms: [TptpTerm]?
    
    public init(symbol: String, terms: [TptpTerm]?) {
        self.symbol = symbol
        self.terms = terms
    }
    
    /// Since TptpTerm inherits description from NSObject
    /// it would not call the protocol extension's implementation.
    public override var description : String {
        return self.defaultDescription
    }
    
    /// Appends additonal term to subterms of connective.
    /// - fof_or_formula '|' fof_unitary_formula
    /// - fof_and_formula '&' fof_unitary_formula
    public func append(term: TptpTerm) {
        if self.terms == nil { self.terms = [term] }
        else { self.terms!.append(term) }
    }
    
    /// Since TptpTerm inherits isEqual from NSObject
    /// it would not call the protocol extension's implementation.
    public override func isEqual(object: AnyObject?) -> Bool {
       
        guard let rhs = object as? TptpTerm else { return false }
        
        return self.isEqual(rhs)
    }
    
    /// Since TptpTerm inherits hashValue from NSObject
    /// it would not call the protocol extension's implementation.
    public override var hashValue : Int {
        return self.hashValueDefault
    }
    
    // MARK: - TptpTerm symbols:
    
    static let symbolsDictionary : [String:(type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:Range<Int>)] = [
        // <assoc_connective> ::= <vline> | &
        "&" : (type:SymbolType.Conjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range(start: 0, end:Int.max)),
        "|" : (type:SymbolType.Disjunction, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range(start: 0, end:Int.max)),
        // <unary_connective> ::= ~
        "~" : (type:SymbolType.Negation, category:SymbolCategory.Connective, notation:SymbolNotation.Prefix, arity:Range(start:1, end:2)),
        // <binary_connective>  ::= <=> | => | <= | <~> | ~<vline> | ~&
        "=>" : (type:SymbolType.Implication, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        "<=" : (type:SymbolType.Converse, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start: 1, end: Int.max)),
        "<=>" : (type:SymbolType.IFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        "~&" : (type:SymbolType.NAND, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        "~|" : (type:SymbolType.NOR, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        "<~>" : (type:SymbolType.NIFF, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        // <fol_quantifier> ::= ! | ?
        "!" : (type:SymbolType.Existential, category:SymbolCategory.Connective, notation:SymbolNotation.Specific, arity:Range<Int>(start:2, end:3)),
        "?" : (type:SymbolType.Universal, category:SymbolCategory.Connective, notation:SymbolNotation.Specific, arity:Range<Int>(start:2, end:3)),
        // <gentzen_arrow>      ::= -->
        "-->" : (type:SymbolType.Sequent, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        // <defined_infix_formula>  ::= <term> <defined_infix_pred> <term>
        // <defined_infix_pred> ::= <infix_equality>
        // <infix_equality>     ::= =
        "=" : (type:SymbolType.Equation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        // <fol_infix_unary>    ::= <term> <infix_inequality> <term>
        // <infix_inequality>   ::= !=
        "!=" : (type:SymbolType.Inequation, category:SymbolCategory.Equational, notation:SymbolNotation.Infix, arity:Range<Int>(start:2, end:3)),
        
        "," : (type:SymbolType.Tuple, category:SymbolCategory.Connective, notation:SymbolNotation.Infix, arity:Range<Int>(start:1, end:Int.max))
    ]
    
    static public func predicate(term:TptpTerm) {
        #if PREDICATE_TABLE
        guard let terms = term.terms else {
            assert(false)
            return
        }
            SymbolTable.add(predicate: term.symbol, arity: terms.count)
        #endif
    }

}



extension TptpTerm {
    
    public convenience init(variable symbol:Symbol) {
        assert(symbol.category != SymbolCategory.Auxiliary, "variables must not overlap auxiliary symbols")
        assert(symbol.category != SymbolCategory.Connective, "variables symbols must not overlap connective symbols")
        assert(symbol.category != SymbolCategory.Equational, "variables must not overlap equational symbols")
        
        #if VARIABLE_TABLE || FULL_TABLE
            SymbolTable.add(variable: symbol)
        #endif
        self.init(symbol:symbol,terms: nil)
    }
    
    public convenience init(constant symbol:Symbol) {
        assert(symbol.category != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(symbol.category != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(symbol.category != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
        
        #if FUNCTION_TABLE || FULL_TABLE
            SymbolTable.add(constant: symbol)
        #endif
        self.init(symbol:symbol,terms: [TptpTerm]())
    }
    
    public convenience init(functional symbol:Symbol, terms:[TptpTerm]) {
        assert(terms.count > 0)
        assert(symbol.category != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(symbol.category != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(symbol.category != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
        
        #if FUNCTION_TABLE || FULL_TABLE
            SymbolTable.add(function: symbol, arity: terms.count)
        #endif
        self.init(symbol:symbol,terms: terms)
    }
    
    public convenience init(predicate symbol:Symbol, terms:[TptpTerm]) {
        assert(symbol.category != SymbolCategory.Auxiliary, "uninterpreted predicate symbols must not overlap auxiliary symbols")
        assert(symbol.category != SymbolCategory.Connective, "uninterpreted predicate symbols must not overlap connective symbols")
        assert(symbol.category != SymbolCategory.Equational, "uninterpreted predicate symbols must not overlap equational symbols")
        
        assert(terms.reduce(true) { $0 && $1.isFunctionTree },"predicate subterms must be functional terms")
        
        #if FUNCTION_TABLE || FULL_TABLE
            SymbolTable.add(predicate: symbol, arity: terms.count)
        #endif
        self.init(symbol:symbol,terms: terms)
    }
    
    public convenience init(equational symbol:Symbol, terms:[TptpTerm]) {
        assert(terms.count == 2)
        assert(symbol.category == SymbolCategory.Equational, "equational symbols must be predefined")
        self.init(symbol:symbol,terms: terms)
    }
    
    public convenience init(connective symbol:Symbol, terms:[TptpTerm]) {
        assert(terms.count > 0)
        assert(symbol.category == SymbolCategory.Connective, "connective symbols must be predefined")
        self.init(symbol:symbol,terms: terms)
    }
    
}

extension TptpTerm : StringLiteralConvertible {
    private static func parse(stringLiteral value:String) -> TptpTerm {
        assert(!value.isEmpty)

        if value.containsOne(SymbolTable.symbols(category:SymbolCategory.Connective)) {
            // fof_formula or cnf_formula (i.e. fof_formula in connjective normal form)
            return TptpFormula.FOF(stringLiteral: value).formula
        }
        else if value.containsOne(SymbolTable.symbols(type:SymbolType.LeftParenthesis)) {
            
            // single equation, predicate or (function) term
            let cnf = TptpFormula.CNF(stringLiteral: value)
            assert(cnf.formula.symbol.type == SymbolType.Disjunction)
            assert(cnf.formula.terms!.count == 1)
            let predicate = cnf.formula.terms!.first!
            // self.init(symbol: predicate.symbol, terms: predicate.terms)
            return predicate
        }
        else {
            // a variable (UPPER_WORD) or a constant (LOWER_WORD)
            
            let first = String(value.characters.first!)
            
            switch first {
            case first.uppercaseString:
                return TptpTerm(variable:value) // UPPER_WORD, i.e. first character is uppercase
            default:
                return TptpTerm(constant:value) // LOWER_WORD, i.e. first character is not uppercase
            }
        }
    }
    
    // TODO: Implementation of `StringLiteralConvertible` is still a hack.
    /// Parse a single (function) term or a single equation between two terms.
    public convenience init(stringLiteral value: StringLiteralType) {
        let term = TptpTerm.parse(stringLiteral: value)
        self.init(symbol: term.symbol, terms: term.terms)
    }
}


