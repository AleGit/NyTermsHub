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
        for (name, timeLimit, expectedTreeSize, expectedFormulaCount) in [
            ("PUZ001-1",    0.002   ,106    , 12), // 12
            ("PUZ051-1",    0.007   ,110    ,  3),  // 43 (1 inlc)
            
            ("SYN000-2",    0.003   ,145    , 18),          // 19 (1 incl)
            
            ("HWV001-1",    0.002   ,413        , 42),      // 47 (1 incl)
            ("HWV002-1",    0.002   ,436        , 51),      // 51
            
            ("HWV003-1",    0.014   ,474, 42),  // 47 (1 incl)
            ("HWV003-2",    0.011     ,372        , 36),      // 36
            ("HWV003-3",    0.002   ,407        , 61),      // 61
            
            ("HWV004-1",    0.010   ,441        , 36),      // 41 (1 incl)
            
            ("HWV005-1",    0.004   ,65         , 10),      // 42 (2 incl)
            ("HWV005-2",    0.004   ,53         , 10),      // 42 (2 incl)
            
            ("HWV006-1",    0.008    ,123        , 16),      // 58 (3 incl)
            
            ("HWV007-1",    0.007    ,115        , 14),      // 56 (3 incl)
            ("HWV007-2",    0.006   ,95         , 14),      // 62 (3 incl)
            
            ("HWV008-1.001",0.008    ,181        , 18),      // 60 (3 incl)
            ("HWV008-1.002",0.010    ,288        , 26),      // 68 (3 incl)
            ("HWV008-2.001",0.007    ,134        , 18),      // 66 (3 incl)
            ("HWV008-2.002",0.009    ,210        , 26),      // 74 (3 incl)
            
            ("HWV009-1",    0.007    ,24         , 3),       // 92 (1 incl)
            
            ("HWV052-1.005.004",0.002,1812       , 52),      // 52
            ("HWV052-1.007.004",0.005,3874       , 86),      // 86
            
            ("HWV056-1",    1.2     ,1970598    , 9661),    // 9661
            ("HWV074-1",    0.152     ,241278     , 2581),    // 2581
            ("HWV076-1",    0.031     ,20830      , 1424),    // 1424
            ("HWV078-1",    0.012     ,10330      , 449),     // 449
            ("HWV080-1",    0.103     ,121264     , 1852),    // 1852
            ("HWV091-1",    1.99     ,1652994    , 125811),  // 125811
            ("HWV092-1",   11.1     ,9377099    , 696691),  // 696691
            ("HWV093-1",    0.051     ,30972      , 2652),    // 2652
            ("HWV098-1",    3.0     ,2378326    , 202745),  // 202745
            ("HWV106-1",    4.2     ,3381734    , 287949),  // 287949
            ("HWV107-1",    0.7     ,490794     , 40269),   // 40269
            ("HWV117-1",    0.4     ,228613     , 17625),   // 17625
            ("HWV124-1",    8.9     ,7098296    , 555949),  // 555949
            ("HWV134-1",36.9, 29_953_326, 2_332_428)
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
                
                print(name,":",parseTime.prettyTimeIntervalDescription,timeLimit.prettyTimeIntervalDescription,"•",c0,expectedTreeSize,"-",c1,expectedFormulaCount)
                
                XCTAssertTrue(parseTime < 2*timeLimit, "\(name) \(parseTime.prettyTimeIntervalDescription)")
                XCTAssertEqual(expectedTreeSize, c0)
                XCTAssertEqual(expectedFormulaCount, c1)
                
                
                
                
        }
    }
    
}
