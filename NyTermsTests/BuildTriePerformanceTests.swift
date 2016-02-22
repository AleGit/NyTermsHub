//
//  BuildSymHopTriePerformanceTests.swift
//  TptpNode
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

extension BuildSymHopTriePerformanceTests {
    
    
//    func fill<T:TrieType where T.Key==SymHop, T.Value==Int>(var root:T, literals:[TptpNode]) {
//        print(".")
//        for (index,literal) in literals.enumerate() {
//            for path in literal.symHopPaths {
//                root.insert(path, value:index)
//            }
//        }
//    }
}

class BuildSymHopTriePerformanceTests: XCTestCase {
    // MARK: LCL129
    
    func testBuildTailLCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals) { $0.symHopPaths }
        }
    }
    
    func testBuildSymHopTrieLCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymbolTrieLCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.symbolPaths }
        }
    }
    
    
    
    func testDiscriminationTrieCL129() {
        let literals = TptpNode.literals("LCL129-1".p)
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    // MARK: SYN000
    
    func testBuildTailSYN000() {
        let literals = TptpNode.literals("SYN000-1".p)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymHopTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymbolTrieSYN000() {
        let literals = TptpNode.literals("SYN000-1".p)
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.symbolPaths }
        }
    }
    
    // MARK: PUZ051
    
    func testBuildTailPUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymHopTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymbolTriePUZ051() {
        let literals = TptpNode.literals("PUZ051-1".p)
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.symbolPaths }
        }
    }
    
    // MARK: HWV074
    
    func testBuildTailHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymHopTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymbolTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.symbolPaths }
        }
    }
    
    
    
    func testDiscriminationTrieHWV074() {
        let literals = TptpNode.literals("HWV074-1".p)
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.preorderPath }
        }
    }
    
    // MARK: HWV105
    
    func testBuildTailHWV105() {
        let literals = TptpNode.literals("HWV105-1".p)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = TailTrie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymHopTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = Trie<SymHop,Int>()
            trie.fill(literals)  { $0.symHopPaths }
        }
    }
    
    func testBuildSymbolTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.symbolPaths }
        }
    }
    
    
    func testDiscriminationTrieHWV105() {
        let literals = TptpNode.literals("HWV105-1".p)
        XCTAssertEqual(52662,literals.count)
        
        self.measureBlock {
            var trie = Trie<Symbol,Int>()
            trie.fill(literals)  { $0.preorderPath }
        }
    }

}
