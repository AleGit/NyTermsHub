//
//  BasicTrieTypeTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 10.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class BasicTailTrieTests: XCTestCase {
    
    typealias TestTrie = TailTrie<Int,String>
    
    func testTailTrieInsert() {
//        var root = TestTrie.Inner(tries: [Int:TestTrie<Int,String>]())
//        root.insert([1],value:"B")
        var root = TestTrie(path: [1], value: "B")
        
        var copy = root
        XCTAssertEqual(root, copy)
        
        root.insert([1],value:"A")
        root.insert([1],value:"A")
        root.insert([2],value:"A")
        root.insert([0,1], value:"C")
        root.insert([0,1], value:"D")
        root.insert([0,1], value:"E")
        root.insert([0,2], value:"F")
        root.insert([0,2], value:"G")
        
        XCTAssertNotEqual(root, copy)
        
        XCTAssertNotEqual(root, copy)
        copy.insert([0,2], value:"G")
        copy.insert([0,2], value:"F")
        copy.insert([0,1], value:"E")
        copy.insert([0,1], value:"D")
        copy.insert([0,1], value:"C")
        copy.insert([2],value:"A")
        copy.insert([1],value:"A")
        copy.insert([1],value:"B")
        
        XCTAssertEqual(root, copy)
        XCTAssertFalse(root.isEmpty)
        
    }
    
    func testTailTrieDelete() {
        var root = TestTrie(path: [1], value: "B")
        XCTAssertFalse(root.isEmpty)
        
        let copy = root
        XCTAssertEqual(root, copy)
        
        root.insert([1],value:"A")
        root.insert([1],value:"A")
        root.insert([2],value:"A")
        root.insert([0,1], value:"C")
        root.insert([0,1], value:"D")
        root.insert([0,1], value:"E")
        root.insert([0,2], value:"F")
        root.insert([0,2], value:"G")
        
        XCTAssertNotEqual(root, copy)
        
        XCTAssertEqual("G",root.delete([0,2], value:"G"))
        XCTAssertEqual("F",root.delete([0,2], value:"F"))
        XCTAssertEqual("E",root.delete([0,1], value:"E"))
        XCTAssertEqual("D",root.delete([0,1], value:"D"))
        XCTAssertEqual("C",root.delete([0,1], value:"C"))
        XCTAssertEqual("A",root.delete([2],value:"A"))
        XCTAssertEqual("A",root.delete([1],value:"A"))
        XCTAssertNil(root.delete([1],value:"A"))
        
        XCTAssertEqual(root, copy)
        XCTAssertEqual("B",root.delete([1],value:"B"))
        XCTAssertTrue(root.isEmpty)
        
    }
    
    func testTailTrieRetrieve() {
        var root = TestTrie(path: [1], value: "B")
        root.insert([1],value:"A")
        root.insert([1],value:"A")
        root.insert([2],value:"A")
        root.insert([0,1], value:"C")
        root.insert([0,1], value:"D")
        root.insert([0,1], value:"E")
        root.insert([0,2], value:"F")
        root.insert([0,2], value:"G")
        
        XCTAssertEqual(Set(["A","B"]), Set(root.retrieve([1])!))
        XCTAssertEqual(Set(["A",]), Set(root.retrieve([2])!))
        XCTAssertEqual(Set(["C","D","E"]), Set(root.retrieve([0,1])!))
        XCTAssertEqual(Set(["F","G"]), Set(root.retrieve([0,2])!))
        
    }

}
