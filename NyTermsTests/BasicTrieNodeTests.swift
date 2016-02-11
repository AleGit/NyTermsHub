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
    
    func testTailTrieEquality() {
        var root = TailTrie.Inner(tries: [Int:TailTrie<Int,String>]())
        var copy = root
        root.insert([1],value:"B")
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
        
    }
    
    func testTailTrieDelete() {
        var root = TailTrie.Inner(tries: [Int:TailTrie<Int,String>]())
        let copy = root
        XCTAssertEqual(root, copy)
        root.insert([1],value:"B")
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
        XCTAssertEqual("B",root.delete([1],value:"B"))
        
        XCTAssertEqual(root, copy)
        
    }

}
