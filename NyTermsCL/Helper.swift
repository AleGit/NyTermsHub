//
//  Helper.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let units = ["s", "ms", "ns"]

func desc(time: CFAbsoluteTime, _ count :Int) -> String {
    
    
    var result = time / Double(count)
    var count = 0
    while result < 1.0 {
        count++
        result *= 1000
    }
    
    return "\(Int(0.5+result))\(units[count])"
    
}
