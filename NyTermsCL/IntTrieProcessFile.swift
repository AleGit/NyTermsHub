//
//  IntTrieProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation



func intTrieSearch(literals:[TptpNode]) -> (Int, String) {
    let step = 1000
    var count = 0
    var stepcount = count
    var trie = TrieStruct<SymHop,Int>()
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    for (newIndex, newLiteral) in literals.enumerate() {
        if let candis = candidates(trie, term:newLiteral) {
            /*
            for oldIndex in candis {
                let oldLiteral = literals[oldIndex]
                if ((newLiteral ~?= oldLiteral) != nil) {
                    count++ // count without check
                }
            }
*/
            count += candis.count // count without unifiable check
        }
        for path in newLiteral.symHopPaths {
            trie.insert(path, value: newIndex)
            
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
    
    return (count,"int index search")
}