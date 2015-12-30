//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

enum SymPos : Hashable, CustomStringConvertible {
    case Symbol(String)
    case Position(Int)
    
    var hashValue : Int {
        switch self {
        case let .Symbol(symbol):
            return symbol.hashValue
        case let .Position(position):
            return position.hashValue
        }
    }
}

extension SymPos {
    var description : String {
        switch self {
        case let .Symbol(symbol):
            return symbol
        case let .Position(position):
            return "\(position)"
        }
    }
}

//extension Array where Element : SymPos {
//    var description : String {
//        self.joinWithSeparator(".")
//    }
//}

func ==(lhs:SymPos, rhs:SymPos) -> Bool {
    switch(lhs,rhs) {
    case let (.Symbol(lsymbol), .Symbol(rsymbol)):
        return lsymbol == rsymbol
    case let (.Position(lpos), .Position(rpos)):
        return lpos == rpos
    default:
        return false
    }
}

typealias TermPath = [SymPos]



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
        
        var paths = [[SymPos]]()
        
        for (index,subpaths) in (nodes.map { $0.paths }).enumerate() {
            for subpath in subpaths {
                paths.append([.Symbol(self.symbol), .Position(index+1)] + subpath)
            }
        }
        return paths
    }
}




func buildNodeTrie<N:Node>(nodes:[N]) -> Trie<SymPos, N> {
    var trie = Trie<SymPos,N>()
    
    for node in nodes {
        let paths = node.paths
        for path in paths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
