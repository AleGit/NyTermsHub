//
//  BuildTriePerformanceTests.swift
//  TptpNode
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

extension BuildTriePerformanceTests {
    
    
//    func fill<T:TrieType where T.Key==SymHop, T.Value==Int>(var root:T, literals:[TptpNode]) {
//        print(".")
//        for (index,literal) in literals.enumerate() {
//            for path in literal.positionPaths {
//                root.insert(path, value:index)
//            }
//        }
//    }
}

class BuildTriePerformanceTests: XCTestCase {
    // MARK: LCL129
    
    func testBuildTailLCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    func testBuildTrieLCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    // MARK: SYN000
    
    func testBuildTailSYN000() {
        let literals = TptpNode.literals("SYN000-1".p)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    func testBuildTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    // MARK: PUZ051
    
    func testBuildTailPUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    func testBuildTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    // MARK: HWV074
    
    func testBuildTailHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)
        }
    }
    
    func testBuildTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)
        }
    }

}
