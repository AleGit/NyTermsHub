//
//  DescriptionTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 12.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

class DescriptionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testSimpleDescriptions() {
        let X : TptpNode = "X"
        let a : TptpNode = "a"
        let faX = TptpNode(function:"f",nodes: [a,X])
        let fXa = TptpNode(function:"f",nodes: [X,a])
        
        let equation = TptpNode(equational:"=", nodes: [faX,fXa])
        
        XCTAssertEqual(faX.tptpDescription, "f(a,X)")
        XCTAssertEqual(fax.laTeXDescription, "{\\mathsf f}({\\mathsf a},x)")
        
        XCTAssertEqual(fax.tikzSyntaxTree, "\\node {${\\mathsf f}$}\n% [clockwise from=-170,sibling angle=-160]\nchild {node {${\\mathsf a}$}}\nchild {node {$x$}};")
        print(fax.laTeXDescription)
        print(fax.tikzSyntaxTree)
        
        print(equation.laTeXDescription)
        print(equation.tikzSyntaxTree)
    }

}
