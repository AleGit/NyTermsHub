//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

enum SymHop {
    case Symbol(String)
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
            return symbol
        case let .Hop(hop):
            return "\(hop)"
        }
    }
}

func ==(lhs:SymHop, rhs:SymHop) -> Bool {
    switch(lhs,rhs) {
    case let (.Symbol(lsymbol), .Symbol(rsymbol)):
        return lsymbol == rsymbol
    case let (.Hop(lhop), .Hop(rhop)):
        return lhop == rhop
    default:
        return false
    }
}

typealias TermPath = Position<SymHop>



extension Node {
    
    var paths : [TermPath] {
        guard let nodes = self.nodes else {
            // a variable
            return [[.Symbol("*")]]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[.Symbol(self.symbol)]]
        }
        
        var paths = [TermPath]()
        
        for (index,subpaths) in (nodes.map { $0.paths }).enumerate() {
            for subpath in subpaths {
                paths.append([.Symbol(self.symbol), .Hop(index+1)] + subpath)
            }
        }
        return paths
    }
}




func buildNodeTrie<N:Node>(nodes:[N]) -> Trie<SymHop, N> {
    var trie = Trie<SymHop,N>()
    
    for node in nodes {
        let paths = node.paths
        for path in paths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
