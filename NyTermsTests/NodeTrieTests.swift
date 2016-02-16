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
    
    func testSymHopPaths() {
        
        let t = "f(X,g(a,b))" as TestNode
        let tPaths = t.symHopPaths
        XCTAssertEqual(3, tPaths.count)
        
        let fxaExpected : [SymHopPath] = [
            [.Symbol("f"),.Hop(0), .Symbol("*")],
            [.Symbol("f"),.Hop(1), .Symbol("g"),.Hop(0), .Symbol("a")],
            [.Symbol("f"),.Hop(1), .Symbol("g"),.Hop(1), .Symbol("b")]
        ]
        
        XCTAssertEqual(fxaExpected.first!, tPaths.first!)
        XCTAssertEqual(fxaExpected.last!, tPaths.last!)
    }
    
    
    
    func testTriePuz001m1() {
        let path = "PUZ001-1".p
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        
        let clauses = tptpFormulae.map { $0.root }
        
        let trie = buildNodeTrie(clauses)
        
        XCTAssertEqual(12, trie.payload.count)
        
        for clause in clauses {
            print("clause=\(clause)")
            
            for path in clause.symHopPaths {
                print("path=\(path)")
                let subtrie = trie[path]!
                let values = subtrie.values
                let payload = subtrie.payload
                XCTAssertTrue(payload.isSupersetOf(values))
                print("values=\(values)")
                
                if (payload.isStrictSupersetOf(values)) {
                    print("payload=\(payload.subtract(values))")
                }
                
                XCTAssertTrue(values.contains(clause))
                XCTAssertTrue(payload.contains(clause))
                print("")
            }
            print("")
        }
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
