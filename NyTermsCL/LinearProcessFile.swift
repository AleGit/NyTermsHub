//
//  LinearProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation


func linearSearch<N:Node>(literals:[N]) -> (Int,String) {
    let step = 1000
    var count = 0
    var stepcount = count
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    var processed = 0
    let message = "search trie type: \(__FUNCTION__)"
    
    print("\t"+message)
    
    for newLiteral in literals {
        for oldLiteral in literals[0..<processed] {
            if ((newLiteral ~?= oldLiteral) != nil) {
                count += 1
            }
        }
        processed += 1
        
        if processed % step == 0 {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(step)) processed in",
                "(\(total.timeIntervalDescriptionMarkedWithUnits),\(round.timeIntervalDescriptionMarkedWithUnits))",
                "(\((total/Double(processed)).timeIntervalDescriptionMarkedWithUnits), \((round/Double(step)).timeIntervalDescriptionMarkedWithUnits))",
                "(\(count),\(count-stepcount)) complementaries")
            
            temp = now
            stepcount = count
        }
    }
    
    
    return (count, message)
    
}