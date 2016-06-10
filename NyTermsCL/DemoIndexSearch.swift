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
    return trieSearch(TrieClass<SymHop<String>,Int>(), literals:literals)
}

let fasterSearch = {
    (literals :[TptpNode]) -> (Int,String) in
    return trieSearch(TrieStruct<SymHop<String>,Int>(), literals:literals)
}

let fastSearch = {
    (literals :[TptpNode]) -> (Int,String) in
    return trieSearch(TailTrie<SymHop<String>,Int>(), literals:literals)
}

let checkunifiability = false


/// finds all complementary variants only
func yicesSearch(literals:[TptpNode]) -> (Int,String) {
    let step = min(1000,literals.count/5)
    var count = 0
    var stepcount = count
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    var last = processed
    
    let message = "search:  \(#function)"
    
    print("\t"+message)
    
    var literalIndicesByYicesLiteral = [term_t:Set<Int>]()
    
    for (newIndex, newLiteral) in literals.enumerate() {
        
        let newYicesLiteral = Yices.literal(newLiteral)
        let negatedLiteral = yices_not(newYicesLiteral)
        
        print(Yices.info(term:newYicesLiteral)!, Yices.info(term:negatedLiteral)!)
        
        if let candis = literalIndicesByYicesLiteral[negatedLiteral] {
            if checkunifiability {
                for oldIndex in candis {
                    let oldLiteral = literals[oldIndex]
                    if ((newLiteral ~?= oldLiteral) != nil) {
                        count += 1  // count with unifiable check
                    }
                }
            }
            else {
                count += candis.count // count without unifiable check
            }
        }
        
        // insert into index
        if literalIndicesByYicesLiteral[newYicesLiteral] == nil {
            literalIndicesByYicesLiteral[newYicesLiteral] = Set<Int>()
        }
        literalIndicesByYicesLiteral[newYicesLiteral]?.insert(newIndex)
        processed += 1
        
        if processed % step == 0 || processed == literals.count {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(processed-last))) processed in",
                  "(\(total.prettyTimeIntervalDescription),\(round.prettyTimeIntervalDescription))",
                  "(\((total/Double(processed)).prettyTimeIntervalDescription), \((round/Double(processed-last)).prettyTimeIntervalDescription))",
                  "(\(count),\(count-stepcount)) complementaries")
            
            temp = now
            stepcount = count
            last = processed
        }
    }
    
    return (count, message)
}



func trieSearch<T:TrieType, N:Node where T.Key==SymHop<N.Symbol>, T.Value==Int, N.Symbol==String>(trieRoot:T, literals:[N]) -> (Int, String) {
    let step = min(1000,literals.count/5)
    var count = 0
    var stepcount = count
    var trie = trieRoot
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    var last = processed
    
    let message = "search trie type: \(T.self) \(#function)"
    
    print("\t"+message)
    
    for (newIndex, newLiteral) in literals.enumerate() {
        if let candis = candidateComplementaries(trie, term:newLiteral) {
            if checkunifiability {
                for oldIndex in candis {
                    let oldLiteral = literals[oldIndex]
                    if ((newLiteral ~?= oldLiteral) != nil) {
                        count += 1  // count with unifiable check
                    }
                }
            }
            else {
                count += candis.count // count without unifiable check
            }

        }
        
        // insert into index
        for path in newLiteral.paths {
            trie.insert(path, value: newIndex)
        }
        processed += 1
        
        if processed % step == 0 || processed == literals.count {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(processed-last))) processed in",
                  "(\(total.prettyTimeIntervalDescription),\(round.prettyTimeIntervalDescription))",
                  "(\((total/Double(processed)).prettyTimeIntervalDescription), \((round/Double(processed-last)).prettyTimeIntervalDescription))",
                  "(\(count),\(count-stepcount)) complementaries")
            
            temp = now
            stepcount = count
            last = processed
        }
    }
    
    return (count, message)
}





