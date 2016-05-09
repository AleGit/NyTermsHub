//
//  PrlcTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 04.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class PrlcTests: XCTestCase {

    func testPrlcCreateStore() {
        let fileSize = 0
        var store = prlcCreateStore(fileSize);
        defer {
            prlcDestroyStore(&store);
            XCTAssertTrue(store == nil);
        }
        
        XCTAssertEqual(1024, store.memory.symbols.capacity);
        XCTAssertEqual(1024, store.memory.p_nodes.capacity);
        XCTAssertEqual(1024, store.memory.t_nodes.capacity);
        
        XCTAssertEqual(1, store.memory.symbols.unit);
        XCTAssertEqual(2056, store.memory.p_nodes.unit);
        XCTAssertEqual(40, store.memory.t_nodes.unit);

        
        XCTAssertEqual(42, store.memory.symbols.size);
        XCTAssertEqual(20, store.memory.p_nodes.size);
        XCTAssertEqual(0, store.memory.t_nodes.size);
        
        XCTAssertEqual("", String.fromCString(prlcFirstSymbol(store))!);
        
    }
    
    func testParsePUZ001() {
        let path = "PUZ001-1".p!
        
        let (result,time) = measure {
            prlcParse(path)
        }
        
        XCTAssertTrue(time < 0.01)
        XCTAssertEqual(106, result.1?.treeStoreSize)
        XCTAssertEqual(0,result.0);
        
        let sequence = result.1!.tptpSequence {
            ref in
            String.fromCString(ref.memory.symbol) ?? "n/a"
            
        }
        
        for node in sequence {
            print(node)
        }
        
        
    }
    
    func testParseHWV134() {
        let path = "HWV134-1".p!
        
        let (result,time) = measure {
            prlcParse(path)
        }
        
        print("time:",time.prettyTimeIntervalDescription)
        XCTAssertTrue(time < 45,"\(time)")
        XCTAssertEqual(29_953_326, result.1?.treeStoreSize)
        // 29953326
        
        XCTAssertEqual(0,result.0);
        
        
    }
    
    func testPrlcStoreSymbol() {
        var store = prlcCreateStore(123);
        defer {
            prlcDestroyStore(&store);
            XCTAssertTrue(store == nil);
        }
        
        XCTAssertEqual(42, store.memory.symbols.size);
        XCTAssertEqual(20, store.memory.p_nodes.size);
        
        let string1 = "Hello, World!";
        let string2 = "🍜🍻"
        
        let s1 = prlcStoreSymbol(store,string1);
        let s2 = prlcStoreSymbol(store,string2);
        
        XCTAssertEqual(65, store.memory.symbols.size);
        XCTAssertEqual(41, store.memory.p_nodes.size);
        
        let s1c = prlcStoreSymbol(store,string1);
        let s2c = prlcStoreSymbol(store,string2);
        
        XCTAssertEqual(65, store.memory.symbols.size);
        XCTAssertEqual(41, store.memory.p_nodes.size);
        
        XCTAssertEqual(string1, String.fromCString(s1))
        XCTAssertEqual(string2, String.fromCString(s2))
        
        XCTAssertEqual(string1, String.fromCString(s1c))
        XCTAssertEqual(string2, String.fromCString(s2c))
        
        XCTAssertEqual(s1c, s1);
        XCTAssertEqual(s2c, s2);
        
        var symbols = [ String ]();
        var symbol = prlcFirstSymbol(store)
        while (symbol != nil) {
            symbols.append(String.fromCString(symbol)!)
            symbol = prlcNextSymbol(store, symbol)
        }
        
        XCTAssertEqual([
            "", "~", "|", "&", "-->", ",", "<=>", "=>", "<=", "<~>", "~|", "~&", "!", "?", "=", "!=",
            "Hello, World!",
            "🍜🍻"], symbols)
        
        XCTAssertEqual(18, symbols.count)
        
        
    }

}
