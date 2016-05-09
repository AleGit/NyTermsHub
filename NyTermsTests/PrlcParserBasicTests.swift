//
//  PrlcParserBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 06.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class PrlcParserBasicTests: XCTestCase {
    
    func testParsing() {
        for (name, timeLimit, expectedTreeSize, _) in [
            ("PUZ001-1",0.003, 106, 12),
            ("PUZ051-1", 1.0 ,110 ,0),
            
            ("SYN000-2",1.0,145, 0),
            
            ("HWV001-1",0.003, 413, 0),
            ("HWV002-1",0.003, 436, 0),
            
            ("HWV003-1",0.005, 474, 0),
            ("HWV003-2",0.005, 372, 0),
            ("HWV003-3",0.002, 407, 0),
            
            ("HWV004-1",0.005, 441, 0),
            
            ("HWV005-1",0.1, 65, 0),
            ("HWV005-2",0.002, 53, 0),
            
            ("HWV006-1",0.01, 123, 0),
            
            ("HWV007-1",0.1, 115, 0),
            ("HWV007-2",0.002, 95, 0),
            
            ("HWV008-1.001",0.01, 181, 0),
            ("HWV008-1.002",0.01, 288, 0),
            ("HWV008-2.001",0.01, 134, 0),
            ("HWV008-2.002",0.01, 210, 0),
            
            ("HWV009-1",0.01, 24, 0),
            
            ("HWV052-1.005.004",0.01,1812, 0),
            ("HWV052-1.007.004",0.01,3874, 0),
            
            ("HWV056-1",1.9,1970598, 0),
            ("HWV074-1",0.4,241278, 0),
            ("HWV076-1",0.1,20830, 0),
            ("HWV078-1",0.1,10330, 0),
            ("HWV080-1",0.2,121264, 0),
            ("HWV091-1",2.9,1652994, 0),
            ("HWV092-1",15.3,9377099, 0),
            ("HWV093-1",0.1,30972, 0),
            ("HWV098-1",3.9,2378326, 0),
            ("HWV106-1",4.9,3381734, 0),
            ("HWV107-1",1.0,490794, 0),
            ("HWV117-1",0.9,228613, 0),
            ("HWV124-1",9.9,7098296, 0),
            ("HWV134-1",45.6, 29_953_326, 2_332_428)
            ] {
                guard let path = name.p else {
                    XCTFail("Did not find path for \(name)")
                    continue
                }
                
                print(name,path)
                
                let (pair,parseTime) = measure {
                    
                    prlcParse(path)
                }
                
                XCTAssertTrue(parseTime < timeLimit,"\(name) \(parseTime)")
                
                let code = pair.0
                XCTAssertEqual(0, code, "\(code)")
                XCTAssertEqual(expectedTreeSize, pair.1?.treeStoreSize, "\(expectedTreeSize) \(pair.1?.treeStoreSize)")
                
                
                
                
        }
    }
    
}
