//
//  DescriptionTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 12.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class DescriptionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
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
    
    func testSimpleDescriptions() {
        let X : TptpNode = "X"
        let a : TptpNode = "a"
        let faX = TptpNode(function:"f",nodes: [a,X])
        
        XCTAssertEqual(faX.tptpDescription, "f(a,X)")
        XCTAssertEqual(fax.laTeXDescription, "{\\mathsf f}({\\mathsf a},X)")
        print(fax.laTeXDescription)
    }

}
