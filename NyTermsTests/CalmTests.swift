//
//  CalmTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class CalmTests: XCTestCase {
    
    func testCalmTableDemo() {
        for capacity in [0, 30, 900, 810000] {
            var symbolTable = calmMakeSymbolTable(capacity)
            defer { calmDeleteSymbolTable(&symbolTable) }
            
            let strings = ["Hello", "🍜🍻🍕", "World", "Hello", "", "∀𝛕", "💤", "Hällü, Wörld!"]
            
            let sids = (0...2000).map { calmStoreSymbol(symbolTable, strings[$0 % (strings.count)]) }
            
            XCTAssertNotEqual(sids[0], sids[1]);
            XCTAssertNotEqual(sids[0], sids[2]);
            XCTAssertEqual(sids[0], sids[3]);
            XCTAssertNotEqual(sids[0], sids[4]);
            XCTAssertEqual(0, sids[4]);
            
            let mapping = sids[0..<strings.count].map {
                (CalmId) -> (CalmId, String, UInt) in
                let cstring = calmGetSybmol(symbolTable, CalmId)
                return (CalmId, String.fromCString(cstring)!, strlen(cstring))
            }
            
            print(mapping);
            
            var sid = calmNextSymbol(symbolTable, 0);
            while sid != 0 {
                let string = String.fromCString( calmGetSybmol(symbolTable, sid) )
                print(sid,string)
                
                sid = calmNextSymbol(symbolTable, sid);
            }
        }
        
        //        let backs = sids.map { String.fromCString(calmGetSybmol(symbolTable, $0))! }
        //        XCTAssertEqual(strings, backs);
        
    }
    
}
