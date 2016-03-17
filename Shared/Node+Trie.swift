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



extension Node {
    private func paths<T>(sym2edge:Symbol->T,_ hop2edge:Int->T) -> [[T]] {
        guard let nodes = self.nodes else {
            // a variable
            return [ [sym2edge(Self.symbol(.Wildcard))] ]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[sym2edge(self.symbol)]]
        }
        
        var paths = [[T]]()
        
        for (index,subpaths) in (nodes.map { $0.paths(sym2edge,hop2edge) }).enumerate() {
            for subpath in subpaths {
                paths.append([sym2edge(self.symbol), hop2edge(index)] + subpath)
            }
        }
        return paths
    }
    
    typealias SymbolPath = [Symbol]
    var preorderPath : SymbolPath {
        guard let nodes = self.nodes else {
            return [Self.symbol(.Wildcard)]
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
        let sym2edge : Symbol -> String = { "\($0)" }
        let hop2edge : Int -> String = { "\($0)" }
        
        return self.paths(sym2edge,hop2edge)
    }
    
    var intPaths: [IntegerPath] {
        let sym2edge : Symbol -> Int = { $0.hashValue }
        let hop2edge : Int -> Int = { $0 }
        
        return self.paths(sym2edge,hop2edge)
    }
    
    typealias SymHopPath = [SymHop<Symbol>]
    var paths : [SymHopPath] {
        
        let sym2edge : Symbol -> SymHop<Symbol> = { SymHop.Symbol($0) }
        let hop2edge : Int -> SymHop<Symbol> = { SymHop.Hop($0) }
        
        return self.paths(sym2edge,hop2edge)
    }
}

func buildNodeTrie<N:Node>(nodes:[N]) -> TrieStruct<SymHop<N.Symbol>, N> {
    var trie = TrieStruct<SymHop<N.Symbol>,N>()
    
    for node in nodes {
        let paths = node.paths
        for path in paths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
