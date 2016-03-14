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

    func testPuz001() {
        for name in  [ "PUZ001-1", "HWV134-1"] {
        guard let path = name.p else {
            XCTFail("Did not find path for \(name)")
            continue
        }
        
        let (code,runtime) = measure {
         
            mereParse(path)
        }
        
        print("name", name, "code", code,"runtime",runtime.prettyTimeIntervalDescription)
        }
    }
}
