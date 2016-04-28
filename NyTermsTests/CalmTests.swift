//
//  CalmTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class CalmTests: XCTestCase {
    
    func testCalmTableDemo() {
        calm_table_init()
        
        let strings = ["Hello", "World", "Hello", "", "∀𝛕", "💤"]
        
        let sids = strings.map { calm_table_store($0) }
        
        XCTAssertNotEqual(sids[0], sids[1]);
        XCTAssertEqual(sids[0], sids[2]);
        XCTAssertNotEqual(sids[0], sids[3]);
        XCTAssertEqual(0, sids[3]);
        
        print(sids);
        
        
        
        let backs = sids.map { String.fromCString(calm_table_retrieve($0))! }
        XCTAssertEqual(strings, backs);
        
        calm_table_exit()
    }

}
