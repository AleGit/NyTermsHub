//
//  YicesCExamplesTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 03.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest

class YicesCExamplesTests: XCTestCase {

    /// [example1](file://Users/Shared/yices-2.4.1/examples/example1.c)
    func testExample1_c() {
        example1_main()
    }
    
    /// yices/examples/example2.c
    func testExample2_c() {
        example1_main()
    }
    
    /// yices/examples/example2.c
    func testExample2() {
        let (type,term,model) = example2()
        XCTAssertNotNil(type)
        XCTAssertNotNil(term)
        XCTAssertNotNil(model)
        
        XCTAssertEqual("real",type!)
        XCTAssertEqual("(< (* -1 X) 0)",term!)
        XCTAssertEqual("(= X 1)",model!)
    }
    
    /// yices/examples/minimal.c
    func testMinimal_c() {
        minimal_main()
    }
    
    /// yices/examples/names.c
    func testNames_c() {
        names_main()
    }
    
    /// yices/examples/test_pp.c
    func testTest_pp_c() {
        test_pp_main()
    }

}
