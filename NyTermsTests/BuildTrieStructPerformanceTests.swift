//
//  BuildTrieStructPerformanceTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 22.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class BuildTrieStructPerformanceTests: XCTestCase {
    
    typealias SymHopTrie = TrieStruct<SymHop<String>,Int>
    typealias SymbolTrie = TrieStruct<String,Int>
    
    // MARK: LCL129-1 (5)
    
    func testBuildSymHopTrieLCL129() {
        let literals = TptpNode.literals("LCL129-1".p!)
        XCTAssertEqual(5,literals.count)
        
        var trie = SymHopTrie()
        self.measureBlock {
            trie.fill(literals) { $0.paths }
        }
        XCTAssertEqual(literals.count, trie.payload.count)
    }
    
    func testBuildSymbolTrieLCL129() {
        let literals = TptpNode.literals("LCL129-1".p!)
        XCTAssertEqual(5,literals.count)
        
        var trie = SymbolTrie()
        self.measureBlock {
            trie.fill(literals)  { $0.stringPaths }
        }
        XCTAssertEqual(literals.count, trie.payload.count)
    }
    
    // MARK: SYN000-1 (27)
    
    func testBuildSymHopTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p!)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = SymHopTrie()
            trie.fill(literals)  { $0.paths }
        }
    }
    
    func testBuildSymbolTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p!)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.stringPaths }
        }
    }
    
    // MARK: PUZ051 (84)
    
    func testBuildSymHopTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p!)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = SymHopTrie()
            trie.fill(literals)  { $0.paths }
        }
    }
    
    func testBuildSymbolTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p!)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.stringPaths }
        }
    }
    
    // MARK: HWV074 (6017)
    
    func testBuildSymHopTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p!)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = SymHopTrie()
            trie.fill(literals)  { $0.paths }
        }
    }
    
    func testBuildSymbolTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p!)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.stringPaths }
        }
    }
    
    // MARK: HWV105 (52662)
    
    func testBuildSymHopTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p!)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = SymHopTrie()
            trie.fill(literals)  { $0.paths }
        }
    }
    
    func testBuildSymbolTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p!)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.stringPaths }
        }
    }
    
    // MARK: - Discrimination Trees
    
    func testDiscriminationTrieCL129() {
        let literals = TptpNode.literals("LCL129-1".p!)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    func testDiscriminationTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p!)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    func testDiscriminationTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p!)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    func testDiscriminationTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p!)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    func testDiscriminationTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p!)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = SymbolTrie()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
}
