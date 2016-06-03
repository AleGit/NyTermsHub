//
//  Z3BasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 03.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class Z3BasicTests: XCTestCase {

    /// Check installed Z3 version.
    func testZ3Info() {
        let info = Z3.info
        
        for previous in [ "4.4.1" ] {
            XCTAssertNil(info.rangeOfString(previous))
        }
        
        XCTAssertTrue(info.containsString("Z3"))
        XCTAssertTrue(info.containsString("4.4."))
        
        XCTAssertEqual("Z3 v4.4.2.0", info) // 2016-06-03
    }
}
