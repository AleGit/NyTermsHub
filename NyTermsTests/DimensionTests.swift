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
            XCTAssertEqual(inds.type, SymbolType.predicate)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 0))
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
            XCTAssertEqual(inds.type, SymbolType.predicate)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 2))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["a"] {
            XCTAssertEqual(inds.type, SymbolType.function)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 0))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["X"] {
            XCTAssertEqual(inds.type, SymbolType.variable)
            XCTAssertTrue(inds.arity.isEmpty)
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
            XCTAssertEqual(inds.type, SymbolType.predicate)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 1))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["f"] {
            XCTAssertEqual(inds.type, SymbolType.function)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 2))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail(fax.description)
        }
        
        if let inds = symbols["a"] {
            XCTAssertEqual(inds.type, SymbolType.function)
            XCTAssertEqual(inds.arity, Set(arrayLiteral: 0))
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
        
        XCTAssertEqual(symbols["a"]?.arity, Set(arrayLiteral: 0))
        XCTAssertEqual(symbols["b"]?.arity, Set(arrayLiteral: 0))
        XCTAssertEqual(symbols["|"]?.arity, Set(arrayLiteral: 2))
        
        XCTAssertEqual(symbols["a"]?.type, SymbolType.predicate)
        XCTAssertEqual(symbols["b"]?.type, SymbolType.predicate)
        XCTAssertEqual(symbols["|"]?.type, SymbolType.disjunction)
        
        XCTAssertEqual(symbols["a"]?.occurences, 1)
        XCTAssertEqual(symbols["b"]?.occurences, 1)
        XCTAssertEqual(symbols["|"]?.occurences, 1)
    }
    
    
    func testPorNP() {
        let clause = "p(f(g(a),X))|~p(g(f(a,X)))" as TestNode
        let (height,size,width,symbols) = clause.dimensions()
        
        XCTAssertEqual(height,5)
        XCTAssertEqual(size,12)
        XCTAssertEqual(width,4)
        XCTAssertEqual(symbols.count,7)
        
        XCTAssertEqual(symbols["|"]?.occurences, 1)
        XCTAssertEqual(symbols["~"]?.occurences, 1)
        XCTAssertEqual(symbols["p"]?.occurences, 2)
        XCTAssertEqual(symbols["f"]?.occurences, 2)
        XCTAssertEqual(symbols["g"]?.occurences, 2)
        XCTAssertEqual(symbols["a"]?.occurences, 2)
        XCTAssertEqual(symbols["X"]?.occurences, 2)
        
        XCTAssertEqual(symbols["|"]?.type, SymbolType.disjunction)
        XCTAssertEqual(symbols["~"]?.type, SymbolType.negation)
        XCTAssertEqual(symbols["p"]?.type, SymbolType.predicate)
        XCTAssertEqual(symbols["f"]?.type, SymbolType.function)
        XCTAssertEqual(symbols["g"]?.type, SymbolType.function)
        XCTAssertEqual(symbols["a"]?.type, SymbolType.function)
        XCTAssertEqual(symbols["X"]?.type, SymbolType.variable)
        
        XCTAssertEqual(symbols["|"]?.arity, Set(arrayLiteral: 2))
        XCTAssertEqual(symbols["~"]?.arity, Set(arrayLiteral: 1))
        XCTAssertEqual(symbols["p"]?.arity, Set(arrayLiteral: 1))
        XCTAssertEqual(symbols["f"]?.arity, Set(arrayLiteral: 2))
        XCTAssertEqual(symbols["g"]?.arity, Set(arrayLiteral: 1))
        XCTAssertEqual(symbols["a"]?.arity, Set(arrayLiteral: 0)) // a function with arity 0 is constant.
        XCTAssertEqual(symbols["X"]?.arity, Set<Int>()) // a variable has no arity
        
        
    }
}
