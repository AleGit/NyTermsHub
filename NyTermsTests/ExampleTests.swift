//
//  ExampleTests.swift
//  NyTerms
//
//  Created by Sarah Winkler on 03/09/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest

class ExampleTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        let t = "f(X)=g(X,Y)" as TermSampleClass
        
        XCTAssertEqual("f(X)=g(X,Y)", t.description)
        XCTAssertFalse(t.isRewriteTree)
    }
    
}
