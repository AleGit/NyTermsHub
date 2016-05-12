//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

/// Parse hardware verification files
class ParseBasicSyntaxTests: XCTestCase {
    
    typealias MyTestTerm = NodeStruct
    
    /// Parse LCL129-1.p and construct tree representation. ~8 MB, 8 ms
    func testParseLCL129cnf1() {
        let expected = 0.009;
        let ((result,tptpFormulae,tptpIncludes),runtime) = measure {
            parse(path:"LCL129-1".p!)
        }
        XCTAssertTrue(runtime <= expected * Process.benchmark,"runtime \(runtime.prettyTimeIntervalDescription) ≰ \(expected.prettyTimeIntervalDescription),\((expected*Process.benchmark).prettyTimeIntervalDescription),")
        print(runtime, expected, expected*Process.benchmark, Process.benchmark)
        
        
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(3, tptpFormulae.count)
        XCTAssertEqual(0, tptpIncludes.count)
        
        XCTAssertEqual("~(is_a_theorem(equivalent(X,Y)))|~(is_a_theorem(X))|is_a_theorem(Y)", tptpFormulae[0].root.description)
        XCTAssertEqual("is_a_theorem(equivalent(equivalent(X,equivalent(Y,Z)),equivalent(equivalent(X,equivalent(U,Z)),equivalent(Y,U))))", tptpFormulae[1].root.description)
        XCTAssertEqual("~(is_a_theorem(equivalent(a,equivalent(a,equivalent(equivalent(b,c),equivalent(equivalent(b,e),equivalent(c,e)))))))", tptpFormulae[2].root.description)
        
        let size = tptpFormulae.reduce(0) {
            $0 + $1.root.size
        }
        XCTAssertEqual(46, size)
    }
    
    /// Parse HWV105-1.p and construct tree representation. ~90 MB, 4s
    func testParseHWV105cnf1() {
        let expected = 5.0;
        let (_,runtime) = measure {
            
            let path = "HWV105-1".p!
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(20_900, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
            
            let myformula = tptpFormulae[20_899]
            XCTAssertEqual("u61248", myformula.name)
            XCTAssertEqual(TptpRole.Axiom, myformula.role)
            
            let myterm = MyTestTerm(myformula.root)
            XCTAssertEqual("~(v2339(VarCurr,bitIndex5))|v2338(VarCurr,bitIndex129)", myterm.description)
            
            let size = tptpFormulae.reduce(0) {
                $0 + $1.root.size
            }
            XCTAssertEqual(194_250, size)
        }
        XCTAssertTrue(runtime <= expected,"runtime \(runtime.prettyTimeIntervalDescription) ≰ \(expected.prettyTimeIntervalDescription)")
        
    }
    
    /// Parse HWV062+1.p and construct tree representation. ~285 MB, 30s
    func testParseHWV062fof1() {
        let expected = 5.0;
        let (_,runtime) = measure {
            let path = "HWV062+1".p!
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
            
            let last = MyTestTerm(tptpFormulae.last!.root)
            XCTAssertEqual("!=", last.symbol)
            XCTAssertNotNil(last.symbolQuadruple())
            let quartuple = last.symbolQuadruple()!
            
            XCTAssertEqual(SymbolNotation.Infix, quartuple.notation)
            let actual = last.description
            
            XCTAssertEqual("true!=false", actual)
            
            let forall = tptpFormulae.first!.root
            XCTAssertEqual("?", forall.symbol)
            XCTAssertEqual(2,forall.nodes!.count)
            
            // let forallvars = forall.nodes!.first!
            let forallvars = forall[[0]]!                   // positions start at 0
            XCTAssertEqual(",", forallvars.symbol)
            XCTAssertEqual(332, forallvars.nodes!.count)
            
            // let exists = forall.nodes!.last!
            let exists = forall[[1]]!                       // positions start at 0
            XCTAssertEqual("!", exists.symbol)
            XCTAssertEqual(2,exists.nodes!.count)
            
            // let existsvars = exists.nodes!.first!
            let existsvars = forall[[1,0]]!                 // positions start at 0
            XCTAssertEqual(",", existsvars.symbol)
            XCTAssertEqual(4, existsvars.nodes!.count)
            
            // let forall2 = exists.nodes!.last!
            let forall2 = forall[[1,1]]!                    // positions start at 0
            XCTAssertEqual("?", forall2.symbol)
            XCTAssertEqual(2,forall2.nodes!.count)
            
            // let forall2vars = forall2.nodes!.first!
            let forall2vars = forall[[1,1,0]]!              // positions start at 0
            XCTAssertEqual(",", forall2vars.symbol)
            XCTAssertEqual(16448, forall2vars.nodes!.count)
            
            for (index,term) in forall2vars.nodes!.enumerate() {
                let symbol = "V\(index+1)"
                // if index > 3 { break; }
                XCTAssertEqual(symbol, term.symbol)
            }
            
            // let conjunction = forall2.nodes!.last!
            let conjunction = forall[[1,1,1]]!              // positions start at 0
            XCTAssertEqual("&", conjunction.symbol)
            
            let expected = 39512;
            XCTAssertEqual(expected, conjunction.nodes!.count)
            XCTAssertEqual(1, conjunction.nodes![0].nodes!.count)   // 36
            XCTAssertEqual(1, conjunction.nodes![1].nodes!.count)   // 37
            XCTAssertEqual(2, conjunction.nodes![2].nodes!.count)   // 38
            XCTAssertEqual(2, conjunction.nodes![3].nodes!.count)   // 40
            XCTAssertEqual(2, conjunction.nodes![4].nodes!.count)   // 42
            XCTAssertEqual(2, conjunction.nodes![5].nodes!.count)   // 44
            XCTAssertEqual(3, conjunction.nodes![6].nodes!.count)   // 46
            XCTAssertEqual(3, conjunction.nodes![7].nodes!.count)   // 49
            XCTAssertEqual(2, conjunction.nodes![8].nodes!.count)   // 52
            XCTAssertEqual(2, conjunction.nodes![9].nodes!.count)   // 54
            XCTAssertEqual(3, conjunction.nodes![10].nodes!.count)   // 56
            
            XCTAssertEqual(2, conjunction.nodes![25].nodes!.count)  // 92
            XCTAssertEqual(2, conjunction.nodes![26].nodes!.count)  // 94
            XCTAssertEqual(2, conjunction.nodes![27].nodes!.count)  // 96
            XCTAssertEqual(6, conjunction.nodes![28].nodes!.count)  // 98
            XCTAssertEqual(2, conjunction.nodes![29].nodes!.count)  // 104
            
            XCTAssertEqual(2, conjunction.nodes![50].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![100].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![250].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![500].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![1000].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![2500].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![5000].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![10000].nodes!.count)
            XCTAssertEqual(2, conjunction.nodes![20000].nodes!.count)
            XCTAssertEqual(3, conjunction.nodes![30000].nodes!.count)
            
            XCTAssertEqual(2, conjunction.nodes![expected-2].nodes!.count)      // 95563
            XCTAssertEqual("p(V6641)|p(V6673)", conjunction.nodes![expected-2].description)
            
            XCTAssertEqual(3, conjunction.nodes!.last!.nodes!.count)    // 95565
            XCTAssertEqual("|", conjunction.nodes!.last!.symbol)
            XCTAssertEqual("~(p(V2912))|p(V2896)|~(p(V2932))", conjunction.nodes!.last!.description)
            
            let nodes = tptpFormulae.map { NodeStruct($0.root) }
            XCTAssertEqual(2,nodes.count)
            
            let a = nodes.first!.nodes!.last!.nodes!.last!.nodes!.last!
            XCTAssertEqual("&", a.symbol)
            XCTAssertEqual(expected, a.nodes!.count)
            
            let b = nodes[[0,1,1,1]]!   // nodes[0][[2,2,2]] position 0 is array index 0
            XCTAssertEqual(a, b)
            
            let bvars = b.allVariables
            let cvars = conjunction.allVariables
            
            XCTAssertEqual(cvars.count, bvars.count)
            let cbvars = Set(bvars.map { TptpNode($0) })
            XCTAssertEqual(cvars, cbvars)
            
            XCTAssertEqual(15_312, b.allVariables.count)
            
            let size = tptpFormulae.reduce(0) {
                $0 + $1.root.size
            }
            XCTAssertEqual(293_916, size)
        }
        XCTAssertTrue(runtime <= expected,"runtime \(runtime.prettyTimeIntervalDescription) ≰ \(expected.prettyTimeIntervalDescription)")
    }
    
    /// Parse HWV134+1.p and construct tree representation. ~3 GB, 120s
    func testParseHWV134fof1() {
        let expected = 180.0;
        //        let ((result,tptpFormulae,tptpIncludes),runtime) = measure {
        //            () -> ([Int],[TptpFormula],[TptpInclude]) in
        //
        //            let path = "HWV134+1".p!
        //
        //            return parse(path:path)
        //
        //        }
        let ((result,tptpFormulae,tptpIncludes),runtime) = measure {
            parse(path:"HWV134+1".p!)
            
        }
        XCTAssertTrue(runtime <= expected,"runtime \(runtime.prettyTimeIntervalDescription) ≰ \(expected.prettyTimeIntervalDescription)")
        
        print(runtime/Process.benchmark, expected/Process.benchmark)
        
        XCTAssertEqual(1, result.count)
        XCTAssertEqual(0, result[0])
        XCTAssertEqual(128_975, tptpFormulae.count)
        XCTAssertEqual(0, tptpIncludes.count)
        
        let myformula = MyTestTerm(tptpFormulae[128_974].root)
        XCTAssertEqual("(![VarCurr]:(v34(VarCurr)<=>v36(VarCurr)))", myformula.description)
        
        let size = tptpFormulae.reduce(0) {
            $0 + $1.root.size
        }
        XCTAssertEqual(7_131_470, size)
    }
    
    
    /// Parse HWV134-1.p and construct tree representation. ~10 GB, 600s
    func testParseHWV134cnf1() {
        let expected = 5.0;
        let (_,runtime) = measure {
            let path = "HWV134-1".p!
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1, result.count)
            XCTAssertEqual(0, result[0])
            XCTAssertEqual(2_332_428, tptpFormulae.count)
            XCTAssertEqual(0, tptpIncludes.count)
            
            let myformula = MyTestTerm(tptpFormulae[2_332_427].root)
            XCTAssertEqual("~(v437(VarCurr,bitIndex128))|v4403(VarCurr,bitIndex0)", myformula.description)
            
            let size = tptpFormulae.reduce(0) {
                $0 + $1.root.size
            }
            
            XCTAssertEqual(25_288_469, size)
        }
        XCTAssertTrue(runtime <= expected,"runtime \(runtime.prettyTimeIntervalDescription) ≰ \(expected.prettyTimeIntervalDescription)")
    }
    
}
