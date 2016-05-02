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
        for (name,limit,expectedTreeSize) in  [
//            ("PUZ001-1",0.003, 106), // ~ 1 ms
//            ("HWV001-1",0.003, 412),
//            ("HWV002-1",0.003, 436),
//            ("HWV003-1",0.005, 473),
//            ("HWV003-2",0.005, 372),
//            ("HWV003-3",0.001, 407),
//            ("HWV004-1",0.005, 440),
            
//             ("HWV005-1",0.1, 66), // +2 ()
            ("HWV005-2",0.002, 53), // +2 ()
            ("HWV006-1",0.01, 123), // +3 ()
            ("HWV007-1",0.1, 115), // +3 ()
            ("HWV007-2",0.002, 95), // +3 ()
            ("HWV008-1.001",0.01, 181), // +3 ()
            ("HWV008-1.002",0.01, 288), // +3 ()
            ("HWV008-2.001",0.01, 134), // +3 ()
            ("HWV008-2.002",0.01, 210), // +3 ()
            ("HWV009-1",0.01, 24), // +3 ()
//            ("HWV052-1.005.004",0.01,1812),
//            ("HWV052-1.007.004",0.01,3874),
//            ("HWV078-1",0.1,10330),
//            ("HWV076-1",0.1,20830),
//            ("HWV093-1",0.1,30972),
//            ("HWV080-1",0.1,121264),
//            ("HWV074-1",0.4,241278),
//            ("HWV117-1",0.9,228613),
//            ("HWV107-1",1.0,490794),
//             ("HWV056-1",1.9,1970598),
//            ("HWV091-1",2.9,1652994),
//             ("HWV098-1",3.9,2378326),
//            ("HWV106-1",4.9,3381734),
//            ("HWV124-1",9.9,7098296),
//            ("HWV092-1",12.3,9377099),
//
//            ("HWV134-1",45.6, 29953326) // > 17.0 s
            ] {
                guard let path = name.p else {
                    XCTFail("Did not find path for \(name)")
                    continue
                }
                
                print(name,path)
                
                let (pair,runtime) = measure {
                    
                    mereParse(path)
                }
                
                let code = pair.0
                print("'name:", name, "'code:", code,"'runtime:",runtime.prettyTimeIntervalDescription, "'limit:", limit.prettyTimeIntervalDescription, "'tree store size:", pair.1?.treeSize)
                XCTAssertTrue(runtime < limit, "\(runtime.prettyTimeIntervalDescription) exceeds limit of \(limit.prettyTimeIntervalDescription)")
                
                let table = pair.1!
                let treeStoreSize = table.treeSize
                XCTAssertEqual(expectedTreeSize, treeStoreSize, "\(name) \(treeStoreSize)")
                
                let array = table.treeNodes.filter {
                    $0.type < 5
                }
                var count = 0;
                
                
                for s in array {
                    count += 1;
                    guard count < 15 else { break }
                    print(s)
                }
                
        }
    }
}
