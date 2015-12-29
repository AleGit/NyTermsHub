//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

// typealias SiPath = [Pair<String,Int>]

extension Node {
    
    var siPaths : [[Pair<String,Int>]] {
        guard let nodes = self.nodes else {
            return [[Pair(left: "",right: -1)]]
        }
        
        guard nodes.count > 0 else {
            return [[Pair(left: self.symbol,right: 0)]]
        }
        
        var paths = [[Pair<String,Int>]]()
        
        for (index,ps) in (nodes.map { $0.siPaths }).enumerate() {
            let pair = Pair(left:self.symbol, right:index+1)
            
            for var path in ps {
                path.insert(pair, atIndex: 0)
                paths.append(path)
            }
            
        }
        
        return paths
    }
    
}

func buildNodeTrie<N:Node>(nodes:[N]) -> Trie<Pair<String,Int>, N> {
    var trie = Trie<Pair<String,Int>,N>()
    
    for node in nodes {
        let paths = node.siPaths
        for path in paths {
            trie.insert(path, value: node)
        }
    }
    
    return trie
}
