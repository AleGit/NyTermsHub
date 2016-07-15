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
        
        XCTAssertTrue(info.contains("Yices"))
        XCTAssertTrue(info.contains("2.4."))
        
        for previous in ["2.4.0", "2.4.1"] {
            XCTAssertNil(info.range(of: previous))
        }
        
        XCTAssertEqual("Yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)", info)
    }
    
    func testZ3Info() {
        
        let info = Z3.info
        
        
        XCTAssertTrue(info.contains("Z3 "))
        XCTAssertTrue(info.contains(" 4.4."))
        
        for previous in ["4.4.2.0"] {
            XCTAssertNil(info.range(of: previous))
        }
        
        XCTAssertEqual("Z3 4.4.2.1", info)

        
    }
}
