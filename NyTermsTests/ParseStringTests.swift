//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

/// Parse tests with strings.
class ParseStringTests: XCTestCase {
    
    func testParseString() {
        let expected = "( lives(agatha ))"
        let cnf = "cnf(agatha,hypothesis,( lives(agatha) )). cnf(agatha,hypothesis,\(expected))."
        
        let (result,tptpFormulae) = parseString(cnf)
        
        XCTAssertEqual(0, result)
        XCTAssertEqual(2, tptpFormulae.count)
        
        let myformulae = tptpFormulae.map{ $0.root }
        for myformula in myformulae {
            let myterm = NodeStruct(myformulae[0]);
            
            
            XCTAssertEqual("lives(agatha)",myterm.description)
            
            XCTAssertEqual("TptpNode","\(myformula.dynamicType)")
            XCTAssertEqual("NodeStruct","\(myterm.dynamicType)")
            
            XCTAssertEqual("String","\(myformula.symbol.dynamicType)")
            XCTAssertEqual("String","\(myterm.symbol.dynamicType)")
        }
        
        
        XCTAssertEqual("Array<TptpFormula>","\(tptpFormulae.dynamicType)")
        XCTAssertEqual("Array<TptpNode>","\(myformulae.dynamicType)")
    }
    
    typealias MyTestTerm = NodeStruct
    
    func fof_annotated(input:String) -> String {
        return "fof(test,axiom,\(input))."
    }
    
    func testMultipleQuantifier() {
        for (input,value) in [
            "![A,B,C]:p(A)" : "(![A,B,C]:(p(A)))",
            "![A]:?[B]:p(A)" : "(![A]:((?[B]:(p(A)))))",
            "?[A]:![B]:p(A)" : "(?[A]:((![B]:(p(A)))))",
            "?[A]:![B]:?[C]:p(A)" : "(?[A]:((![B]:((?[C]:(p(A)))))))"
            ] {
                let fofa = fof_annotated(input)
                let (result,formulae) = parseString(fofa)
                XCTAssertEqual(0, result)
                XCTAssertEqual(value, formulae[0].root.description)
                
                
        }
    }
    
    func testParseQuantified() {
        let expected = "(![B]:(addressVal(v83622_range_3_to_0_address_term_bound_98,B)<=>v83622(constB98,B)))"
        let fof = "fof(transient_address_definition_401,axiom,(! [B] : ( addressVal(v83622_range_3_to_0_address_term_bound_98,B) <=> v83622(constB98,B) ) ))."
            + "fof(transient_address_definition_401,axiom,\(expected))."
        let (result,tptpFormulae) = parseString(fof)
        
        XCTAssertEqual(0, result)
        XCTAssertEqual(2, tptpFormulae.count)
        
        let myformulae = tptpFormulae.map{ $0.root }
        for myformula in myformulae {
            let myterm = NodeStruct(myformula)
            XCTAssertEqual(expected,myterm.description)
        }
        
    }
    
    
    
    
    
    
    
    
    
}
