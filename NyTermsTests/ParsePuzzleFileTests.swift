//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

/// Parse tests with puzzles
/// - Problems/PUZ/PUZ001-1.p
/// - Problems/PUZ/PUZ051-1.p
class ParsePuzzleFileTests: XCTestCase {

    /// PUZ001-1.p: Dreadbury Mansion.
    ///
    /// Who killed Aunt Agatha?
    func testParsePUZ001cfn1() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p"
        
        let (result,tptpFormulae,_) = parsePath(path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        // test transformation
        let myterms = tptpFormulae.map { NodeStruct($0.formula) }
        
        XCTAssertEqual("lives(agatha)",myterms[0].description)
        XCTAssertEqual("killed(butler,agatha)|killed(charles,agatha)",myterms[11].description)
        XCTAssertEqual("String","\(tptpFormulae[11].formula.symbol.dynamicType)")
        
        for formula in tptpFormulae {
            XCTAssertTrue(formula.formula.isFormula)
            XCTAssertTrue(formula.formula.isClause)
        }
    }
    
    /// PUZ051-1.p: Quo vadis 6.
    ///
    /// includes Axioms/PUZ004-0.ax
    func testParsePUZ051cfn1() {
        let path = "/Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p"
        
        let (result,tptpFormulae,tptpIncludes) = parsePath(path)
        XCTAssertEqual(2, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(0, result[1])
        XCTAssertEqual(43, tptpFormulae.count)
        
        XCTAssertEqual(1, tptpIncludes.count)
        
        // test transformation
        var index = 0
        if tptpFormulae.count > index {
            XCTAssertEqual(tptpFormulae[index].language, TptpLanguage.CNF)
            XCTAssertEqual(tptpFormulae[index].name, "intermediate_state")
            XCTAssertEqual(tptpFormulae[index].role, TptpRole.Hypothesis)
            XCTAssertTrue(tptpFormulae[index].formula.isFormula)
            XCTAssertTrue(tptpFormulae[index].formula.isClause)
        }
        
        index = 1
        if tptpFormulae.count > index {
            XCTAssertEqual(tptpFormulae[index].language, TptpLanguage.CNF)
            XCTAssertEqual(tptpFormulae[index].name, "goal_state")
            XCTAssertEqual(tptpFormulae[index].role, TptpRole.NegatedConjecture)
        }
        
        for formula in tptpFormulae[2..<tptpFormulae.count] {
            XCTAssertEqual(formula.language, TptpLanguage.CNF)
            XCTAssertEqual(formula.role, TptpRole.Axiom)
            XCTAssertTrue(formula.formula.isFormula)
            XCTAssertTrue(formula.formula.isClause)
        }
    }
    
    


}
