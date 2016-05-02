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
            ("PUZ001-1",0.1), // > 1 ms
            // ("HWV134-1",49.9) // > 17.0 s
            ] {
        guard let path = name.p else {
            XCTFail("Did not find path for \(name)")
            continue
        }
        
        let (pair,runtime) = measure {
         
            mereParse(path)
        }
                
             
            
            XCTAssertTrue(runtime < limit, "\(runtime.prettyTimeIntervalDescription) exceeds limit of \(limit.prettyTimeIntervalDescription)")
                
                let (code,_) = pair
        
            print("name:", name, "code:", code,"runtime:",runtime.prettyTimeIntervalDescription, "< limit:", limit.prettyTimeIntervalDescription)
                
                //    let value = calmGetTreeNodeSize(parsingTable);
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
