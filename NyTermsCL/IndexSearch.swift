//
//  TrieProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 27.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let fastestSearch = {
    (literals :[TptpNode]) -> (Int,String) in
    return trieSearch(TrieClass<SymHop,Int>(), literals:literals)
}

let fasterSearch = {
    (literals :[TptpNode]) -> (Int,String) in
    return trieSearch(TrieStruct<SymHop,Int>(), literals:literals)
}

let fastSearch = {
    (literals :[TptpNode]) -> (Int,String) in
    return trieSearch(TailTrie<SymHop,Int>(), literals:literals)
}

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

func trieSearch<T:TrieType, N:Node where T.Key==SymHop, T.Value==Int>(trieRoot:T, literals:[N]) -> (Int, String) {
    let step = min(1000,literals.count/5)
    var count = 0
    var stepcount = count
    var trie = trieRoot
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    var last = processed
    
    let message = "search trie type: \(T.self) \(__FUNCTION__)"
    
    print("\t"+message)
    
    for (newIndex, newLiteral) in literals.enumerate() {
        if let candis = candidates(trie, term:newLiteral) {
                        for oldIndex in candis {
                            let oldLiteral = literals[oldIndex]
                            if ((newLiteral ~?= oldLiteral) != nil) {
                                count++  // count wiht check
                            }
                        }
            // count += candis.count // count without unifiable check
        }
        for path in newLiteral.symHopPaths {
            trie.insert(path, value: newIndex)
        }
        processed += 1
        
        if processed % step == 0 || processed == literals.count {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(processed-last))) processed in",
                "(\(total.timeIntervalDescriptionMarkedWithUnits),\(round.timeIntervalDescriptionMarkedWithUnits))",
                "(\((total/Double(processed)).timeIntervalDescriptionMarkedWithUnits), \((round/Double(processed-last)).timeIntervalDescriptionMarkedWithUnits))",
                "(\(count),\(count-stepcount)) complementaries")
            
            temp = now
            stepcount = count
            last = processed
        }
    }
    
    return (count, message)
}





