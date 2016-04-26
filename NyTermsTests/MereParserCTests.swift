//
//  MereParserCTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class MereParserCTests: XCTestCase {
    
    func testMereStoreString() {
        let total = 2_000_000
        let (_,runtime) = measure {
            XCTAssertTrue(mere_parser_init(total))
            defer {
                mere_parser_exit()
            }
            let a = "1234567890"
            
            let strings = (1...2_000_000).map { (_) -> (SID,String) in
                let sid = mere_store_string(a, 10);
                let cstring = mere_retrieve_string(sid)
                return (sid, String.fromCString(cstring)!)
            }
            
            print(strings.count, strings[92..<94])
            
            let entries = strings.map { (sid,_) -> EID in
                let entry = mere_entry_create(sid)
                
                return entry
            }
            
            print(entries.count, entries[100...122])
        }
        
        print(runtime)
        
        
        
    }
    
}
