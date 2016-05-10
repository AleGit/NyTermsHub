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
    
    func testPredefinedSymbols() {
        
        print(Process.info)
        
        let symbols = [
            (""     ,0),
            ("~"    ,1),
            ("|"    ,3),
            ("&"    ,5),
            ("-->"  ,7),
            (","    ,11),
            ("<=>"  ,13),
            ("=>"   ,17),
            ("<="   ,20),
            ("<~>"  ,23),
            ("~|"   ,27),
            ("~&"   ,30),
            ("!"    ,33),
            ("?"    ,35),
            ("="    ,37),
            ("!="   ,39),
            ("", 0)
        ]
        
        let table = PrlcTable(size: 0, path: "")
        
        XCTAssertEqual(42, table.symbolStoreSize)
        XCTAssertEqual(1024, table.store.memory.symbols.capacity)
        
        for (symbol,index) in symbols {
            XCTAssertEqual(index, table.indexOf(symbol: symbol),"\(symbol)")
        }
    }
    
    func testParsing() {
        
        let dividend = Process.relativeSpeed
        
        print(Process.info, dividend)
        
        for (name, timeLimit, expectedTreeSize, expectedInputs, expectedIncludes) in [
            ("PUZ001-1",    0.002   ,106    , 12,0), // 12
            ("PUZ051-1",    0.007   ,110    ,  3,1),  // 43 (1 inlc)
            
            ("SYN000-2",    0.003   ,145    , 18,1),          // 19 (1 incl)
            
            ("HWV001-1",    0.002   ,413        , 42,1),      // 47 (1 incl)
            ("HWV002-1",    0.002   ,436        , 51,0),      // 51
            
            ("HWV003-1",    0.014   ,474        , 42,1),  // 47 (1 incl)
            ("HWV003-2",    0.011   ,372        , 36,0),      // 36
            ("HWV003-3",    0.002   ,407        , 61,0),      // 61
            
            ("HWV004-1",    0.010   ,441        , 36,1),      // 41 (1 incl)
            
            ("HWV005-1",    0.004   ,65         , 10,2),      // 42 (2 incl)
            ("HWV005-2",    0.004   ,53         , 10,2),      // 42 (2 incl)
            
            ("HWV006-1",    0.008    ,123        , 16,3),      // 58 (3 incl)
            
            ("HWV007-1",    0.007    ,115        , 14,3),      // 56 (3 incl)
            ("HWV007-2",    0.006   ,95         , 14,3),      // 62 (3 incl)
            
            ("HWV008-1.001",0.008    ,181        , 18,3),      // 60 (3 incl)
            ("HWV008-1.002",0.010    ,288        , 26,3),      // 68 (3 incl)
            ("HWV008-2.001",0.007    ,134        , 18,3),      // 66 (3 incl)
            ("HWV008-2.002",0.009    ,210        , 26,3),      // 74 (3 incl)
            
            ("HWV009-1",    0.007    ,24         , 3,1),       // 92 (1 incl)
            
            ("HWV052-1.005.004",0.002,1812       , 52,0),      // 52
            ("HWV052-1.007.004",0.005,3874       , 86,0),      // 86
            
            ("HWV056-1",    1.2     ,1970598    , 9661,0),    // 9661
            ("HWV074-1",    0.152     ,241278     , 2581,0),    // 2581
            ("HWV076-1",    0.031     ,20830      , 1424,0),    // 1424
            ("HWV078-1",    0.012     ,10330      , 449,0),     // 449
            ("HWV080-1",    0.103     ,121264     , 1852,0),    // 1852
            ("HWV091-1",    1.99     ,1652994    , 125811,0),  // 125811
            ("HWV092-1",   11.1     ,9377099    , 696691,0),  // 696691
            ("HWV093-1",    0.051     ,30972      , 2652,0),    // 2652
            ("HWV098-1",    3.0     ,2378326    , 202745,0),  // 202745
            ("HWV106-1",    4.2     ,3381734    , 287949,0),  // 287949
            ("HWV107-1",    0.7     ,490794     , 40269,0),   // 40269
            ("HWV117-1",    0.4     ,228613     , 17625,0),   // 17625
            ("HWV124-1",    8.9     ,7098296    , 555949,0),  // 555949
            ("HWV134-1",36.9, 29_953_326, 2_332_428, 0)
            ] {
                guard let path = name.p else {
                    XCTFail("Did not find path for \(name)")
                    continue
                }
                
                
                print(name,path)
                let (pair,parseTime) = measure {
                    
                    prlcParse(path)
                }
                
                guard let table = pair.1 where pair.0 == 0 else {
                    XCTFail("\(name) \(path) was not parsed correctly: \(pair.0)")
                    continue
                }
                
                let c0 = table.treeStoreSize
                let c1 = table.tptpSequence.count { _ in true }
                let c2 = table.includes.count { _ in true }
                let c2x = table.tptpSequence.count { $0.memory.type == PRLC_INCLUDE }
                
                print(name,":",
                      parseTime.prettyTimeIntervalDescription,
                      "≤",timeLimit.prettyTimeIntervalDescription,
                      "•",c0,"≟",expectedTreeSize,
                      "-",c1,"≟",expectedInputs,
                      "+",c2,"≟",expectedIncludes)
                
                XCTAssertTrue(parseTime < (timeLimit/dividend), "\(name) \(parseTime.prettyTimeIntervalDescription)")
                XCTAssertEqual(expectedTreeSize, c0, "\(name)")
                XCTAssertEqual(expectedInputs, c1, "\(name)")
                XCTAssertEqual(expectedIncludes, c2, "\(name)")
                 XCTAssertEqual(c2x, c2, "\(name)")
                
                
                
                
        }
    }
    
}
