//
//  StringTrieTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.12.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class StringTrieTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSimpleStringTrie() {
        
        let hello = "Hello"
        let helloComma = hello + ", "
        let helloEurope = helloComma + "Europe!"
        let helloAmerica = helloComma + "Amerika."
        
        
        let trie = buildStringTrie([hello, helloComma, helloEurope, helloAmerica])
        
        let prefix = Array(helloComma.characters)
        let expected = Set([helloComma, helloEurope, helloAmerica].filter {
            $0.hasPrefix(helloComma)
        })
        
        if let subtrie = trie[prefix]  {
            XCTAssertEqual(1, subtrie.data.count)
            XCTAssertTrue(subtrie.data.contains(helloComma))
            
            XCTAssertEqual(3, subtrie.payload.count)
            XCTAssertEqual(expected, subtrie.payload)
            
        }
        else {
            XCTFail()
        }
        
        let goodbye = "Goodbye"
        let unknown = Array(goodbye.characters)
        
        XCTAssertNil(trie[unknown])
        
        
        
        
        
        
    }

}
