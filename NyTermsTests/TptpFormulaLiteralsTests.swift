//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

class TptpFormulaLiteralsTests: XCTestCase {

    func testFOF() {
        // first in 'PUZ001+1.p'
        let fof : TptpFormula = "fof(pel55_1,axiom, ( ? [X] : ( lives(X) & killed(X,agatha) ) ))."
        XCTAssertEqual("fof(pel55_1,axiom,(?[X]:(lives(X)&killed(X,agatha)))).", fof.description)
        
        let fof2 = TptpFormula(language:fof.language, stringLiteral:fof.formula.description)
        XCTAssertEqual(fof.formula.description, fof2.formula.description)
        
        let fof3 = TptpFormula.FOF(stringLiteral: fof.formula.description)
        XCTAssertEqual(fof.formula.description, fof3.formula.description)
    }
    
    func testCNF() {
        // first in 'PUZ001-1.p'
        let cnf = "cnf(agatha,hypothesis, ( lives(agatha) ))." as TptpFormula
        XCTAssertEqual("cnf(agatha,hypothesis,lives(agatha)).", cnf.description)
        
        let literal = cnf.formula.description
        let cnf2 = TptpFormula(language:cnf.language, stringLiteral:literal)
        let literal2 = cnf2.formula.description
        XCTAssertEqual(cnf.formula.description, literal2)
        
        
        let cnf3 = TptpFormula.CNF(stringLiteral: cnf.formula.description)
        let literal3 = cnf3.formula.description
        XCTAssertEqual(cnf.formula.description, literal3)
        
    }

    

}
