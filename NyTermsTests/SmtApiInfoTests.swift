//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

/// Basic Usage
///
/// [yices.csl.sri.com/doc/basic-usage.html](http://yices.csl.sri.com/doc/basic-usage.html)
class SmtApiInfoTests: XCTestCase {

    /// Check installed yices version.
    func testYicesInfo() {

        let info = Yices.info
        
        XCTAssertTrue(info.containsString("Yices"))
        XCTAssertTrue(info.containsString("2.4."))
        
        for previous in ["2.4.0", "2.4.1"] {
            XCTAssertNil(info.rangeOfString(previous))
        }
        
        XCTAssertEqual("Yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)", info)
    }
    
    func testZ3Info() {
        
        let info = Z3.info
        
        
        XCTAssertTrue(info.containsString("Z3 "))
        XCTAssertTrue(info.containsString(" 4.4."))
        
        for previous in ["4.4.1.0"] {
            XCTAssertNil(info.rangeOfString(previous))
        }
        
        XCTAssertEqual("Z3 4.4.2.0", info)

        
    }
}
