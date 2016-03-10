//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Abstract data type `Node`.
/// A tree of nodes can represent a term, e.g
///
/// * (leaf) variable terms: X, Y, Zustand
/// * (leaf) constant terms: a, b, config
/// * (tree) functional terms: f(X,a)
/// * (tree) predicate terms: p(f(X,a)
/// * (tree) equational terms: a = X, b ~= f(X,a)
/// * (root) clause terms: a=X | b ~= f(X,a)
/// * (root) formuala terms: ...
protocol Node : Hashable, CustomStringConvertible, StringLiteralConvertible {
    var symbol : Symbol { get }
    var nodes : [Self]? { get }
    
    init (symbol:Symbol, nodes:[Self]?)
}

// MARK: convenience initializers

extension Node {
    init(variable symbol:Symbol) {
        self.init(symbol:symbol,nodes: nil)
    }
    
    init(constant symbol:Symbol) {
        self.init(symbol:symbol,nodes: [Self]())
    }
    
    init(function symbol:Symbol, nodes:[Self]) {
        assert(nodes.count>0)
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(predicate symbol:Symbol, nodes:[Self]) {
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(equational symbol:Symbol, nodes:[Self]) {
        assert(nodes.count==2,"an equational term must have exactly two subnodes.")
        self.init(symbol:symbol,nodes: nodes)
    }
    
    init(connective symbol:Symbol, nodes:[Self]) {
        // assert(nodes.count>0,"a connective \(symbol) \(nodes)term must have at least one subnode")
        self.init(symbol:symbol,nodes: nodes)
    }
}

// MARK: Hashable : Equatable

extension Node {
    func isEqual(rhs:Self) -> Bool {
        if self.symbol != rhs.symbol  { return false }               // the symbols are equal
        
        if self.nodes == nil && rhs.nodes == nil { return true }     // both are nil (both are variables)
        if self.nodes == nil || rhs.nodes == nil { return false }    // one is nil, not both. (one is variable, the other is not)
        return self.nodes! == rhs.nodes!                             // none is nil (both are functions)
    }
    
    func isVariant(rhs:Self) -> Bool {
        guard let mgu = (self =?= rhs) else { return false }
        
        return mgu.isRenaming
    }
    
    func isUnifiable(rhs:Self) -> Bool {
        return (self =?= rhs) != nil
    }
}

func ==<T:Node> (lhs:T, rhs:T) -> Bool {
    return lhs.isEqual(rhs)
}

extension Node {
    var defaultHashValue : Int {
        let val = self.symbol.hashValue //  &+ self.type.hashValue
        guard let nodes = self.nodes else { return val }
        
        return nodes.reduce(val) { $0 &+ $1.hashValue }
    }
    
    var hashValue : Int {
        return self.defaultHashValue
    }
}

// MARK: CustomStringConvertible

extension Node {
    
    
    /// Representation of self:Node in TPTP Syntax.
    var tptpDescription : String {
        return buildDescription { $0.0 }
    }
    
    func buildDescription(decorate:(symbol:String,type:SymbolType)->String) -> String {
        
        assert(!self.symbol.isEmpty, "a term must not have an emtpy symbol")
        
        guard let nodes = self.nodes else {
            // since self has not list of subnodes at all,
            // self must be a variable term
            assert((self.symbol.type ?? SymbolType.Variable) == SymbolType.Variable, "\(self.symbol) is variable term with wrong type \(self.symbol.quadruple!)")
            
            return decorate(symbol:self.symbol, type:SymbolType.Variable)
        }
        
        let decors = nodes.map { $0.buildDescription(decorate) }
        
        guard let quadruple = self.symbol.quadruple else {
            // If the symbol is not defined in the global symbol table,
            // i.e. a function or predicate symbol
            let decor = decorate(symbol:self.symbol,type:SymbolType.Function)
            
            // we assume prefix notation for (constant) functions or predicates:
            switch nodes.count {
            case 0:
                return "\(decor)" // constant (or proposition)
            default:
                
                return "\(decor)(\(decors.joinWithSeparator(Symbol.separator)))" // prefix function (or predicate)
            }
        }
        
        assert(quadruple.arities.contains(nodes.count), "'\(self.symbol)' has invalid number \(nodes.count) of subnodes  ∉ \(quadruple.arities).")
        
        let decor = decorate(symbol:self.symbol, type:quadruple.type)
        
        switch quadruple {
            
        case (.Universal,_,.TptpSpecific,_), (.Existential,_,.TptpSpecific,_):
            return "(\(decor)[\(decors.first!)]:(\(decors.last!)))" // e.g.: ! [X,Y,Z] : ( P(f(X,Y),Z) & f(X,X)=g(X) )
            
        case (_,_,.TptpSpecific,_):
            assertionFailure("'\(symbol)' has ambiguous notation \(quadruple).")
            return "\(decor)☇(\(decors.joinWithSeparator(Symbol.separator)))"
            
        case (.Universal,_,_,_), (.Existential,_,_,_):
            return "(\(decor)\(decors.first!) (\(decors.last!)))" // e.g.: ∀ x,y,z : ( P(f(x,y),z) ∧ f(x,x)=g(x) )
            
        case (_,_,.Prefix,_) where nodes.count == 0:
            return "\(decor)"
            
        case (_,_,.Prefix,_):
            return "\(decor)(\(decors.joinWithSeparator(Symbol.separator)))"
            
        case (_,_,.Minus,_) where nodes.count == 1:
            return "\(decor)(\(decors.first!)"
            
        case (_,_,.Minus,_), (_,_,.Infix,_):
            return decors.joinWithSeparator(decor)
            
        case (_,_,.Postfix,_):
            assertionFailure("'\(symbol),\(decor)' uses unsupported postfix notation \(quadruple).")
            return "(\(decors.joinWithSeparator(Symbol.separator)))\(decor)"
            
        case (_,_,.Invalid,_):
            assertionFailure("'\(symbol),\(decor)' has invalid notation: \(quadruple)")
            return "☇\(decor)☇(\(decors.joinWithSeparator(Symbol.separator)))"
            
        default:
            assertionFailure("'\(symbol)' has impossible notation: \(quadruple)")
            return "☇☇\(decor)☇☇(\(decors.joinWithSeparator(Symbol.separator)))"
        }
    }
    
    var description : String {
        return tptpDescription
    }
}

extension Node {
    
    var laTeXDescription : String {
        return buildDescription ( LaTeX.Symbols.decorate )
        
    }
}

extension Node {
    private func buildSyntaxTree(level:Int, decorate:(symbol:String,type:SymbolType)->String) -> String {
        
        var s = "node "
        
        if let nodes = self.nodes {
            
            
            
            let quadruple = self.symbol.quadruple ??
                (type:SymbolType.Function,category:SymbolCategory.Functor, notation:SymbolNotation.Infix, arities: 0..<Int.max)
            
            let decor = decorate(symbol:self.symbol,type:quadruple.type)
            
            switch quadruple.type {
            case .Tuple:
                let variables = nodes.map { decorate(symbol: $0.symbol, type: .Variable) }
                s += "{$[\(variables.joinWithSeparator(","))]$}"
            default:
                let trees = nodes.map { "child {\($0.buildSyntaxTree(level+1,decorate: decorate))}" }
                
                
                let n = nodes.count
                
                switch n {
                case 0:
                    s += "{$\(decor)$}" // constant (or proposition)
                default:
                    
                    s += "{$\(decor)$}"
                    
                    var width = 160
                    for _ in 0..<level { width /= 2 }
                    let (start,angle) = (n == 1) ? (-90,0) : (-90-width/2,-width/(n-1))
                    s += "\n% [clockwise from=\(start),sibling angle=\(angle)]"
                    
                    var separator = "\n"
                    for _ in 0..<level { separator += " " }
                    s += separator
                    
                    s += "\(trees.joinWithSeparator(separator))" // prefix function (or predicate)
                }
            }
        }
        else {
            s += "{$\(decorate(symbol:self.symbol, type:SymbolType.Variable))$}"
        }
        
        return s
    }
    
    var tikzSyntaxTree : String {
        let tree = buildSyntaxTree(0, decorate: LaTeX.Symbols.decorate)
        return "\\\(tree);"
    }
}

// MARK: StringLiteralConvertible : ExtendedGraphemeClusterLiteralConvertible : UnicodeScalarLiteralConvertible

extension Node {
    
    init(unicodeScalarLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    
    init(extendedGraphemeClusterLiteral value: StringLiteralType) {
        self.init(stringLiteral: value)
    }
    /*
    // implemenations of the protocol must provide this initializer
    init(stringLiteral value: StringLiteralType) {
    self.init(constant:"failed")
    }
    */
}

// MARK: Conversion between `Node` implemenations.

extension Node {
    init<T:Node>(_ s:T) {    // similar to Int(3.5)
        
        // no conversion between same types
        if let t = s as? Self {
            self = t
        }
        else if let nodes = s.nodes {
            self = Self(symbol: s.symbol, nodes: nodes.map { Self($0) } )
        }
        else {
            self = Self(variable:s.symbol)
        }
    }
}

func +(lhs:(Int,Int,Int),rhs:(Int,Int,Int)) -> (Int,Int,Int) {
    return (lhs.0+rhs.0, lhs.1+rhs.1, lhs.2+rhs.2)
}

func /(lhs:(Int,Int,Int),rhs:Int) -> (Double,Double,Double) {
    
    let f = { (a:Int,b:Int) -> Double in
        let c = 10.0 * Double(a)/Double(b) + 0.5
        
        return floor(c)/10.0
    }
    
    return (f(lhs.0,rhs), f(lhs.1,rhs), f(lhs.2,rhs))
}

extension Node {
    var height : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have height = 0
            return 0
        }
        
        // the height of a (constant) function
        // is one plus the maximum height of its arguments
        return 1 + nodes.reduce(0) { max($0,$1.height) }
    }
    
    var size : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have size = 1
            return 1
        }
        
        // the size of a (constant) function
        // is one plus the sum of sizes of its arguments.
        return nodes.reduce(1) { $0+$1.size }
        // 1 + nodes.reduce(0) { $0+$1.size }
    }
    
    var width : Int {
        guard let nodes = self.nodes
            where nodes.count > 0 // necessary
            else {
                // constants and variables have width = 1
            return 1
        }
        
        // the width of a function 
        // is the sum of the widths of its arguments
        return nodes.reduce(0) { $0 + $1.width }
    }
    
    var hsw : (height:Int,size:Int,width:Int) {
        guard let nodes = self.nodes
            where nodes.count > 0 // superfluous but correct
            else  {
                // constants and variables have height = 0
                return (0,1,1)
        }
        
        // the height of a (constant) function
        // is one plus the maximum height of its arguments
        return (1,1,0) + nodes.reduce((0,0,0)) {
            (a,b) -> (Int,Int,Int) in
            let (h0,s0,w0) = a
            let (h1,s1,w1) = b.hsw
            
            return ( max(h0,h1), s0+s1, w0+w1 )
            
        }
    }
}



