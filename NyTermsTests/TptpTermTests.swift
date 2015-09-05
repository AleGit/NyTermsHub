//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

/// Tests for default implementation of protocol term with **bridging class** data structure.
class TptpTermTests: XCTestCase {
    
    private typealias TermType = TptpTerm
    
    func testEquals() {
        XCTAssertEqual("a", TermType(a))
        XCTAssertEqual(TermType(constant:"a"), TermType(a))
        XCTAssertEqual("b", TermType(b))
        XCTAssertEqual("c", TermType(c))
        XCTAssertEqual("X", TermType(x))
        XCTAssertEqual(TermType(variable:"X"), TermType(x))
        XCTAssertEqual("Y", TermType(y))
        XCTAssertEqual("Z", TermType(z))
        XCTAssertEqual("f(X,Y)", TermType(fxy))
        XCTAssertEqual(TermType(function:"f",terms: ["X","Y"]), TermType(fxy))
        XCTAssertEqual(TermType(function:"f",terms: [TermType(variable:"X"),TermType(variable:"Y")]), TermType(fxy))
        XCTAssertEqual("f(a,X)", TermType(fax))
        XCTAssertEqual("f(X,a)", TermType(fxa))
        XCTAssertEqual("f(a,a)", TermType(faa))
        XCTAssertEqual("g(X)", TermType(gx))
        XCTAssertEqual("g(b)", TermType(gb))
        let rule = TermType.Rule("f(X,Y)","X")!
        XCTAssertEqual(rule, TermType(fxy_x!))
    }
    
    func testCriticalPeaks() {
        guard let fagx_fxx = TermType.Rule("f(a,g(X))", "f(X,X)") else { XCTAssert(false, "f(a,g(X))=f(X,X) would be a rule."); return }
        guard let gb_c = TermType.Rule("g(b)", "c") else { XCTAssert(false, "g(b)=c would be a rule"); return }
        XCTAssertEqual(0,fagx_fxx.criticalPeaks(gb_c).count)
        
        let peaks = gb_c.criticalPeaks(fagx_fxx)
        XCTAssertEqual(1, peaks.count, "one peak was expected")
        
        guard let (l2r1,p,l2,r2) = peaks.first else { XCTAssert(false, "one peak was expected"); return }
        
        XCTAssertEqual("f(a,c)",l2r1)
        XCTAssertEqual([2], p)
        XCTAssertEqual("f(a,g(b))", l2)
        XCTAssertEqual("f(b,b)", r2)
        
        XCTAssertTrue(gb_c.hasOverlap(at: p, with:fagx_fxx))
    }
    
    func testSymbols() {
        
        let tt_faa = TermType(faa)
        let tt_fxy = TermType(fxy)
        
        XCTAssertEqual("TptpTerm","\(tt_faa.dynamicType)")
        
        let soa_faa = tt_faa.countedSymbols
        let soa_fxy = tt_fxy.countedSymbols
        
        XCTAssertEqual(2, soa_faa.count)
        XCTAssertEqual(3, soa_fxy.count)
        
        let efaa = ["f":(count:1,arity:Set(arrayLiteral:2)), "a":(count:2,arity:Set(arrayLiteral:0))]
        let efxy = [
            "f":(count:1,arity:Set(arrayLiteral:2)),
            "X":(count:1,arity:Set<Int>()),
            "Y":(count:1,arity:Set<Int>())]
        
        XCTAssertTrue(efaa == soa_faa)
        XCTAssertTrue(efxy == soa_fxy)
        XCTAssertFalse(efaa == soa_fxy)
        
        let vo_faa = tt_faa.countedVariableSymbols
        let vo_fxy = tt_fxy.countedVariableSymbols
        
        XCTAssertEqual(0, vo_faa.count)
        XCTAssertEqual(2, vo_fxy.count)
        
        let vfaa = VariableSymbolCountDictonary()
        let vfxy = ["X":1,"Y":1]
        
        XCTAssertTrue(vfaa == vo_faa)
        XCTAssertTrue(vfxy == vo_fxy)
        XCTAssertFalse(vo_faa == vo_fxy)
    }
    
    func testCustomStringConvertible() {
        XCTAssertEqual("f(X,Y)=X", TermType(fxy_x!).description)
    }
    
    func testStringLiteralConvertible() {
        let variable = TermType(variable:"X")   // UPPER_WORD
        var expected = "X" as TermType
        XCTAssertEqual(variable, expected)
        
        let constant = TermType(constant:"a")   // LOWER_WORD
        XCTAssertEqual(constant, "a")
        
        let function = TermType(function:"f", terms: [variable, constant])
        XCTAssertEqual(function, "f(X,a)")
        
        let equation = TermType(predicate:"=", terms:[function,constant])
        XCTAssertEqual(equation, "f(X,a)=a")
        
        let inequation = TermType(predicate:"!=", terms:[function,constant])
        XCTAssertEqual(inequation, "f(X,a)!=a")
        
        let predicate = TermType(predicate:"p", terms:[variable,constant])
        XCTAssertEqual(predicate, "p(X,a)")
        
        let negation = TermType(connective:"~", terms: [predicate])
        XCTAssertEqual(negation, "~p(X,a)")
        
        var disjunction = TermType(connective:"|", terms:[equation, predicate, negation])
        XCTAssertEqual(disjunction, "f(X,a)=a | p(X,a) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "( f(X,a)=a | p(X,a) ) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "f(X,a)=a | ( p(X,a) | ~p(X,a) )")
        
        disjunction = TermType(connective:"|", terms:[equation, TermType(connective:"|", terms: [predicate,negation])])
        XCTAssertNotEqual(disjunction, "f(X,a)=a | p(X,a) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "( f(X,a)=a | p(X,a) ) | ~p(X,a)")
        XCTAssertEqual(disjunction, "f(X,a)=a | ( p(X,a) | ~p(X,a) )")
        
        var conjunction = TermType(connective:"&", terms:[equation, predicate, negation])
        XCTAssertEqual(conjunction, "f(X,a)=a & p(X,a) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "( f(X,a)=a & p(X,a) ) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "f(X,a)=a & ( p(X,a) & ~p(X,a) )")
        
        conjunction = TermType(connective:"&", terms:[equation, TermType(connective:"&", terms: [predicate,negation])])
        XCTAssertNotEqual(conjunction, "f(X,a)=a & p(X,a) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "( f(X,a)=a & p(X,a) ) & ~p(X,a)")
        XCTAssertEqual(conjunction, "f(X,a)=a & ( p(X,a) & ~p(X,a) )")
        
        var fof = TermType(connective:"|", terms:[equation, TermType(connective:"&", terms: [predicate,negation])])
        expected = "f(X,a)=a | (p(X,a) & ~p(X,a) )"
        XCTAssertEqual(fof, expected)
        
        fof = TermType(connective:"&", terms:[equation, TermType(connective:"|", terms: [predicate,negation])])
        expected = "f(X,a)=a & (p(X,a) | ~p(X,a)) "
        XCTAssertEqual(fof, expected)
        
        let universal = TermType(connective:"!", terms: [TermType(connective:",", terms:["X"]), disjunction])
        expected = "![X]:(f(X,a)=a | ( p(X,a) | ~p(X,a)) )"
        XCTAssertEqual(universal, expected)
        
        let existential = TermType(connective:"?", terms: [TermType(connective:",", terms:["X"]), disjunction])
        expected = "?[X]:(f(X,a)=a | ( p(X,a) | ~p(X,a)) )"
        XCTAssertEqual(existential, expected)
    }
    
    func testSubstitution() {
        var subs = [TermType: TermType]()
        
        // An empty term mapping is everything.
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
        
        // A term mapping, but not an substitution.
        subs = ["f(g(X,a))": "g(X)"] as [TermType: TermType]
        
        XCTAssertFalse(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertFalse(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // An substitution, but not a variable substitution.
        subs = ["X": "g(X)"] as [TermType: TermType]
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // A variable substitution, but not a renaming.
        subs = ["X": "Z"] as [TermType: TermType]
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // A renaming
        subs = ["X": "Y"] as [TermType: TermType]
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
    }
}