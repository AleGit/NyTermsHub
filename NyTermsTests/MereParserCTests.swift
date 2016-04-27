//
//  MereParserCTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class MereParserDataTests: XCTestCase {
    
    let total = 52_000// _000
    let a = ["", "1234567890","ABCDEFGHIJ","abcde67890", "1234", "⦿🍻", "ABC", "abcde"]
    
    func testMereStringStore() {
        XCTAssertTrue(mere_parser_init(total*2))
        defer {
            mere_parser_exit()
        }
        
        let (_,runtime) = measure {
            
            let strings = (1...self.total).map { (i) -> (SID,String,UInt) in
            
                let sid = mere_string_store(self.a[i % self.a.count])
                let cstring = mere_string_retrieve(sid)
                return (sid, String.fromCString(cstring)!, strlen(cstring))
            }
            
            print(strings[0..<(self.a.count*3)])
        }
        
        print(runtime.prettyTimeIntervalDescription)
        
        
        
    }
    
//    func testMereStringCreate() {
//        XCTAssertTrue(mere_parser_init(self.total*12))
//        defer {
//            mere_parser_exit()
//        }
//        let (_,runtime) = measure {
//            let strings = (1...self.total).map { (i) -> (SID,String) in
//                let sid = mere_string_create(self.a[i % self.a.count], 10)
//                let cstring = mere_string_retrieve(sid)
//                return (sid, String.fromCString(cstring)!)
//            }
//            
//            print(strings[10...12])
//        }
//        
//        print(runtime.prettyTimeIntervalDescription)
//        
//        
//        
//    }
    
}
