//
//  BasicTrieTypeTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 10.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class BasicTrieNodeTests: XCTestCase {

    func testTrieNodePathTooShort() {
        
        var root = TrieNode.Inner(tries: [Int:TrieNode<Int,String>]())
        try! root.insert([Int](), value:"1")
        print(root)
        
        do {
            try root.insert([1],value:"B")
            print(root)
        }
        catch TrieNodeError.PathIsTooLong {
            print(root)
        }
        catch TrieNodeError.PathIsTooShort {
            XCTFail()
        }
        catch let error {
            print("error", error)
        }
        print(root)
        
    }
    
    func testTrieNodePathTooLong() {
        
        var root = TrieNode.Inner(tries: [Int:TrieNode<Int,String>]())
        try! root.insert([1],value:"B")
        print(root)
        
        do {
            try root.insert([Int](), value:"1")
            print(root)
        }
        catch TrieNodeError.PathIsTooLong {
            XCTFail()
        }
        catch TrieNodeError.PathIsTooShort {
            print(root)
        }
        catch let error {
            print("error", error)
        }
        
    }
    
    func testTrieNodeRoot() {
        var root = TrieNode.Inner(tries: [Int:TrieNode<Int,String>]())
        var copy = root
        try! root.insert([1],value:"B")
        try! root.insert([1],value:"A")
        try! root.insert([1],value:"A")
        try! root.insert([2],value:"A")
        try! root.insert([0,1], value:"C")
        try! root.insert([0,1], value:"D")
        try! root.insert([0,1], value:"E")
        try! root.insert([0,2], value:"F")
        try! root.insert([0,2], value:"G")
        
        XCTAssertNotEqual(root, copy)
        
        XCTAssertNotEqual(root, copy)
        try! copy.insert([0,2], value:"G")
        try! copy.insert([0,2], value:"F")
        try! copy.insert([0,1], value:"E")
        try! copy.insert([0,1], value:"D")
        try! copy.insert([0,1], value:"C")
        try! copy.insert([2],value:"A")
        try! copy.insert([1],value:"A")
        try! copy.insert([1],value:"B")
        
        XCTAssertEqual(root, copy)
        
    }
    
    
    
    func testTrieNodeDelete() {
        var root = TrieNode.Inner(tries: [Int:TrieNode<Int,String>]())
        let copy = root
        XCTAssertEqual(root, copy)
        try! root.insert([1],value:"B")
        try! root.insert([1],value:"A")
        try! root.insert([1],value:"A")
        try! root.insert([2],value:"A")
        try! root.insert([0,1], value:"C")
        try! root.insert([0,1], value:"D")
        try! root.insert([0,1], value:"E")
        try! root.insert([0,2], value:"F")
        try! root.insert([0,2], value:"G")
        
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
