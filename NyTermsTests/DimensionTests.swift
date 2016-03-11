//
//  DimensionTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 11.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

typealias NodeDimensions = (height:Int, size:Int, width:Int)
typealias NodeIndications = (type:SymbolType,arities:Set<Int>,occurences:Int)

class DimensionTests: XCTestCase {
    
    func testX() {
        var symbols = [Symbol:NodeIndications]()
        let dims = x.dimensions(true, symbols: &symbols)
        
        XCTAssertEqual(dims.height,0)
        XCTAssertEqual(dims.size,1)
        XCTAssertEqual(dims.width,1)
        
        XCTAssertEqual(symbols.count,1)
        
        if let inds = symbols[x.symbol] {
            XCTAssertEqual(inds.type, SymbolType.Variable)
            XCTAssertTrue(inds.arities.isEmpty)
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail()
        }
        
    }
    
    func testA() {
        var symbols = [Symbol:NodeIndications]()
        let dims = a.dimensions(true, symbols: &symbols)
        
        XCTAssertEqual(dims.height,0)
        XCTAssertEqual(dims.size,1)
        XCTAssertEqual(dims.width,1)
        
        XCTAssertEqual(symbols.count,1)
        
        if let inds = symbols[a.symbol] {
            XCTAssertEqual(inds.type, SymbolType.Function)
            XCTAssertEqual(inds.arities, Set(arrayLiteral: 0))
            XCTAssertEqual(inds.occurences, 1)
            
        }
        else {
            XCTFail()
        }
    }
    
    
    
    func testFax() {
        var symbols = [Symbol:NodeIndications]()
        let dims = fax.dimensions(true, symbols: &symbols)
        
        XCTAssertEqual(dims.height,1)
        XCTAssertEqual(dims.size,3)
        XCTAssertEqual(dims.width,2)
        
        XCTAssertEqual(symbols.count,3)
        
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
    
    
}
