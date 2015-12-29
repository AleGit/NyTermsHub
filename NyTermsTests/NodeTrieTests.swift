//
//  NodeTrieTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 29.12.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class NodeTrieTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSiPaths() {
        
        let t = "f(X,g(a,b))" as TestNode
        let tPaths = t.siPaths
        XCTAssertEqual(3, tPaths.count)
        
        let fxaExpected : [[Pair<String,Int>]] = [
            [Pair(left:"f",right:1), Pair(left:"",right:-1)],
            [Pair(left:"f",right:2), Pair(left:"g",right:1), Pair(left:"a",right:0)],
            [Pair(left:"f",right:2), Pair(left:"g",right:2), Pair(left:"b",right:0)]
        ]
        
        XCTAssertEqual(fxaExpected.first!, tPaths.first!)
        XCTAssertEqual(fxaExpected.last!, tPaths.last!)
        
        
        
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
