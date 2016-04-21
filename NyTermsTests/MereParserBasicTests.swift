//
//  MereParserBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class MereParserBasicTests: XCTestCase {

    func testParsing() {
        for (name,limit) in  [
            ("PUZ001-1",0.005),
            ("HWV134-1",17.0)
            ] {
        guard let path = name.p else {
            XCTFail("Did not find path for \(name)")
            continue
        }
        
        let (code,runtime) = measure {
         
            mereParse(path)
        }
            
            XCTAssertTrue(runtime < limit, "\(runtime.prettyTimeIntervalDescription) exceeds limit of \(limit.prettyTimeIntervalDescription)")
        
            print("name:", name, "code:", code,"runtime:",runtime.prettyTimeIntervalDescription, "< limit:", limit.prettyTimeIntervalDescription)
        }
    }
}
