//
//  BuildTriePerformanceTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

extension BuildTriePerformanceTests {
    func literals(localPath:String) -> [TptpNode] {
        return parse(path:"/Users/Shared/TPTP/Problems/" + localPath).1.flatMap { $0.root.nodes ?? [TptpNode]() }
    }
    
    func fill<T:TrieType where T.Key==SymHop, T.Value==Int>(var root:T, literals:[TptpNode]) {
        print(".")
        for (index,literal) in literals.enumerate() {
            for path in literal.paths {
                root.insert(path, value:index)
            }
        }
    }
}

class BuildTriePerformanceTests: XCTestCase {
    // MARK: LCL129
    
    func testBuildTailLCL129() {
        let literals = self.literals("LCL/LCL129-1.p")
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            self.fill(TailTrie<SymHop,Int>(), literals: literals)
        }
    }
    
    func testBuildTrieLCL129() {
        let literals = self.literals("LCL/LCL129-1.p")
        XCTAssertEqual(5,literals.count)
        
        self.measureBlock {
            self.fill(Trie<SymHop,Int>(), literals: literals)
        }
    }
    
    // MARK: SYN000
    
    func testBuildTailSYN000() {
        let literals = self.literals("SYN/SYN000-1.p")
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            self.fill(TailTrie<SymHop,Int>(), literals: literals)
        }
    }
    
    func testBuildTrieSYN000() {
        let literals = self.literals("SYN/SYN000-1.p")
        XCTAssertEqual(27,literals.count)
        
        self.measureBlock {
            self.fill(Trie<SymHop,Int>(), literals: literals)
        }
    }
    
    // MARK: PUZ051
    
    func testBuildTailPUZ051() {
        let literals = self.literals("PUZ/PUZ051-1.p")
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            self.fill(TailTrie<SymHop,Int>(), literals: literals)
        }
    }
    
    func testBuildTriePUZ051() {
        let literals = self.literals("PUZ/PUZ051-1.p")
        XCTAssertEqual(84,literals.count)
        
        self.measureBlock {
            self.fill(Trie<SymHop,Int>(), literals: literals)
        }
    }
    
    // MARK: HWV074
    
    func testBuildTailHWV074() {
        let literals = self.literals("HWV/HWV074-1.p")
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            self.fill(TailTrie<SymHop,Int>(), literals: literals)
        }
    }
    
    func testBuildTrieHWV074() {
        let literals = self.literals("HWV/HWV074-1.p")
        XCTAssertEqual(6017,literals.count)
        
        self.measureBlock {
            self.fill(Trie<SymHop,Int>(), literals: literals)
        }
    }

}
