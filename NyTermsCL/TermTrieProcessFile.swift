//
//  File.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func extract<T>(trie:TrieStruct<SymHop, T>, path:SymHopPath) -> Set<T>? {
    guard let (head,tail) = path.decompose else {
        return trie.payload
    }
    
    switch head {
    case .Hop(_):
        guard let subtrie = trie[head] else { return nil }
        return extract(subtrie, path: tail)
    case .Symbol("*"):
        // collect everything
        return Set(trie.subtries.flatMap { $0.1.payload })
        
    default:
        // collect variable and exact match
        
        let variables = trie[.Symbol("*")]?.payload
        
        guard let exactly = trie[head] else {
            return variables
        }
        
        guard var payload = extract(exactly, path:tail) else {
            return variables
        }
        
        
        if variables != nil {
            payload.unionInPlace(variables!)
        }
        return payload
        
        
        
        
    }
    
    
}

func candidates<T:Hashable>(indexed:TrieStruct<SymHop, T>, term:TptpNode) -> Set<T>? {
    var queryTerm : TptpNode
    switch term.symbol {
    case "~":
        queryTerm = term.nodes!.first!
    case "!=":
        queryTerm = TptpNode(symbol: "=", nodes: term.nodes)
    case "=":
        queryTerm = TptpNode(symbol: "!=", nodes: term.nodes)
        
        
    default:
        queryTerm = TptpNode(symbol: "~", nodes: [term])
    }
    
    
    guard let (first,tail) = queryTerm.symHopPaths.decompose else { return nil }
    
    guard var result = extract(indexed, path: first) else { return nil }
    
    for path in tail {
        guard let next = extract(indexed, path:path) else { return nil }
        result.intersectInPlace(next)
    }
    
    
    return result
}

func trieSearch(literals:[TptpNode]) -> (Int,String) {
    let step = 1000
    
    var count = 0
    var stepcount = count
    
    var trie = TrieStruct<SymHop,TptpNode>()
    
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    for newLiteral in literals {
        if let candis = candidates(trie, term:newLiteral) {
            for oldLiteral in candis  {
                if ((newLiteral ~?= oldLiteral) != nil) {
                    count++
                }
            }
        }
        
        for path in newLiteral.symHopPaths {
            trie.insert(path, value: newLiteral)
            
        }
        processed += 1
        
        if processed % step == 0 {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            temp = now
            stepcount = count
        }
    }
    
    
    return (count,"index search")
}