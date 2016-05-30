//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

/// `TptpNode` is the bridging implementation of protocol `Node` (Swift) to the *TPTP* parser (C).
/// The root node of an abstract syntax tree with TptpTerms represents one of the follwing TPTP types:
/// - cnf_formula
/// - fof_formula
final class TptpNode: NSObject, Node {
    let symbol: String
    var nodes: [TptpNode]?
    private var cachedDescription : String? = nil
    private var cachedHashValue : Int? = nil
    
    init(symbol: String, nodes: [TptpNode]?) {
        self.symbol = symbol
        self.nodes = nodes
    }
    
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
    
    func register(type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity) -> Bool {
        if let quadruple = self.symbolQuadruple() {
            assert(quadruple.type==type)
            assert(quadruple.category == category)
            assert(quadruple.notation == notation)
            
            assert(quadruple.arity.contains(arity),"\(self.symbol), \(quadruple), \(arity)")

            
            return quadruple.type==type
                && quadruple.category == category
                // && quadruple.notation == notation
                && quadruple.arity.contains(arity)
            
            
            
        }
        else {
            globalStringSymbols[self.symbol] = (type,category,notation,arity)
            return true
        }
    }
    
    var symbolQuadruple : () -> SymbolQuadruple? {
        return {
            return globalStringSymbols[self.symbol] // could be nil
        }
    }
}

extension TptpNode {
    
    convenience init(symbol:StringSymbol) {
        self.init(symbol:symbol, nodes:[TptpNode]())
    }
    
    convenience init(variable symbol:StringSymbol) {
        
        self.init(symbol:symbol,nodes: nil)
        
        assert(self.symbolCategory != SymbolCategory.Auxiliary, "variables must not overlap auxiliary symbols")
        assert(self.symbolCategory != SymbolCategory.Connective, "variables must not overlap connective symbols")
        assert(self.symbolCategory != SymbolCategory.Equational, "variables must not overlap equational symbols")
    }
    
    convenience init(constant symbol:StringSymbol) {
        
        self.init(symbol:symbol)
        assert(self.symbolCategory != SymbolCategory.Auxiliary, "uninterpreted constant symbols must not overlap auxiliary symbols")
        assert(self.symbolCategory != SymbolCategory.Connective, "uninterpreted constant symbols must not overlap connective symbols")
        assert(self.symbolCategory != SymbolCategory.Equational, "uninterpreted constant symbols must not overlap equational symbols")
    }
    
    convenience init(functional symbol:StringSymbol) {
        
        self.init(symbol:symbol)
        assert(self.symbolCategory != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(self.symbolCategory != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(self.symbolCategory != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
    }
    
    convenience init(functional symbol:StringSymbol, nodes:[TptpNode]) {
        assert(nodes.count > 0, "uninterpreted functions must have one argumument at least")
        
        self.init(symbol:symbol,nodes: nodes)
        assert(self.symbolCategory != SymbolCategory.Auxiliary, "uninterpreted function symbols must not overlap auxiliary symbols")
        assert(self.symbolCategory != SymbolCategory.Connective, "uninterpreted function symbols must not overlap connective symbols")
        assert(self.symbolCategory != SymbolCategory.Equational, "uninterpreted function symbols must not overlap equational symbols")
    }
    
    convenience init(predicate symbol:StringSymbol, nodes:[TptpNode]) {
        assert(nodes.reduce(true) { $0 && $1.isTerm },"predicate subnodes must be functional nodes")
        
        self.init(symbol:symbol,nodes: nodes)
        assert(self.symbolCategory != SymbolCategory.Auxiliary, "uninterpreted predicate symbols must not overlap auxiliary symbols")
        assert(self.symbolCategory != SymbolCategory.Connective, "uninterpreted predicate symbols must not overlap connective symbols")
        assert(self.symbolCategory != SymbolCategory.Equational, "uninterpreted predicate symbols must not overlap equational symbols")
    }
    
    convenience init(equational symbol:StringSymbol) {
        
        self.init(symbol:symbol)
        assert(self.symbolCategory == SymbolCategory.Equational, "equational symbols must be predefined")
    }
    
    convenience init(equational symbol:StringSymbol, nodes:[TptpNode]) {
        assert(nodes.count == 2)
        
        self.init(symbol:symbol,nodes: nodes)
        assert(self.symbolCategory == SymbolCategory.Equational, "equational symbols must be predefined")
    }
    
    convenience init(connective symbol:StringSymbol) {
        
        self.init(symbol:symbol)
        assert(self.symbolCategory == SymbolCategory.Connective, "\(symbol) connective symbols must be predefined")
    }
    
    convenience init(connective symbol:StringSymbol, nodes:[TptpNode]) {
        
        self.init(symbol:symbol,nodes: nodes)
        assert(self.symbolCategory == SymbolCategory.Connective, "connective symbols must be predefined")
    }
    
}

extension TptpNode : StringLiteralConvertible {
    private static func node(stringLiteral value:String) -> TptpNode {
        assert(!value.isEmpty)

        if value.containsOne(TptpNode.connectives) {
            // fof_formula or cnf_formula (i.e. fof_formula in connjective normal form)
            return TptpFormula.FOF(stringLiteral: value).root
        }
        else if value.containsOne(["(","=","!="]) {
            
            // single equation, predicate or (function) term
            let cnf = TptpFormula.CNF(stringLiteral: value)
            assert(cnf.root.symbolType == SymbolType.Disjunction)
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
        let term = TptpNode.node(stringLiteral: value)
        self.init(symbol: term.symbol, nodes: term.nodes)
    }
}



extension TptpNode {
    static func roots(path:String) -> [TptpNode] {
        return parse(path:path).1.map { $0.root }
    }
    
    static func literals(path:String) -> [TptpNode] {
        return parse(path:path).1.flatMap { $0.root.nodes ?? [TptpNode]() }
    }
}




