//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

/// Parse tests with files
/// - Problems/SYN/SYN000-2.p
/// - Axioms/SYN000-0.ax
class ParseAdvancedSyntaxTests: XCTestCase {

    /// SYN000-2.p: Advanced TPTP CNF syntax.
    ///
    /// include('Axioms/SYN000-0.ax',[ia1,ia3]).
    func testParseSYN000cnf2() {
        let path = "/Users/Shared/TPTP/Problems/SYN/SYN000-2.p"
        
        let (result,tptpFormulae,tptpIncludes) = parsePath(path)
        XCTAssertEqual(2, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(0, result[1])
        XCTAssertEqual(19, tptpFormulae.count)
        
        XCTAssertEqual(1, tptpIncludes.count)
        
        let formulae = tptpFormulae.map { TermSampleStruct($0.formula) }
        
        // 1 quoted symbol
        var index = 0
        let tptpFormula = tptpFormulae[index]
        XCTAssertEqual("distinct_object",tptpFormula.name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormula.role)
        
        let clause = tptpFormula.formula
        XCTAssertEqual("|", clause.symbol)
        
        let literals = clause.terms!
        XCTAssertEqual("Array<TptpNode>", "\(literals.dynamicType)")
        XCTAssertEqual(1, literals.count)
        
        let literal = literals.first!
        XCTAssertEqual("!=", literal.symbol)
        
        let terms = literal.terms!
        XCTAssertEqual("Array<TptpNode>", "\(terms.dynamicType)")
        XCTAssertEqual(2, terms.count)
        
        let l = terms.first!
        let r = terms.last!
        
        XCTAssertEqual("\"An Apple\"", l.symbol)
        XCTAssertEqual("\"A \\\"Microsoft \\\\ escape\\\"\"", r.symbol)
        
        // 3 numbers
        
        XCTAssertEqual("integers",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(12)|p(-12)",formulae[index].description)
        
        XCTAssertEqual("rationals",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(123/456)|p(-123/456)|p(+123/456)",formulae[index].description)
        
        XCTAssertEqual("reals",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(123.456)|p(-123.456)|p(123.456E789)|p(123.456e789)|p(-123.456E789)|p(123.456E-789)|p(-123.456E-789)",formulae[index].description)
        
        // 5 roles
        
        XCTAssertEqual("role_definition",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Definition,tptpFormulae[index].role)
        XCTAssertEqual("f(d)=f(X)",formulae[index].description)
        
        XCTAssertEqual("role_assumption",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Assumption,tptpFormulae[index].role)
        XCTAssertEqual("p(a)",formulae[index].description)
        
        XCTAssertEqual("role_lemma",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Lemma,tptpFormulae[index].role)
        XCTAssertEqual("p(l)",formulae[index].description)
        
        XCTAssertEqual("role_theorem",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Theorem,tptpFormulae[index].role)
        XCTAssertEqual("p(t)",formulae[index].description)
        
        XCTAssertEqual("role_unknown",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Unknown,tptpFormulae[index].role)
        XCTAssertEqual("p(u)",formulae[index].description)
        
        // Selective include directive
        
        // 7 source
        
        XCTAssertEqual("source_unknown",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        XCTAssertEqual("source",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        XCTAssertEqual("source_name",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        XCTAssertEqual("source_copy",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        XCTAssertEqual("source_introduced_assumption",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        XCTAssertEqual("source_inference",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(a)",formulae[index].description)
        
        XCTAssertEqual("source_inference_with_bind",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(a)",formulae[index].description)
        
        // 1 useful info
        
        XCTAssertEqual("useful_info",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("p(X)",formulae[index].description)
        
        
        // 2 include('Axioms/SYN000-0.ax',[ia1,ia3]).
        
        XCTAssertEqual("ia1",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("ia1",formulae[index].description)
        
        XCTAssertEqual("ia3",tptpFormulae[++index].name)
        XCTAssertEqual(TptpRole.Axiom,tptpFormulae[index].role)
        XCTAssertEqual("ia3",formulae[index].description)
        
    }

}
