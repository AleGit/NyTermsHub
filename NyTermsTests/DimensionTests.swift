//
//  DimensionTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class DimensionTests: XCTestCase {
    
    
    func testA() {
        let (height,size,width,symbols) = a.dimensions()
        
        XCTAssertEqual(height,0)
        XCTAssertEqual(size,1)
        XCTAssertEqual(width,1)
        
        XCTAssertEqual(symbols.count,1)
        
        if let inds = symbols[a.symbol] {
            XCTAssertEqual(inds.type, SymbolType.Predicate)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 0))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail()
        }
    }
    
    func testFax() {
        let (height,size,width,symbols) = fax.dimensions()
        
        XCTAssertEqual(height,1)
        XCTAssertEqual(size,3)
        XCTAssertEqual(width,2)
        
        XCTAssertEqual(symbols.count,3)
        
        if let inds = symbols["f"] {
            XCTAssertEqual(inds.type, SymbolType.Predicate)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 2))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["a"] {
            XCTAssertEqual(inds.type, SymbolType.Function)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 0))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["X"] {
            XCTAssertEqual(inds.type, SymbolType.Variable)
            XCTAssertTrue(inds.arities.isEmpty)
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
    }
    
    func testGfaa() {
        let (height,size,width,symbols) = gfaa.dimensions()
        
        XCTAssertEqual(height,2)
        XCTAssertEqual(size,4)
        XCTAssertEqual(width,2)
        
        XCTAssertEqual(symbols.count,3)
        
        if let inds = symbols["g"] {
            XCTAssertEqual(inds.type, SymbolType.Predicate)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 1))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["f"] {
            XCTAssertEqual(inds.type, SymbolType.Function)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 2))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["a"] {
            XCTAssertEqual(inds.type, SymbolType.Function)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 0))
            XCTAssertEqual(inds.occurences, 2)
            
        }
        else {
            XCTFail(fax.description)
        }
    }
    
    func testAorB() {
        let clause = "a|b" as TestNode
        let (height,size,width,symbols) = clause.dimensions()
        
        XCTAssertEqual(height,1)
        XCTAssertEqual(size,3)
        XCTAssertEqual(width,2)
        XCTAssertEqual(symbols.count,3)
        
        XCTAssertEqual(symbols["a"]?.arities, Set(arrayLiteral: 0))
        XCTAssertEqual(symbols["b"]?.arities, Set(arrayLiteral: 0))
        XCTAssertEqual(symbols["|"]?.arities, Set(arrayLiteral: 2))
        
        XCTAssertEqual(symbols["a"]?.type, SymbolType.Predicate)
        XCTAssertEqual(symbols["b"]?.type, SymbolType.Predicate)
        XCTAssertEqual(symbols["|"]?.type, SymbolType.Disjunction)
        
        XCTAssertEqual(symbols["a"]?.occurences, 1)
        XCTAssertEqual(symbols["b"]?.occurences, 1)
        XCTAssertEqual(symbols["|"]?.occurences, 1)
        
        
    }
}
