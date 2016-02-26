//
//  TptpPathTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class TptpPathTests: XCTestCase {

    func testTptpRootPath() {
        let expected = "/Users/Shared/TPTP"
        let actual = TptpPath.tptpRootPath
        XCTAssertEqual(expected, actual,"arbitrary root paths are not supported yet.")
    }
    
    func testP() {
        XCTAssertNotNil("HWV001-1".p)
        XCTAssertNil("HWV999-9".p)
    }

}
