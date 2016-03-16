//
//  LinearProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


func linearSearch<N:Node where N.Symbol==String>(literals:[N]) -> (Int,String) {
    let step = min(1000,literals.count/5)
    var count = 0
    var stepcount = count
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    var last = processed
    let message = "search trie type: \(__FUNCTION__)"
    
    print("\t"+message)
    
    processed = 0
    
    for newLiteral in literals[processed..<literals.count] {
        for oldLiteral in literals[0..<processed] {
            if ((newLiteral ~?= oldLiteral) != nil) {
                count += 1
            }
        }
        processed += 1
        
        if processed % step == 0 || processed == literals.count {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(processed-last)) processed in",
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