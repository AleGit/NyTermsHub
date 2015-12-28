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
    
    func myprint(ts:[(String,CFAbsoluteTime)]) {
        
        for (index,pair) in ts[1..<ts.count].enumerate() {
            let duration = pair.1 - ts[index].1
            print("\(pair.0)\t\(duration)")
        }
        
    }
    
    func testStringTriePerformance() {
        let prefix = "x1 a __ xx 432"
        var words = [prefix,"a","b","c","d","e"]

        var ts = [("Start",CFAbsoluteTimeGetCurrent())]
        let limit = 1_000_000
        repeat   {
            outer: for first in words {
                for second in words {
                    
                    words.append(first+second)
                    
                    guard words.count < limit else { break outer }
                }
            }
        }
        while words.count < limit
        
        
        
        XCTAssertEqual(limit, words.count)
        ts.append(("WordsBuild", CFAbsoluteTimeGetCurrent()))
        
        // print(words)
        // ts.append(("WordsPrint", CFAbsoluteTimeGetCurrent()))
        
        
        
        
        let trie = buildStringTrie(words)
        ts.append(("TrieBuild", CFAbsoluteTimeGetCurrent()))
        
        let path = Array((prefix+"abc").characters)
        guard let trieResult = trie[path]?.payload else {
            XCTFail()
            return
        }
        ts.append(("TrieSearch", CFAbsoluteTimeGetCurrent()))
        
        
        let mapResult = words.filter {
            $0.hasPrefix(prefix+"abc")
        }
        ts.append(("ArrayFilter", CFAbsoluteTimeGetCurrent()))
        myprint(ts)
        
        
        
        XCTAssertEqual(limit,mapResult.count)
        
        
        
        
        
        
        

        
        
    }

}
