//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

/// `TptpNode` is the bridging implementation of protocol `Node` (Swift) to the *TPTP* parser (C).
/// The root node of an abstract syntax tree with TptpTerms represents one of the follwing TPTP types:
/// - cnf_formula
/// - fof_formula
final class TptpNode: NSObject, Node {
    #if INIT_COUNT
    static var count = 0
    #endif
    
    let symbol: String
    var nodes: [TptpNode]?
    private var cachedDescription : String? = nil
    private var cachedHashValue : Int? = nil
    
    init(symbol: String, nodes: [TptpNode]?) {
        #if INIT_COUNT
            TptpNode.count++
        #endif
        self.symbol = symbol
        self.nodes = nodes
    }
    
    #if INIT_COUNT
    deinit {
        TptpNode.count--
    }
    #endif
    
    private func updateDescription() -> String {
        let string = self.tptpDescription
        cachedDescription = string
        return string
    }
    
    /// Since TptpNode inherits description from NSObject
    /// it would not call the protocol extension's implementation.
    override var description : String {
        return cachedDescription ?? updateDescription()
    }
    
    /// Since TptpNode inherits isEqual from NSObject
    /// it would not call the protocol extension's implementation.
    override func isEqual(object: AnyObject?) -> Bool {
       
        guard let rhs = object as? TptpNode else { return false }
        
        return self.isEqual(rhs)
    }
    
    private func updateHashValue() -> Int {
        let value = self.defaultHashValue
        cachedHashValue = value
        return value
    }
    
    /// Since TptpNode inherits hashValue from NSObject
    /// it would not call the protocol extension's implementation.
    override var hashValue : Int {
        return cachedHashValue ?? updateHashValue()
    }
    
    /// Appends additonal term to subterms of connective.
    /// - fof_or_formula '|' fof_unitary_formula
    /// - fof_and_formula '&' fof_unitary_formula
    func append(term: TptpNode) {
        cachedDescription = nil // invalidate cached description
        cachedHashValue = nil // invalidate cached hash value
        
        if self.nodes == nil { self.nodes = [term] }
        else { self.nodes!.append(term) }
    }
}



extension TptpNode {
    
    convenience init(symbol:Symbol) {
        self.init(symbol:symbol, nodes:[TptpNode]())
    }
    
    convenience init(variable symbol:Symbol) {
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Auxiliary, "variables must not overlap auxiliary symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Connective, "variables must not overlap connective symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Equational, "variables must not overlap equational symbols")
        
        self.init(symbol:symbol,nodes: nil)
    }
    
    convenience init(constant symbol:Symbol) {
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted constant symbols must not overlap auxiliary symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Connective, "uninterpreted constant symbols must not overlap connective symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Equational, "uninterpreted constant symbols must not overlap equational symbols")
        
        self.init(symbol:symbol)
    }
    
    convenience init(functional symbol:Symbol) {
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
        
        self.init(symbol:symbol)
    }
    
    convenience init(functional symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count > 0, "uninterpreted functions must have one argumument at least")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
        
        self.init(symbol:symbol,nodes: nodes)
    }
    
    convenience init(predicate symbol:Symbol, nodes:[TptpNode]) {
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Auxiliary, "uninterpreted predicate symbols must not overlap auxiliary symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Connective, "uninterpreted predicate symbols must not overlap connective symbols")
        assert(Symbols.defaultSymbols[symbol]?.category != SymbolCategory.Equational, "uninterpreted predicate symbols must not overlap equational symbols")
        
        assert(nodes.reduce(true) { $0 && $1.isTerm },"predicate subnodes must be functional nodes")
        
        self.init(symbol:symbol,nodes: nodes)
    }
    
    convenience init(equational symbol:Symbol) {
        assert(Symbols.defaultSymbols[symbol]?.category == SymbolCategory.Equational, "equational symbols must be predefined")
        self.init(symbol:symbol)
    }
    
    convenience init(equational symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count == 2)
        assert(Symbols.defaultSymbols[symbol]?.category == SymbolCategory.Equational, "equational symbols must be predefined")
        self.init(symbol:symbol,nodes: nodes)
    }
    
    convenience init(connective symbol:Symbol) {
        assert(Symbols.defaultSymbols[symbol]?.category == SymbolCategory.Connective, "connective symbols must be predefined")
        self.init(symbol:symbol)
    }
    
    convenience init(connective symbol:Symbol, nodes:[TptpNode]) {
        assert(nodes.count > 0)
        assert(Symbols.defaultSymbols[symbol]?.category == SymbolCategory.Connective, "connective symbols must be predefined")
        self.init(symbol:symbol,nodes: nodes)
    }
    
}

extension TptpNode : StringLiteralConvertible {
    private static func parse(stringLiteral value:String) -> TptpNode {
        assert(!value.isEmpty)
        
        let connectives = Symbols.defaultSymbols.keys { $0.1.category == SymbolCategory.Connective }
        let leftpars = Symbols.defaultSymbols.keys { $0.1.type == SymbolType.LeftParenthesis }

        if value.containsOne(connectives) {
            // fof_formula or cnf_formula (i.e. fof_formula in connjective normal form)
            return TptpFormula.FOF(stringLiteral: value).root
        }
        else if value.containsOne(leftpars) {
            
            // single equation, predicate or (function) term
            let cnf = TptpFormula.CNF(stringLiteral: value)
            assert(Symbols.defaultSymbols[cnf.root.symbol]?.type == SymbolType.Disjunction)
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
    convenience init(stringLiteral value: StringLiteralType) {
        let term = TptpNode.parse(stringLiteral: value)
        self.init(symbol: term.symbol, nodes: term.nodes)
    }
}


