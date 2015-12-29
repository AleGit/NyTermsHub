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
    
    func accumulate(inout words:[String], limit:Int) -> CFAbsoluteTime {
        let start = CFAbsoluteTimeGetCurrent()
        repeat {
            for first in words {
                for second in words {
                    words.append(first+second)
                    guard words.count < limit else { return CFAbsoluteTimeGetCurrent() - start }
                }
            }
        }
            while true
    }
    
    func trieSearch(words:[String]) -> (duration:CFAbsoluteTime,results:[Set<String>]) {
        let start = CFAbsoluteTimeGetCurrent()
        
        let trie = buildStringTrie(words)
        var results = [Set<String>]()
        
        for word in words {
            let path = Array(word.characters)
            
            guard let result = trie[path]?.payload else {
                continue
            }
            results.append(result)
        }
        
        return (CFAbsoluteTimeGetCurrent() - start, results)
    }
    
    func filterSearch(words:[String]) -> (duration:CFAbsoluteTime,results:[[String]]) {
        let start = CFAbsoluteTimeGetCurrent()
        
        var results = [[String]]()
        
        for word in words {
            let result = words.filter {
                $0.hasPrefix(word)
            }
            results.append(result)
        }
        
        return (CFAbsoluteTimeGetCurrent() - start, results)

    }
    
    func testStringTriePerformance() {
        
        var words = ["x1 __","a","b","c","d","e"]
        for (count, expected) in [(50,0.3), (300,1.1), (1_800, 3.4)] {
            
            let duration = accumulate(&words, limit:count)
            print("build words\t",duration,duration/Double(count))
            XCTAssertEqual(count, words.count)
            
            let trieResult = trieSearch(words)
            print("trie search\t",trieResult.duration,trieResult.duration/Double(count))
            
            let filterResult = filterSearch(words)
            print("filtering\t",filterResult.duration,filterResult.duration/Double(count))
            
            let speedup = filterResult.duration/trieResult.duration
            let message = "\(count)-speedup: expected=\(expected), actual=\(speedup)"
            print(message)
            
            XCTAssertTrue(expected < speedup, message)
            XCTAssertEqual(trieResult.results.count, filterResult.results.count)
        }
    }
    
}
