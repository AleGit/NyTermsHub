//
//  SharingNode.swift
//  NyTerms
//
//  Created by Alexander Maringele on 22.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

protocol SharingNode : Hashable {
    associatedtype Symbol : Hashable
    
    static var sharedNodes : Set <Self> { get set }
    
    var symbol : Symbol { get set }
    var children : [Self]? { get set }
    
    /// induces a retain cycle, but since all nodes are shared this should not be a problem.
    var parents : Set<Self> { get set }
    
    init()
}

extension SharingNode {
    var hashValue : Int {
        guard let children = self.children else {
            return self.symbol.hashValue
        }
        return children.reduce (self.symbol.hashValue) { $0 &+ $1.hashValue }
    }
}

extension SharingNode {
    init(symbol:Symbol, children: [Self]?) {
        self.init()
        
        self.symbol = symbol
        self.children = children
        
        if let index = Self.sharedNodes.indexOf(self) {
            self = Self.sharedNodes[index]
        }
        else {
            Self.sharedNodes.insert(self)
        }
        
//        if let cs = self.children {
//            for var child in cs {
//                child.parents.insert(self)
//            }
//        }
        
    }
    
    func isEqual(rhs:Self) -> Bool {
        guard self.symbol == rhs.symbol else { return false }
        // affirmed: symbols are equal
        
        if self.children == nil && rhs.children == nil {
            // both are variables
            return true
        }
        // affirmed: not both are variables
        
        guard let lcs = self.children, let rcs = rhs.children else {
            // one is a variable, one is not a variable
            return false
        }
        // affirmed: none is a variable
        
        return lcs == rcs
    
    }
}

func ==<N:SharingNode>(lhs:N, rhs:N) -> Bool {
    return lhs.isEqual(rhs)
}

func ==<N:SharingNode where N:AnyObject>(lhs:N, rhs:N) -> Bool {
    if lhs === rhs {
        return true
    }
    else { return lhs.isEqual(rhs) }
}

extension ShareNode : CustomStringConvertible {
    var description : String {
        guard let children = self.children else {
            return ShareNode.i2s[symbol]?.0 ?? "'\(symbol)'"
        }
        
        let string = ShareNode.i2s[symbol]?.0 ?? "'\(symbol)'"
        let args = children.map { $0.description }.joinWithSeparator(",")
        return "\(string)(\(args))"
        
    }
    
    
}

//func ==(lhs:ShareNode, rhs:ShareNode) -> Bool {
//    if lhs === rhs { return true }
//    else { return lhs.isEqual(rhs) }
//}



final class ShareNode : SharingNode {
    static var sharedNodes = Set<ShareNode>()
    
    static var s2i : [String : Int] = [
        "✻" : 0,
        "~" : 1,
        "|" : 2,
        "=" : 3,
        "!=" : 4
    ]
    static var i2s : [Int:(String,type:SymbolType, category:SymbolCategory, notation:SymbolNotation, arity:SymbolArity)] = [
        0 : ("✻", SymbolType.Wildcard, SymbolCategory.Variable, SymbolNotation.Infix, SymbolArity.None),
        1 : ("~", SymbolType.Negation, SymbolCategory.Connective, SymbolNotation.Prefix, SymbolArity.Fixed(1)),
        2 : ("|", SymbolType.Conjunction, SymbolCategory.Connective, SymbolNotation.Infix, SymbolArity.Variadic(0..<Int.max)),
        3 : ("=", SymbolType.Equation, SymbolCategory.Equational, SymbolNotation.Infix, SymbolArity.Fixed(2)),
        4 : ("!=", SymbolType.Inequation, SymbolCategory.Equational, SymbolNotation.Infix, SymbolArity.Fixed(2))
    ]
    
    var symbol : Int = 0
    var children : [ShareNode]? = nil
    var parents = Set<ShareNode>()
    
    // init() { }
    
    static func insert<N:Node where N.Symbol == String>(node:N, belowPredicate:Bool) -> (ShareNode,[(String,Position)]) {
        
        var abovePredicate : Bool
        var isPredicate : Bool
        
        if let index = s2i[node.symbol] {
            // symbol is registerd, hence it has the right type
            switch i2s[index]!.type {
            case .Negation, .Conjunction:
                abovePredicate = true
                isPredicate = false
            case .Predicate, .Equation, .Inequation:
                abovePredicate = false
                isPredicate = true
                break
                
            default:
                abovePredicate = false
                isPredicate = false
            }
        }
        else {
            abovePredicate = false
            isPredicate = !belowPredicate
        }

        guard let nodes = node.nodes   else {
            // variables are all the same
            
            assert(belowPredicate,"variable \(node) must be below a predicate")
            
            let x = ShareNode(symbol:0, children:nil)
            
            return (x,[(node.symbol,ε)]) // variable at root position
        }
        
        let symbol = s2i[node.symbol] ?? s2i.count
        
        if symbol < s2i.count {
            assert(i2s[symbol]!.arity.contains(nodes.count))
        }
        else {
            s2i[node.symbol] = symbol
            i2s[symbol] = (node.symbol,
                           isPredicate ? SymbolType.Predicate : SymbolType.Function,
                           SymbolCategory.Functor,
                           SymbolNotation.Infix,
                           SymbolArity.Fixed(nodes.count))
        }
        
        let pairs = nodes.map { insert($0, belowPredicate: belowPredicate || (!abovePredicate && isPredicate)) }
        let f = ShareNode(symbol:symbol, children: pairs.map { $0.0 } )
        
        var variables = [(String,Position)]()
        
        for (index, entry) in pairs.enumerate() {
            let array = entry.1.map { ($0.0,[index]+$0.1) }
            variables += array
            
        }
        
        // return (f, pairs.flatMap { $0.1 })
        return (f,variables)
    }
}


