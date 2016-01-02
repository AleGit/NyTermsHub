//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

class TptpFormulaLiteralsTests: XCTestCase {

    func testFOF() {
        // first in 'PUZ001+1.p'
        let fof : TptpFormula = "fof(pel55_1,axiom, ( ? [X] : ( lives(X) & killed(X,agatha) ) ))."
        XCTAssertEqual("fof(pel55_1,axiom,(?[X]:(lives(X)&killed(X,agatha)))).", fof.description)
        
        let fof2 = TptpFormula(language:fof.language, stringLiteral:fof.root.description)
        XCTAssertEqual(fof.root.description, fof2.root.description)
        
        let fof3 = TptpFormula.FOF(stringLiteral: fof.root.description)
        XCTAssertEqual(fof.root.description, fof3.root.description)
    }
    
    func testCNF() {
        // first in 'PUZ001-1.p'
        let cnf = "cnf(agatha,hypothesis, ( lives(agatha) ))." as TptpFormula
        XCTAssertEqual("cnf(agatha,hypothesis,lives(agatha)).", cnf.description)
        
        let literal = cnf.root.description
        let cnf2 = TptpFormula(language:cnf.language, stringLiteral:literal)
        let literal2 = cnf2.root.description
        XCTAssertEqual(cnf.root.description, literal2)
        
        
        let cnf3 = TptpFormula.CNF(stringLiteral: cnf.root.description)
        let literal3 = cnf3.root.description
        XCTAssertEqual(cnf.root.description, literal3)
        
    }

    

}
