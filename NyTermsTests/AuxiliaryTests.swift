//
//  AuxiliaryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 27.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//


import XCTest
@testable
import NyTerms

class AuxiliaryTests: XCTestCase {

    func testIntegerIntersection() {
        func set(start:Int, _ factor:Int, _ size:Int) -> Set<Int> {
            var set = Set<Int>()
            var element = start
            for _ in 0..<size {
                set.insert(element)
                element+=factor
                set.insert(element)
            }
            return set
        }
        
        
        
        let n = 30
        let factor = 2
        var size = 1
        for i in 0..<n {
            
            
            let first = set(3,5,size)
            size *= factor
            let second = set (5,7,size)
            
            
            
            let (third,runtime) = measure {
                first.intersect(second)
            }
            
            
            
            
            print(
                "\(i) of \(n):",
                "\(size/factor),\(size)",
                runtime,
                (runtime)/Double(size),
                third.count,
                Double(third.count)/Double(size/factor))
            
            
        }
    }
}
