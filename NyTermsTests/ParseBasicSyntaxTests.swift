//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

/// Parse Tests with hardware verification files
/// - Problems/HWV/HWV134-1.p
/// - Problems/HWV/HWV105-1.p
/// - Problems/HWV/HWV134+1.p
/// - Problems/HWV/HWV062+1.p
class ParseBasicSyntaxTests: XCTestCase {

    typealias MyTestTerm = TermSampleStruct

    func check(path:String, limit:NSTimeInterval, count:Int) -> ([TptpFormula],[TptpInclude]) {
        
        let start = NSDate()
        let (result,tptpFormulae,tptpIncludes) = parsePath(path)
        let total = NSDate().timeIntervalSinceDate(start)
        
        let name = (path as NSString).lastPathComponent
        
        XCTAssertEqual(0, result[0], path)
        XCTAssertEqual(count,tptpFormulae.count, path)
        
        let average = total / Double(tptpFormulae.count)
        
        let message = "'\(name)' total:\(Double(Int(total*1000))/1000.0)s, limit:\(limit)s, count:\(tptpFormulae.count) avg:\(Double(Int(average*1000_000))/1000.0)ms"
        XCTAssertTrue(total < limit, message)
        print("// (\(NSDate())) \(SymbolTable.info)\n// *** \(message) *** ")
        return (tptpFormulae, tptpIncludes)
    }
    
    // MARK - parse cfn files
    
    func testParseHWV134cfn1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
        let (tptpFormulae,_) = check(path, limit:150, count: 2_332_428)
        // *** 'HWV134-1.p' total:74.974s, limit:150.0s, count:2332428 avg:0.032ms *** (2015-08-29 11:43:46 +0000)
        // *** 'HWV134-1.p' total:70.208s, limit:150.0s, count:2332428 avg:0.030ms *** (2015-09-17 13:23:36 +0000)
        // *** 'HWV134-1.p' total:45.392s, limit:150.0s, count:2332428 avg:0.019ms *** (2015-10-05 09:42:29 +0000) (26) MacBookPro
        
        let myformula = MyTestTerm(tptpFormulae[2_332_427].formula)
        XCTAssertEqual("~(v437(VarCurr,bitIndex128))|v4403(VarCurr,bitIndex0)", myformula.description)
        
    }
    
    func testParseHWV105cfn1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
        let (tptpFormulae,_) = check(path, limit:1.5, count: 20_900)  // <1s
        // *** 'HWV105-1.p' total:0.737s, limit:1.5s, count:20900 avg:0.035ms *** (2015-08-29 11:42:31 +0000)
        // *** 'HWV105-1.p' total:0.712s, limit:1.5s, count:20900 avg:0.034ms *** (2015-09-17 13:22:26 +0000)
        // *** 'HWV105-1.p' total:0.438s, limit:1.5s, count:20900 avg:0.02ms *** (2015-10-05 09:41:43 +0000) (26) MacBookPro
        let myformula = tptpFormulae[20_899]
        XCTAssertEqual("u61248", myformula.name)
        XCTAssertEqual(TptpRole.Axiom, myformula.role)
        
        let myterm = MyTestTerm(myformula.formula)
        XCTAssertEqual("~(v2339(VarCurr,bitIndex5))|v2338(VarCurr,bitIndex129)", myterm.description)
        
    }
    
    // MARK - parse fof files
    
    func testParseHWV134fof1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134+1.p"
        let (tptpFormulae,_) = check(path, limit:90.0, count: 128_975)
        // *** 'HWV134+1.p' total:42.162s, limit:90.0s, count:128975 avg:0.326ms *** (2015-08-29 11:44:30 +0000)
        // *** 'HWV134+1.p' total:41.537s, limit:90.0s, count:128975 avg:0.322ms *** (2015-09-17 13:24:20 +0000)
        // *** 'HWV134+1.p' total:18.978s, limit:90.0s, count:128975 avg:0.147ms *** (2015-10-05 09:42:48 +0000) (26) MacBookPro
        
        let myformula = MyTestTerm(tptpFormulae[128_974].formula)
        XCTAssertEqual("(![VarCurr]:(v34(VarCurr)<=>v36(VarCurr)))", myformula.description)
    }
    
    func testParseHWV062fof1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV062+1.p"
        let (tptpFormulae,_) = check(path, limit:2, count: 2) // 209
        // *** 'HWV062+1.p' total:0.93s, limit:2.0s, count:2 avg:465.016ms *** (2015-08-29 11:42:18 +0000)
        // *** 'HWV062+1.p' total:0.837s, limit:2.0s, count:2 avg:418.707ms *** (2015-09-17 13:22:14 +0000)
        // *** 'HWV062+1.p' total:0.479s, limit:2.0s, count:2 avg:239.766ms *** (2015-10-05 09:41:32 +0000) (26) MacBookPro
        
        let last = MyTestTerm(tptpFormulae.last!.formula)
        XCTAssertEqual("!=", last.symbol)
        XCTAssertNotNil(last.symbol.quadruple)
        let quadruple = last.symbol.quadruple!
        
        XCTAssertEqual(SymbolNotation.Infix, quadruple.notation)
        let actual = last.description
        
        XCTAssertEqual("true!=false", actual)
        
        let forall = tptpFormulae.first!.formula
        XCTAssertEqual("?", forall.symbol)
        XCTAssertEqual(2,forall.terms!.count)
        
        // let forallvars = forall.terms!.first!
        let forallvars = forall[[1]]!
        XCTAssertEqual(",", forallvars.symbol)
        XCTAssertEqual(332, forallvars.terms!.count)
        
        // let exists = forall.terms!.last!
        let exists = forall[[2]]!
        XCTAssertEqual("!", exists.symbol)
        XCTAssertEqual(2,exists.terms!.count)
        
        // let existsvars = exists.terms!.first!
        let existsvars = forall[[2,1]]!
        XCTAssertEqual(",", existsvars.symbol)
        XCTAssertEqual(4, existsvars.terms!.count)
        
        // let forall2 = exists.terms!.last!
        let forall2 = forall[[2,2]]!
        XCTAssertEqual("?", forall2.symbol)
        XCTAssertEqual(2,forall2.terms!.count)
        
        // let forall2vars = forall2.terms!.first!
        let forall2vars = forall[[2,2,1]]!
        XCTAssertEqual(",", forall2vars.symbol)
        XCTAssertEqual(16448, forall2vars.terms!.count)
        
        for (index,term) in forall2vars.terms!.enumerate() {
            let symbol = "V\(index+1)"
            // if index > 3 { break; }
            XCTAssertEqual(symbol, term.symbol)
        }
        
        // let conjunction = forall2.terms!.last!
        let conjunction = forall[[2,2,2]]!
        XCTAssertEqual("&", conjunction.symbol)
        
        let expected = 39512;
        XCTAssertEqual(expected, conjunction.terms!.count)
        XCTAssertEqual(1, conjunction.terms![0].terms!.count)   // 36
        XCTAssertEqual(1, conjunction.terms![1].terms!.count)   // 37
        XCTAssertEqual(2, conjunction.terms![2].terms!.count)   // 38
        XCTAssertEqual(2, conjunction.terms![3].terms!.count)   // 40
        XCTAssertEqual(2, conjunction.terms![4].terms!.count)   // 42
        XCTAssertEqual(2, conjunction.terms![5].terms!.count)   // 44
        XCTAssertEqual(3, conjunction.terms![6].terms!.count)   // 46
        XCTAssertEqual(3, conjunction.terms![7].terms!.count)   // 49
        XCTAssertEqual(2, conjunction.terms![8].terms!.count)   // 52
        XCTAssertEqual(2, conjunction.terms![9].terms!.count)   // 54
        XCTAssertEqual(3, conjunction.terms![10].terms!.count)   // 56
        
        
        XCTAssertEqual(2, conjunction.terms![25].terms!.count)  // 92
        XCTAssertEqual(2, conjunction.terms![26].terms!.count)  // 94
        XCTAssertEqual(2, conjunction.terms![27].terms!.count)  // 96
        XCTAssertEqual(6, conjunction.terms![28].terms!.count)  // 98
        XCTAssertEqual(2, conjunction.terms![29].terms!.count)  // 104
        
        XCTAssertEqual(2, conjunction.terms![50].terms!.count)
        XCTAssertEqual(2, conjunction.terms![100].terms!.count)
        XCTAssertEqual(2, conjunction.terms![250].terms!.count)
        XCTAssertEqual(2, conjunction.terms![500].terms!.count)
        XCTAssertEqual(2, conjunction.terms![1000].terms!.count)
        XCTAssertEqual(2, conjunction.terms![2500].terms!.count)
        XCTAssertEqual(2, conjunction.terms![5000].terms!.count)
        XCTAssertEqual(2, conjunction.terms![10000].terms!.count)
        XCTAssertEqual(2, conjunction.terms![20000].terms!.count)
        XCTAssertEqual(3, conjunction.terms![30000].terms!.count)

        
        XCTAssertEqual(2, conjunction.terms![expected-2].terms!.count)      // 95563
        XCTAssertEqual("p(V6641)|p(V6673)", conjunction.terms![expected-2].description)
        
        XCTAssertEqual(3, conjunction.terms!.last!.terms!.count)    // 95565
        XCTAssertEqual("|", conjunction.terms!.last!.symbol)
        XCTAssertEqual("~(p(V2912))|p(V2896)|~(p(V2932))", conjunction.terms!.last!.description)
        
        let terms = tptpFormulae.map { TermSampleStruct($0.formula) }
        XCTAssertEqual(2,terms.count)
        
        let a = terms.first!.terms!.last!.terms!.last!.terms!.last!
        XCTAssertEqual("&", a.symbol)
        XCTAssertEqual(expected, a.terms!.count)
        
        let b = terms[[1,2,2,2]]!   // terms[0][[2,2,2]] position 1 is array index 0
        XCTAssertEqual(a, b)
        
        let bvars = b.allVariables
        let cvars = conjunction.allVariables
        
        XCTAssertEqual(cvars.count, bvars.count)
        let cbvars = Set(bvars.map { TptpTerm($0) })
        XCTAssertEqual(cvars, cbvars)
        
        XCTAssertEqual(15312, b.allVariables.count)
    }
}
