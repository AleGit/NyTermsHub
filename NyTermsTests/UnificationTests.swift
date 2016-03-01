//
//  UnificationTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 29.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class UnificationTests: XCTestCase {
    
    func testComplementaries() {
        let name = "PUZ001-1"
        guard let path = name.p else {
            XCTFail("\(name) is not accessible")
            return
        }
        
        let literals = TptpNode.literals(path)
        print("# of literals:",literals.count)
        
        let step = min(literals.count/4,1000)
        
        var count = 0
        
        for (indexA,literalA) in literals.enumerate() {
            for (indexB,literalB) in literals[0..<indexA].enumerate() {
                let mgu = (literalA ~?= literalB)
                if mgu != nil {
                    count++
                    
                    if count % step == 0 {
                        print(indexA,indexB,count)
                    }
                }
            }
            
        }
        print(count)
        
        
    }
    
}
