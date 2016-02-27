//
//  TrieProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 27.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

extension TrieType where Value:Hashable {
    var payload : Set<Value> {
        guard let vals = values else { return Set<Value>() }
        return Set(vals)
    }
    
}

func extract<T:TrieType where T.Key==SymHop, T.Value:Hashable>(trie:T, path:SymHopPath) -> Set<T.Value>? {
    guard let (head,tail) = path.decompose else {
        return trie.payload
    }
    
    switch head {
    case .Hop(_):
        guard let subtrie = trie[head] else { return nil }
        return extract(subtrie, path:tail)
    case .Symbol("*"):
        // collect everything
        return Set(trie.tries.flatMap { $0.payload })
        
    default:
        // collect variable and exeact match
        
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

func candidates<T:TrieType, N:Node where T.Key==SymHop, T.Value:Hashable>(indexed:T, term:N) -> Set<T.Value>? {
    var queryTerm: N
    switch term.symbol {
    case "~":
        queryTerm = term.nodes!.first!
    case "!=":
        queryTerm = N(symbol: "=", nodes: term.nodes)
    case "=":
        queryTerm = N(symbol:"!=", nodes: term.nodes)
    default:
        queryTerm = N(symbol:"~", nodes: [term])
    }
    
    guard let (first,tail) = queryTerm.symHopPaths.decompose else { return nil }
    
    guard var result = extract(indexed, path: first) else { return nil }
    
    for path in tail {
        guard let next = extract(indexed, path:path) else { return nil }
        result.intersectInPlace(next)
    }
    return result
    
}

