//
//  LinearProcessFile.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

func linearSearch(literals:[TptpNode]) -> (Int,String) {
    let step = 1000
    
    var count = 0
    var stepcount = count
    
    var processed = 0
    
    let start = CFAbsoluteTimeGetCurrent()
    var temp = start
    
    for newLiteral in literals {
        for oldLiteral in literals[0..<processed] {
            if ((newLiteral ~?= oldLiteral) != nil) {
                count++
            }
        }
        processed++
        
        if processed % step == 0 {
            let now = CFAbsoluteTimeGetCurrent()
            let total = now - start
            let round = now - temp
            
            print("\t(\(processed),\(step)) processed in (\(Int(total))s, \(Int(round))s) (\(desc(total,processed)),\(desc(round,step)))",
                "\(count,count-stepcount) complementaries. ")
            temp = now
            stepcount = count
        }
    }
    
    
    return (count, "linear search")
    
}