//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

/// Class `TptpNode` is the generic bridging implementation of protocol `Node` (Swift) to the *TPTP* parser (C).
/// The root node of an abstract syntax tree with TptpTerms represents one of the follwing TPTP types:
/// - cnf_formula
/// - fof_formula
public final class TptpNode: NSObject, Node {
    public let symbol: String
    public var nodes: [TptpNode]?
    
    public init(symbol: String, nodes: [TptpNode]?) {
        self.symbol = symbol
        self.nodes = nodes
    }
    
    /// Since TptpNode inherits description from NSObject
    /// it would not call the protocol extension's implementation.
    public override var description : String {
        return self.defaultDescription
    }
    
    /// Appends additonal term to subterms of connective.
    /// - fof_or_formula '|' fof_unitary_formula
    /// - fof_and_formula '&' fof_unitary_formula
    public func append(term: TptpNode) {
        if self.nodes == nil { self.nodes = [term] }
        else { self.nodes!.append(term) }
    }
    
    /// Since TptpNode inherits isEqual from NSObject
    /// it would not call the protocol extension's implementation.
    public override func isEqual(object: AnyObject?) -> Bool {
       
        guard let rhs = object as? TptpNode else { return false }
        
        return self.isEqual(rhs)
    }
    
    /// Since TptpNode inherits hashValue from NSObject
    /// it would not call the protocol extension's implementation.
    public override var hashValue : Int {
        return self.hashValueDefault
    }
    
    func setPredicate() {
        #if PREDICATE_TABLE
        guard let nodes = self.nodes else {
            assert(false)
            return
        }
            Symbols.add(predicate: self.symbol, arity: nodes.count)
        #endif
    }

}



extension TptpNode {
    
    public convenience init(variable symbol:Symbol) {
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Auxiliary, "variables must not overlap auxiliary symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Connective, "variables must not overlap connective symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Equational, "variables must not overlap equational symbols")
        
        #if VARIABLE_TABLE || FULL_TABLE
            Symbols.add(variable: symbol)
        #endif
        self.init(symbol:symbol,nodes: nil)
    }
    
    public convenience init(constant symbol:Symbol) {
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted constant symbols must not overlap auxiliary symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Connective, "uninterpreted constant symbols must not overlap connective symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Equational, "uninterpreted constant symbols must not overlap equational symbols")
        
        #if FUNCTION_TABLE || FULL_TABLE
            Symbols.add(constant: symbol)
        #endif
        self.init(symbol:symbol,nodes: [TptpNode]())
    }
    
    public convenience init(functional symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count > 0, "uninterpreted functions must have one argumument at least")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
        
        #if FUNCTION_TABLE || FULL_TABLE
            Symbols.add(function: symbol, arity: nodes.count)
        #endif
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public convenience init(predicate symbol:Symbol, nodes:[TptpNode]) {
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted predicate symbols must not overlap auxiliary symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Connective, "uninterpreted predicate symbols must not overlap connective symbols")
        assert(Symbols.defined[symbol]?.category != SymbolCategory.Equational, "uninterpreted predicate symbols must not overlap equational symbols")
        
        assert(nodes.reduce(true) { $0 && $1.isTerm },"predicate subnodes must be functional nodes")
        
        #if FUNCTION_TABLE || FULL_TABLE
            Symbols.add(predicate: symbol, arity: nodes.count)
        #endif
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public convenience init(equational symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count == 2)
        assert(Symbols.defined[symbol]?.category == SymbolCategory.Equational, "equational symbols must be predefined")
        self.init(symbol:symbol,nodes: nodes)
    }
    
    public convenience init(connective symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count > 0)
        assert(Symbols.defined[symbol]?.category == SymbolCategory.Connective, "connective symbols must be predefined")
        self.init(symbol:symbol,nodes: nodes)
    }
    
}

extension TptpNode : StringLiteralConvertible {
    private static func parse(stringLiteral value:String) -> TptpNode {
        assert(!value.isEmpty)

        if value.containsOne(Symbols.symbols(category:SymbolCategory.Connective)) {
            // fof_formula or cnf_formula (i.e. fof_formula in connjective normal form)
            return TptpFormula.FOF(stringLiteral: value).root
        }
        else if value.containsOne(Symbols.symbols(type:SymbolType.LeftParenthesis)) {
            
            // single equation, predicate or (function) term
            let cnf = TptpFormula.CNF(stringLiteral: value)
            assert(Symbols.defined[cnf.root.symbol]?.type == SymbolType.Disjunction)
            assert(cnf.root.nodes!.count == 1)
            let predicate = cnf.root.nodes!.first!
            // self.init(symbol: predicate.symbol, nodes: predicate.nodes)
            return predicate
        }
        else {
            // a variable (UPPER_WORD) or a constant (LOWER_WORD)
            
            let first = String(value.characters.first!)
            
            switch first {
            case first.uppercaseString:
                return TptpNode(variable:value) // UPPER_WORD, i.e. first character is uppercase
            default:
                return TptpNode(constant:value) // LOWER_WORD, i.e. first character is not uppercase
            }
        }
    }
    
    // TODO: Implementation of `StringLiteralConvertible` is still a hack.
    /// Parse a single (function) term or a single equation between two terms.
    public convenience init(stringLiteral value: StringLiteralType) {
        let term = TptpNode.parse(stringLiteral: value)
        self.init(symbol: term.symbol, nodes: term.nodes)
    }
}


