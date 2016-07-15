//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable
import NyTerms

/// Parse tests with puzzles
/// - Problems/PUZ/PUZ001-1.p
/// - Problems/PUZ/PUZ051-1.p
class ParsePuzzleFileTests: XCTestCase {

    /// PUZ001-1.p: Dreadbury Mansion.
    ///
    /// Who killed Aunt Agatha?
    func testParsePUZ001m1() {
        let path = "PUZ001-1".p!
        
        let (result,tptpFormulae,_) = parse(path:path)
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(12, tptpFormulae.count)
        
        // test transformation
        let tptpNodes = tptpFormulae.map { NodeStruct($0.root) }
        
        XCTAssertEqual("lives(agatha)",tptpNodes[0].description)
        XCTAssertEqual("killed(butler,agatha)|killed(charles,agatha)",tptpNodes[11].description)
        XCTAssertEqual("String","\(tptpFormulae[11].root.symbol.dynamicType)")
        
        let roots = tptpFormulae.map { $0.root }
        
        for root in roots {
            XCTAssertTrue(root.isFormula)
            XCTAssertTrue(root.isClause)
        }
        
        XCTAssertEqual(10, roots.count { $0.isHornClause })
        XCTAssertEqual(5, roots.count { $0.isUnitClause })
        XCTAssertEqual(21, roots.reduce(0) { $0! + $1.nodes!.count })
    }
    
    /// PUZ051-1.p: Quo vadis 6.
    ///
    /// includes Axioms/PUZ004-0.ax
    func testParsePUZ051m1() {
        let path = "PUZ051-1".p!
        
        let (result,tptpFormulae,tptpIncludes) = parse(path:path)
        XCTAssertEqual(2, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(0, result[1])
        XCTAssertEqual(43, tptpFormulae.count)
        
        XCTAssertEqual(1, tptpIncludes.count)
        
        // test transformation
        var index = 0
        if tptpFormulae.count > index {
            XCTAssertEqual(tptpFormulae[index].language, TptpLanguage.cnf)
            XCTAssertEqual(tptpFormulae[index].name, "intermediate_state")
            XCTAssertEqual(tptpFormulae[index].role, TptpRole.hypothesis)
            XCTAssertTrue(tptpFormulae[index].root.isFormula)
            XCTAssertTrue(tptpFormulae[index].root.isClause)
        }
        
        index = 1
        if tptpFormulae.count > index {
            XCTAssertEqual(tptpFormulae[index].language, TptpLanguage.cnf)
            XCTAssertEqual(tptpFormulae[index].name, "goal_state")
            XCTAssertEqual(tptpFormulae[index].role, TptpRole.negatedConjecture)
        }
        
        for root in tptpFormulae[2..<tptpFormulae.count] {
            XCTAssertEqual(root.language, TptpLanguage.cnf)
            XCTAssertEqual(root.role, TptpRole.axiom)
            XCTAssertTrue(root.root.isFormula)
            XCTAssertTrue(root.root.isClause)
        }
    }
    
    


}
