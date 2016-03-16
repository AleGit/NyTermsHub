//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

enum SymHop<S:Hashable> {
    case Symbol(S)
    case Hop(Int)
}

extension SymHop: Hashable {
    var hashValue : Int {
        switch self {
        case let .Symbol(symbol):
            return symbol.hashValue
        case let .Hop(hop):
            return hop.hashValue
        }
    }
}

extension SymHop : CustomStringConvertible {
    var description : String {
        switch self {
        case let .Symbol(symbol):
            return "\(symbol)"
        case let .Hop(hop):
            return "\(hop)"
        }
    }
}

func ==<S:Hashable>(lhs:SymHop<S>, rhs:SymHop<S>) -> Bool {
    switch(lhs,rhs) {
    case let (.Symbol(lsymbol), .Symbol(rsymbol)):
        return lsymbol == rsymbol
    case let (.Hop(lhop), .Hop(rhop)):
        return lhop == rhop
    default:
        return false
    }
}

typealias SymHopPath = [SymHop<String>]
typealias SymbolPath = [StringSymbol]

extension Node where Symbol == String {
    
    var symHopPaths : [SymHopPath] {
        guard let nodes = self.nodes else {
            // a variable
            return [[.Symbol("*")]]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[.Symbol(self.symbol)]]
        }
        
        var symHopPaths = [SymHopPath]()
        
        for (index,subpaths) in (nodes.map { $0.symHopPaths }).enumerate() {
            for subpath in subpaths {
                symHopPaths.append([.Symbol(self.symbol), .Hop(index)] + subpath)
            }
        }
        return symHopPaths
    }
    
    var symbolPaths : [SymbolPath] {
        guard let nodes = self.nodes else {
            // a variable
            return [["*"]]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[self.symbol]]
        }
        
        var paths = [[Symbol]]()
        
        for (index,subpaths) in (nodes.map { $0.symbolPaths }).enumerate() {
            for subpath in subpaths {
                let path = [self.symbol, "\(index)"] + subpath
                paths.append(path)
            }
        }
        return paths
    }
    
    var preorderPath : SymbolPath {
        guard let nodes = self.nodes else {
            return ["*"]
        }
        
        guard nodes.count > 0 else {
            return [self.symbol]
        }
        
        return nodes.reduce([self.symbol]) { $0 + $1.preorderPath }
        
        
    }
}

func buildNodeTrie<N:Node where N.Symbol == String>(nodes:[N]) -> TrieStruct<SymHop<String>, N> {
    var trie = TrieStruct<SymHop<String>,N>()
    
    for node in nodes {
        let symHopPaths = node.symHopPaths
        for path in symHopPaths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
