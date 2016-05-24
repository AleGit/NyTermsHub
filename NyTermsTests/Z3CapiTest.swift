//
//  Z3CapiTest.swift
//  NyTerms
//
//  Created by Alexander Maringele on 24.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest

class Z3CapiTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testZ3CapiMain() {
        z3_main()
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
