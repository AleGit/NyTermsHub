//
//  AuxiliaryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 02.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class AuxiliaryTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    let list = [0,1,42,Int(Int8.max),Int(Int16.max),Int(Int32.max)]
    
    func testPositiveIndicesOnly() {
        
        
        for (cidx,lidx) in list * list {
            let pair = (cidx,lidx)
            let encoded = Int(first:cidx, second:lidx)
            let decoded = (encoded.first,encoded.second)
            
            XCTAssertTrue((cidx,lidx)==decoded, "\(pair) ≠ \(decoded)")
        }
    }
    
    func testNegativeIndicesToo() {
        let nlist = list + list.map { -$0 } + [Int(Int8.min),Int(Int16.min),Int(Int32.min)]
        for (cidx,lidx) in nlist * nlist {
            let pair = (cidx,lidx)
            let encoded = Int(first:cidx, second:lidx)
            let decoded = (encoded.first,encoded.second)
            
            XCTAssertTrue((cidx,lidx)==decoded, "\(pair) ≠ \(decoded)")
        }
    }
}
