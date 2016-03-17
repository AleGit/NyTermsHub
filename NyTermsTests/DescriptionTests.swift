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
    
    func testSimpleDescriptions() {
        let X : TptpNode = "X"
        let a : TptpNode = "a"
        let faX = TptpNode(function:"f",nodes: [a,X])
        let fXa = TptpNode(function:"f",nodes: [X,a])
        
        let equation = TptpNode(equational:"=", nodes: [faX,fXa])
        
        XCTAssertEqual(faX.tptpDescription, "f(a,X)")
        XCTAssertEqual(fax.laTeXDescription, "{\\mathsf f}({\\mathsf a},x)")
        
        XCTAssertEqual(equation.tptpDescription, "f(a,X)=f(X,a)")
        XCTAssertEqual(equation.laTeXDescription, "{\\mathsf f}({\\mathsf a},x)\\approx {\\mathsf f}(x,{\\mathsf a})")
    }

}
