//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
import NyTerms

// MARK: - term implementation

/// Struct `NodeStruct` is a sample implementation of protocol `Node` for testing purposes only.
/// Basically just the data representation has to be defined, but nearly no functions.
struct NodeStruct : Node {
    let symbol : String
    let nodes : [NodeStruct]?
}

extension NodeStruct : StringLiteralConvertible {
    // TODO: Implementation of `StringLiteralConvertible` should not depend on `TptpNode`.
    init(stringLiteral value: StringLiteralType) {
        self = NodeStruct(TptpNode(stringLiteral:value))
    }
}

// MARK: - term tests

/// Tests for default implementation of protocol term with **swift struct** data structure.
class NodeStructTests: XCTestCase {
    
    private typealias LocalTestNode = NodeStruct
    
    func testEquals() {
        XCTAssertEqual("a", LocalTestNode(a))
        XCTAssertEqual(LocalTestNode(constant:"a"), LocalTestNode(a))
        XCTAssertEqual("b", LocalTestNode(b))
        XCTAssertEqual("c", LocalTestNode(c))
        XCTAssertEqual("X", LocalTestNode(x))
        XCTAssertEqual(LocalTestNode(variable:"X"), LocalTestNode(x))
        XCTAssertEqual("Y", LocalTestNode(y))
        XCTAssertEqual("Z", LocalTestNode(z))
        XCTAssertEqual("f(X,Y)", LocalTestNode(fxy))
        XCTAssertEqual(LocalTestNode(function:"f",nodes: ["X","Y"]), LocalTestNode(fxy))
        XCTAssertEqual(LocalTestNode(function:"f",nodes: [LocalTestNode(variable:"X"),LocalTestNode(variable:"Y")]), LocalTestNode(fxy))
        XCTAssertEqual("f(a,X)", LocalTestNode(fax))
        XCTAssertEqual("f(X,a)", LocalTestNode(fxa))
        XCTAssertEqual("f(a,a)", LocalTestNode(faa))
        XCTAssertEqual("g(X)", LocalTestNode(gx))
        XCTAssertEqual("g(b)", LocalTestNode(gb))
        let rule = LocalTestNode.Rule("f(X,Y)","X")!
        XCTAssertEqual(rule, LocalTestNode(fxy_x!))
    }
    
    func testCriticalPeaks() {
        guard let fagx_fxx = LocalTestNode.Rule("f(a,g(X))", "f(X,X)") else { XCTAssert(false, "f(a,g(X))=f(X,X) would be a rule."); return }
        guard let gb_c = LocalTestNode.Rule("g(b)", "c") else { XCTAssert(false, "g(b)=c would be a rule"); return }
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
        
        let tt_faa = LocalTestNode(faa)
        let tt_fxy = LocalTestNode(fxy)
        
        XCTAssertEqual("NodeStruct","\(tt_faa.dynamicType)")
        
        let soa_faa = tt_faa.countedSymbols
        let soa_fxy = tt_fxy.countedSymbols
        
        XCTAssertEqual(2, soa_faa.count)
        XCTAssertEqual(3, soa_fxy.count)
        
        let efaa = ["f":(count:1,arities:Set(arrayLiteral:2)), "a":(count:2,arities:Set(arrayLiteral:0))]
        let efxy = [
            "f":(count:1,arities:Set(arrayLiteral:2)),
            "X":(count:1,arities:Set<Int>()),
            "Y":(count:1,arities:Set<Int>())]
        
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
        XCTAssertEqual("f(X,Y)=X", LocalTestNode(fxy_x!).description)
    }
    
    func testStringLiteralConvertible() {
        let variable = LocalTestNode(variable:"X")   // UPPER_WORD
        var expected = "X" as LocalTestNode
        XCTAssertEqual(variable, expected)
        
        let constant = LocalTestNode(constant:"a")   // LOWER_WORD
        XCTAssertEqual(constant, "a")
        
        let function = LocalTestNode(function:"f", nodes: [variable, constant])
        XCTAssertEqual(function, "f(X,a)")
        
        let equation = LocalTestNode(predicate:"=", nodes:[function,constant])
        XCTAssertEqual(equation, "f(X,a)=a")
        
        let inequation = LocalTestNode(predicate:"!=", nodes:[function,constant])
        XCTAssertEqual(inequation, "f(X,a)!=a")
        
        let predicate = LocalTestNode(predicate:"p", nodes:[variable,constant])
        XCTAssertEqual(predicate, "p(X,a)")
        
        let negation = LocalTestNode(connective:"~", nodes: [predicate])
        XCTAssertEqual(negation, "~p(X,a)")
        
        var disjunction = LocalTestNode(connective:"|", nodes:[equation, predicate, negation])
        XCTAssertEqual(disjunction, "f(X,a)=a | p(X,a) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "( f(X,a)=a | p(X,a) ) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "f(X,a)=a | ( p(X,a) | ~p(X,a) )")
        
        disjunction = LocalTestNode(connective:"|", nodes:[equation, LocalTestNode(connective:"|", nodes: [predicate,negation])])
        XCTAssertNotEqual(disjunction, "f(X,a)=a | p(X,a) | ~p(X,a)")
        XCTAssertNotEqual(disjunction, "( f(X,a)=a | p(X,a) ) | ~p(X,a)")
        XCTAssertEqual(disjunction, "f(X,a)=a | ( p(X,a) | ~p(X,a) )")
        
        var conjunction = LocalTestNode(connective:"&", nodes:[equation, predicate, negation])
        XCTAssertEqual(conjunction, "f(X,a)=a & p(X,a) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "( f(X,a)=a & p(X,a) ) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "f(X,a)=a & ( p(X,a) & ~p(X,a) )")
        
        conjunction = LocalTestNode(connective:"&", nodes:[equation, LocalTestNode(connective:"&", nodes: [predicate,negation])])
        XCTAssertNotEqual(conjunction, "f(X,a)=a & p(X,a) & ~p(X,a)")
        XCTAssertNotEqual(conjunction, "( f(X,a)=a & p(X,a) ) & ~p(X,a)")
        XCTAssertEqual(conjunction, "f(X,a)=a & ( p(X,a) & ~p(X,a) )")
        
        var fof = LocalTestNode(connective:"|", nodes:[equation, LocalTestNode(connective:"&", nodes: [predicate,negation])])
        expected = "f(X,a)=a | (p(X,a) & ~p(X,a) )"
        XCTAssertEqual(fof, expected)
        
        fof = LocalTestNode(connective:"&", nodes:[equation, LocalTestNode(connective:"|", nodes: [predicate,negation])])
        expected = "f(X,a)=a & (p(X,a) | ~p(X,a)) "
        XCTAssertEqual(fof, expected)
        
        let universal = LocalTestNode(connective:"!", nodes: [LocalTestNode(connective:",", nodes:["X"]), disjunction])
        expected = "![X]:(f(X,a)=a | ( p(X,a) | ~p(X,a)) )"
        XCTAssertEqual(universal, expected)
        
        let existential = LocalTestNode(connective:"?", nodes: [LocalTestNode(connective:",", nodes:["X"]), disjunction])
        expected = "?[X]:(f(X,a)=a | ( p(X,a) | ~p(X,a)) )"
        XCTAssertEqual(existential, expected)
    }
    
    func testSubstitution() {
        var subs = [LocalTestNode: LocalTestNode]()
        
        // An empty term mapping is everything.
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
        
        // A term mapping, but not an substitution.
        subs = ["f(g(X,a))": "g(X)"] as [LocalTestNode: LocalTestNode]
        
        XCTAssertFalse(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertFalse(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // An substitution, but not a variable substitution.
        subs = ["X": "g(X)"] as [LocalTestNode: LocalTestNode]
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertFalse(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // A variable substitution, but not a renaming.
        subs = ["X": "Z"] as [LocalTestNode: LocalTestNode]
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertFalse(subs.isRenaming)
        
        // A renaming
        subs = ["X": "Y"] as [LocalTestNode: LocalTestNode]
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
        
        subs["Y"] = "Z"
        
        XCTAssertTrue(subs.isSubstitution)
        XCTAssertTrue(subs.isVariableSubstitution)
        XCTAssertTrue(subs.isRenaming)
    }
}