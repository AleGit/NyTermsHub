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
        for (name,limit,expectedTreeSize, numberOfClauses, expectedArrayTime) in  [
             ("PUZ001-1",0.003, 106, 12, 0.001),
//            ("PUZ051-1",1.0,110),
//            
//            ("SYN000-2",1.0,145),
//            
//            ("HWV001-1",0.003, 413),
//            ("HWV002-1",0.003, 436),
//            
//            ("HWV003-1",0.005, 474),
//            ("HWV003-2",0.005, 372),
//            ("HWV003-3",0.002, 407),
//            
//            ("HWV004-1",0.005, 441),
//            
//            ("HWV005-1",0.1, 65),
//            ("HWV005-2",0.002, 53),
//            
//            ("HWV006-1",0.01, 123),
//            
//            ("HWV007-1",0.1, 115),
//            ("HWV007-2",0.002, 95),
//            
//            ("HWV008-1.001",0.01, 181),
//            ("HWV008-1.002",0.01, 288),
//            ("HWV008-2.001",0.01, 134),
//            ("HWV008-2.002",0.01, 210),
//            
//            ("HWV009-1",0.01, 24),
//            
//            ("HWV052-1.005.004",0.01,1812),
//            ("HWV052-1.007.004",0.01,3874),
//            
//            ("HWV056-1",1.9,1970598),
//            ("HWV074-1",0.4,241278),
//            ("HWV076-1",0.1,20830),
//            ("HWV078-1",0.1,10330),
//            ("HWV080-1",0.2,121264),
//            ("HWV091-1",2.9,1652994),
//            ("HWV092-1",15.3,9377099),
//            ("HWV093-1",0.1,30972),
//            ("HWV098-1",3.9,2378326),
//            ("HWV106-1",4.9,3381734),
//            ("HWV107-1",1.0,490794),
//            ("HWV117-1",0.9,228613),
//            ("HWV124-1",9.9,7098296),
            
            ("HWV134-1",45.6, 29_953_326, 2_332_428, 5.1)
            ] {
                guard let path = name.p else {
                    XCTFail("Did not find path for \(name)")
                    continue
                }
                
                print(name,path)
                
                let (pair,parseTime) = measure {
                    
                    mereParse(path)
                }
                
                let code = pair.0
                print("'name:", name, "'code:", code,"'parse time:",parseTime.prettyTimeIntervalDescription, "'limit:", limit.prettyTimeIntervalDescription, "'tree store size:", pair.1?.treeSize)
                XCTAssertTrue(parseTime < limit, "\(parseTime.prettyTimeIntervalDescription) exceeds limit of \(limit.prettyTimeIntervalDescription) - \(name)")
                
                let table = pair.1!
                let treeStoreSize = table.treeSize
                XCTAssertEqual(expectedTreeSize, treeStoreSize, "\(name) \(treeStoreSize)")
                

                
                let (sequence, arrayTime) = measure {
                    Array(table.tptpSequence)
                }
                
                
                for s in sequence[0..<min(sequence.count,25)] {
                    print(s)
                }
                
                print("\(sequence.count) clauses in \(arrayTime.prettyTimeIntervalDescription).")
                
                XCTAssertEqual(sequence.count, numberOfClauses)
                XCTAssertTrue(arrayTime < expectedArrayTime,"\(arrayTime) ≰ \(expectedArrayTime)")
                
        }
    }
    
    func testDemoPUZ001Tree() {
        let path = "PUZ001-1".p!
        let pair = mereParse(path)
        XCTAssertEqual(0, pair.0)
        
        let table = pair.1!
        
//        for s in table.treeNodes {
//            print(s)
//        }
        
//        for s in table.children(0) {
//            print(s)
//        }
        
        let childs = table.children(0) {
            ($0.1, calmCopyTreeNodeData($0.0, $0.1))
        }
        for s in childs {
            print(s)
        }
        
//        for s in table.tptpSequence {
//            print(s)
//            for c in table.children(s) {
//                print("\t\t",c)
//            }
//        }
        
        
    }
}
