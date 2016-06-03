//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

/// Basic Usage
///
/// [yices.csl.sri.com/doc/basic-usage.html](http://yices.csl.sri.com/doc/basic-usage.html)
class YicesBasicTests: XCTestCase {

    /// Check installed yices version.
    func testYicesInfo() {
        let info = Yices.info
        
        for previous in ["2.4.0", "2.4.1"] {
            XCTAssertNil(info.rangeOfString(previous))
        }
        
        XCTAssertTrue(info.containsString("Yices"))
        XCTAssertTrue(info.containsString("2.4."))
        
        XCTAssertEqual("Yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)", info)
    }
}
