//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

/// Basic Usage
///
/// [yices.csl.sri.com/doc/basic-usage.html](http://yices.csl.sri.com/doc/basic-usage.html)
class YicesBasicTests: XCTestCase {

    /// Check installed version.
    func testYicesInfo() {
        XCTAssertNotEqual("yices 2.4.0 (x86_64-apple-darwin14.4.0,release,2015-07-29)", Yices.info)
        XCTAssertNotEqual("yices 2.4.1 (x86_64-apple-darwin14.4.0,release,2015-08-10)", Yices.info)
        
        
        
        XCTAssertEqual("yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)", Yices.info)
        
        
    }
    
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
