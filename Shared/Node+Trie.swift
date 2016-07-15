//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

enum SymHop<S:Hashable> {
    case symbol(S)
    case hop(Int)
}

extension SymHop: Hashable {
    var hashValue : Int {
        switch self {
        case let .symbol(symbol):
            return symbol.hashValue
        case let .hop(hop):
            return hop.hashValue
        }
    }
}

extension SymHop : CustomStringConvertible {
    var description : String {
        switch self {
        case let .symbol(symbol):
            return "\(symbol)"
        case let .hop(hop):
            return "\(hop)"
        }
    }
}

func ==<S:Hashable>(lhs:SymHop<S>, rhs:SymHop<S>) -> Bool {
    switch(lhs,rhs) {
    case let (.symbol(lsymbol), .symbol(rsymbol)):
        return lsymbol == rsymbol
    case let (.hop(lhop), .hop(rhop)):
        return lhop == rhop
    default:
        return false
    }
}



extension Node {
    private func paths<T>(_ sym2edge:(Symbol)->T,_ hop2edge:(Int)->T) -> [[T]] {
        guard let nodes = self.nodes else {
            // a variable
            return [ [sym2edge(Self.symbol(.wildcard))] ]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[sym2edge(self.symbol)]]
        }
        
        var paths = [[T]]()
        
        for (index,subpaths) in (nodes.map { $0.paths(sym2edge,hop2edge) }).enumerated() {
            for subpath in subpaths {
                paths.append([sym2edge(self.symbol), hop2edge(index)] + subpath)
            }
        }
        return paths
    }
    
    typealias SymbolPath = [Symbol]
    var preorderPath : SymbolPath {
        guard let nodes = self.nodes else {
            return [Self.symbol(.wildcard)]
        }
        
        let first = [self.symbol]
        
        guard nodes.count > 0 else {
            return first
        }
        
        return nodes.reduce(first) { $0 + $1.preorderPath }
    }
}

typealias StringPath = [String]
typealias IntegerPath = [Int]

extension Node {
    var stringPaths : [StringPath] {
        let sym2edge : (Symbol) -> String = { "\($0)" }
        let hop2edge : (Int) -> String = { "\($0)" }
        
        return self.paths(sym2edge,hop2edge)
    }
    
    var intPaths: [IntegerPath] {
        let sym2edge : (Symbol) -> Int = { $0.hashValue }
        let hop2edge : (Int) -> Int = { $0 }
        
        return self.paths(sym2edge,hop2edge)
    }
    
    typealias SymHopPath = [SymHop<Symbol>]
    var paths : [SymHopPath] {
        
        let sym2edge : (Symbol) -> SymHop<Symbol> = { SymHop.symbol($0) }
        let hop2edge : (Int) -> SymHop<Symbol> = { SymHop.hop($0) }
        
        return self.paths(sym2edge,hop2edge)
    }
}

func buildNodeTrie<N:Node>(_ nodes:[N]) -> TrieStruct<SymHop<N.Symbol>, N> {
    var trie = TrieStruct<SymHop<N.Symbol>,N>()
    
    for node in nodes {
        let paths = node.paths
        for path in paths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
