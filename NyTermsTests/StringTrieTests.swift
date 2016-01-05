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
    
    /// builds a prefix tree for a list of strings
    func buildStringTrie(words:[String]) -> Trie<Character, String> {
        var trie = Trie<Character,String>()
        
        for word in words {
            let characters = Array(word.characters)
            trie.insert(characters, value: word)
        }
        
        return trie
    }
    
    func testStringTrie() {
        var words = ["a", "b", "c","d"]
        accumulate(&words,limit: 12345)
        XCTAssertEqual(12345,words.count)
        
        let trie = buildStringTrie(words)
        
        let prefix = [ "a" as Character, "b"]
        
        let abWords = trie[prefix]!.payload
        
        XCTAssertEqual(1789,abWords.count)
        
        let nabWords = Set(words).subtract(abWords)
        
        let count = nabWords.filter { $0.hasPrefix("ab") }.count
        
        XCTAssertEqual(0, count)
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
    
    /// This test builds a list of words, then takes each word and
    /// searches for all words in the list that are prefixed by this word.
    /// It does this by building (once) and using (multiple) a prefix tree (trie) 
    /// from the words and compares the total duration of building and 
    /// searching with the multiple linear filtering with a prefix predicate.
    /// - with 100 words trie prefix search is less than half as fast as linear prefix search
    /// - with 350 words trie prefix search is approximatley as fast as linear prefix search
    /// - with 2500 words trie prefix search is more than four times faster than linear prefix search
    func testStringTrieSpeedup() {
        
        var words = ["x1 __","a","b","c","d","e"]
        for (count, expected) in [
            (50,0.3),
            (350,0.95),
            (2_500, 4.0)
            ] {
            
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
