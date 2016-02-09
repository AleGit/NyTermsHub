//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

/// Parse tests with strings.
class ParseStringTests: XCTestCase {
    typealias MyTestTerm = NodeStruct
    
    func testParseString() {
        let expected = "( lives(agatha ))"
        let cnf = "cnf(agatha,hypothesis,( lives(agatha) )). cnf(agatha,hypothesis,\(expected))."
        
        let tptpFormulae = parse(string:cnf)
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
    
    func testParseStringMultipleQuantifiers() {
        func fof_annotated(input:String) -> String {
            return "fof(test,axiom,\(input))."
        }
        
        for (input,value) in [
            ("![A,B,C]:p(A)" , "(![A,B,C]:(p(A)))"),
            ("![A]:?[B]:p(A)" , "(![A]:((?[B]:(p(A)))))"),
            ("?[A]:![B]:p(A)" , "(?[A]:((![B]:(p(A)))))"),
            ("?[A]:![B]:?[C]:p(A)" , "(?[A]:((![B]:((?[C]:(p(A)))))))")
            ] {
                let fofa = fof_annotated(input)
                let formulae = parse(string:fofa)
                XCTAssertEqual(value, formulae[0].root.description)
                
                print("% ------------------")
                print(formulae[0].root.tikzSyntaxTree)
                print("% ---")
                print(formulae[0].root.laTeXDescription)
        }
    }
    
    func testParseStringSingleQuantifier() {
        let expected = "(![B]:(addressVal(v83622_range_3_to_0_address_term_bound_98,B)<=>v83622(constB98,B)))"
        let fof = "fof(transient_address_definition_401,axiom,(! [B] : ( addressVal(v83622_range_3_to_0_address_term_bound_98,B) <=> v83622(constB98,B) ) ))."
            + "fof(transient_address_definition_401,axiom,\(expected))."
        let tptpFormulae = parse(string:fof)
        
        XCTAssertEqual(2, tptpFormulae.count)
        
        let myformulae = tptpFormulae.map{ $0.root }
        for myformula in myformulae {
            let myterm = NodeStruct(myformula)
            XCTAssertEqual(expected,myterm.description)
        }
    }
}
