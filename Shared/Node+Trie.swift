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
    
    private func paths<T>(sym2t:Symbol->T,_ hop2t:Int->T) -> [[T]] {
        guard let nodes = self.nodes else {
            // a variable
            return [ [sym2t(Self.starSign)] ]
        }
        
        guard nodes.count > 0 else {
            // a constant
            return [[sym2t(self.symbol)]]
        }
        
        var paths = [[T]]()
        
        for (index,subpaths) in (nodes.map { $0.paths(sym2t,hop2t) }).enumerate() {
            for subpath in subpaths {
                paths.append([sym2t(self.symbol), hop2t(index)] + subpath)
            }
        }
        return paths
    }
    
    var stringPaths : [[String]] {
        let sym2t : Symbol -> String = { "\($0)" }
        let hop2t : Int -> String = { "\($0)" }
        
        return self.paths(sym2t,hop2t)
    }
    
    var symHopPaths : [[SymHop<Symbol>]] {
        
        let sym2t : Symbol -> SymHop<Symbol> = { SymHop.Symbol($0) }
        let hop2t : Int -> SymHop<Symbol> = { SymHop.Hop($0) }
        
        return self.paths(sym2t,hop2t)
        
//        guard let nodes = self.nodes else {
//            // a variable
//            return [ [.Symbol(Self.starSign())] ]
//        }
//        
//        guard nodes.count > 0 else {
//            // a constant
//            return [[.Symbol(self.symbol)]]
//        }
//        
//        var symHopPaths = [[SymHop<Symbol>]]()
//        
//        for (index,subpaths) in (nodes.map { $0.symHopPaths }).enumerate() {
//            for subpath in subpaths {
//                symHopPaths.append([.Symbol(self.symbol), .Hop(index)] + subpath)
//            }
//        }
//        return symHopPaths
    }
}

extension Node where Symbol == String {
    typealias SymHopPath = [SymHop<String>]
    typealias SymbolPath = [StringSymbol]
    
//    var symHopPaths : [SymHopPath] {
//        guard let nodes = self.nodes else {
//            // a variable
//            return [[.Symbol("*")]]
//        }
//        
//        guard nodes.count > 0 else {
//            // a constant
//            return [[.Symbol(self.symbol)]]
//        }
//        
//        var symHopPaths = [SymHopPath]()
//        
//        for (index,subpaths) in (nodes.map { $0.symHopPaths }).enumerate() {
//            for subpath in subpaths {
//                symHopPaths.append([.Symbol(self.symbol), .Hop(index)] + subpath)
//            }
//        }
//        return symHopPaths
//    }
    
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

func buildNodeTrie<N:Node>(nodes:[N]) -> TrieStruct<SymHop<N.Symbol>, N> {
    var trie = TrieStruct<SymHop<N.Symbol>,N>()
    
    for node in nodes {
        let symHopPaths = node.symHopPaths
        for path in symHopPaths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
