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
            ("PUZ001-1",0.1, 106), // > 1 ms
            // ("HWV134-1",49.9) // > 17.0 s
            ] {
                guard let path = name.p else {
                    XCTFail("Did not find path for \(name)")
                    continue
                }
                
                let (pair,runtime) = measure {
                    
                    mereParse(path)
                }
                
                let code = pair.0
                print("'name:", name, "'code:", code,"'runtime:",runtime.prettyTimeIntervalDescription, "'limit:", limit.prettyTimeIntervalDescription, "'tree store size:", pair.1?.treeSize)
                XCTAssertTrue(runtime < limit, "\(runtime.prettyTimeIntervalDescription) exceeds limit of \(limit.prettyTimeIntervalDescription)")
                
                let table = pair.1!
                let treeStoreSize = table.treeSize
                XCTAssertEqual(expectedTreeSize, treeStoreSize)
                
                for s in table.treeNodes {
                    print(s)
                }
                
                
                //    let value = calmGetTreeStoreSize(parsingTable);
                //
                //
                //    print(lastInput, value)
                //
                //    for i in 0..<value {
                //        print(i, String.fromCString(calmGetTreeNodeSymbol(parsingTable,i))!)
                //    }
                //
                //    #if DEBUG
                //
                //    var sid = calmNextSymbol(parsingTable, 0);
                //    while sid != 0 && sid < 300 {
                //        if sid > 160 {
                //            let string = String.fromCString( calmGetSymbol(parsingTable, sid) )
                //            print(sid,string)
                //        }
                //
                //        sid = calmNextSymbol(parsingTable, sid);
                //    }
                //    #endif
                
        }
    }
}
