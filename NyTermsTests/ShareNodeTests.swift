//
//  ShareNodeTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 22.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class ShareNodeTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testBottomUp() {
        let x0 = ShareNode(symbol: 0,children:nil)
        let x1 = ShareNode(symbol: 0,children:nil)
        let y = ShareNode(symbol: 1,children:nil)
        
        XCTAssertTrue (x0 === x1)
        XCTAssertFalse(x0 === y)
        
        XCTAssertEqual(0, x0.parents.count)
        XCTAssertEqual(0, x1.parents.count)
        XCTAssertEqual(0, y.parents.count)
        
        let fx0y = ShareNode(symbol:2,children:[x0,y])
        let fx1y = ShareNode(symbol:2,children:[x1,y])
        
        XCTAssertTrue (fx0y == fx1y)

        XCTAssertTrue (fx0y === fx1y)
        
        XCTAssertEqual(1, x0.parents.count)
        XCTAssertEqual(1, x1.parents.count)
        XCTAssertEqual(1, y.parents.count)
        
        XCTAssertTrue(x0.parents.contains(fx0y))
        XCTAssertTrue(x1.parents.contains(fx0y))
        XCTAssertTrue(y.parents.contains(fx0y))
        
        
    }
    
    
    
    func testTopDown() {
        
        let fx0y = ShareNode(symbol:2,children:[ShareNode(symbol: 0,children:nil),ShareNode(symbol: 1,children:nil)])
        let fx1y = ShareNode(symbol:2,children:[ShareNode(symbol: 0,children:nil),ShareNode(symbol: 1,children:nil)])
        
        XCTAssertTrue (fx0y === fx1y)

        let x0 = ShareNode(symbol: 0,children:nil)
        let x1 = ShareNode(symbol: 0,children:nil)
        let y = ShareNode(symbol: 1,children:nil)
        
        XCTAssertTrue (x0 === x1)
        XCTAssertFalse(x0 === y)
        
        XCTAssertTrue(x0.parents.contains(fx0y))
        XCTAssertTrue(x1.parents.contains(fx0y))
        XCTAssertTrue(y.parents.contains(fx0y))
        
        
    }
    
    func testClause() {
        let clause = "f(X,g(Y,X))=g(f(X,Y),h(f(Y,X)))|p(X,X)" as TptpNode
        let (a,b) = ShareNode.insert(clause,belowPredicate: false)
        
        print(a)
        for (c,d) in b {
            print(c,d)
        }
        
        print(ShareNode.s2i)
        let x = ShareNode.i2s.map {
            ($0, $1.0,
                $1.type,$1.category,$1.notation,$1.arity) }.sort { $0.0.0 < $0.1.0 }
        for s in x {
            print(s)
        }
    }
    
    func testHWV134() {
        let path = "HWV134-1".p!
        
        let (clauses,parsingTime) = measure {
            return TptpNode.roots(path)
        }
        
        print("parsed",parsingTime.prettyTimeIntervalDescription)
        
        let start =  CFAbsoluteTimeGetCurrent()
        var last = start
        
        let (_, convertingTime) = measure {
        
        for (index,clause) in clauses.enumerate() {
            
            let (a,b) = ShareNode.insert(clause, belowPredicate:false)
            if index % 10000 == 0 {
                let now = CFAbsoluteTimeGetCurrent()
                print(index, (now-start).prettyTimeIntervalDescription, (now-last).prettyTimeIntervalDescription)
                print(clause)
                print(a)
                print(b)
                last = now
            }
        }
        }
        
        print("converted", (convertingTime).prettyTimeIntervalDescription)
    
    }

}
