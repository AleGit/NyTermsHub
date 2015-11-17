//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

/// Parse hardware verification files
/// - Problems/HWV/HWV134-1.p (41.0 seconds)
/// - Problems/HWV/HWV105-1.p ( 0.4 seconds)
/// - Problems/HWV/HWV134+1.p (17.3 seconds)
/// - Problems/HWV/HWV062+1.p (10.5 seconds)
class ParseBasicSyntaxTests: XCTestCase {

    typealias MyTestTerm = NodeStruct

    func check(path:String, limit:NSTimeInterval, count:Int) -> ([TptpFormula],[TptpInclude]) {
        
        let start = NSDate()
        let (result,tptpFormulae,tptpIncludes) = parse(path:path)
        let total = NSDate().timeIntervalSinceDate(start)
        
        let name = (path as NSString).lastPathComponent
        
        XCTAssertEqual(0, result[0], path)
        XCTAssertEqual(count,tptpFormulae.count, path)
        
        let average = total / Double(tptpFormulae.count)
        
        let message = "'\(name)' total:\(Double(Int(total*1000))/1000.0)s, limit:\(limit)s, count:\(tptpFormulae.count) avg:\(Double(Int(average*1000_000))/1000.0)ms"
        XCTAssertTrue(total < limit, message)
        print(message, NSDate())
        
        return (tptpFormulae, tptpIncludes)
    }
    
    // MARK - parse cfn files
    
    /// Parse HWV134-1.p and construct tree representation.
    func testParseHWV134cfn1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134-1.p"
        let limit : NSTimeInterval = 200.0
        let (tptpFormulae,_) = check(path, limit:limit, count: 2_332_428)
        // 'HWV134-1.p' total:74.974s, limit:99.0s, count:2332428 avg:0.032ms (2015-08-29 11:43:46 +0000)
        // 'HWV134-1.p' total:70.208s, limit:99.0s, count:2332428 avg:0.030ms (2015-09-17 13:23:36 +0000)
        // 'HWV134-1.p' total:45.392s, limit:99.0s, count:2332428 avg:0.019ms (2015-10-05 09:42:29 +0000) (26) MacBookPro
        // 'HWV134-1.p' total:42.139s, limit:99.0s, count:2332428 avg:0.018ms (2015-10-22 14:17:27 +0000) (27) Mac mini
        // 'HWV134-1.p' total:40.049s, limit:45.0s, count:2332428 avg:0.017ms (2015-11-12 08:08:01 +0100) Mac mini, Swift 2.1
        // 'HWV134-1.p' total:44.083s, limit:49.0s, count:2332428 avg:0.018ms (2015-11-17 06:25:06 +0000) -"-
        // 'HWV134-1.p' total:199.212s, limit:200.0s, count:2332428 avg:0.085ms (2015-11-17 16:31:50 +00) -"-, unoptimized
        
        let myformula = MyTestTerm(tptpFormulae[2_332_427].root)
        XCTAssertEqual("~(v437(VarCurr,bitIndex128))|v4403(VarCurr,bitIndex0)", myformula.description)
        
    }
    
    /// Parse HWV105-1.p and construct tree representation.
    func testParseHWV105cfn1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV105-1.p"
        let limit : NSTimeInterval = 3.0
        let (tptpFormulae,_) = check(path, limit:limit, count: 20_900)  // <1s
        // 'HWV105-1.p' total:0.737s, limit:1.5s, count:20900 avg:0.035ms (2015-08-29 11:42:31 +0000)
        // 'HWV105-1.p' total:0.712s, limit:1.5s, count:20900 avg:0.034ms (2015-09-17 13:22:26 +0000)
        // 'HWV105-1.p' total:0.438s, limit:1.5s, count:20900 avg:0.020ms (2015-10-05 09:41:43 +0000) (26) MacBookPro
        // 'HWV105-1.p' total:0.383s, limit:1.5s, count:20900 avg:0.018ms (2015-10-22 14:16:44 +0000) (27) Mac mini
        // 'HWV105-1.p' total:0.337s, limit:1.0s, count:20900 avg:0.016ms (2015-11-12 08:06:33 +0100) Mac mini, Swift 2.1
        // 'HWV105-1.p' total:0.401s, limit:1.0s, count:20900 avg:0.019ms (2015-11-17 06:24:22 +0000) -"-
        // 'HWV105-1.p' total:1.564s, limit:3.0s, count:20900 avg:0.074ms (2015-11-17 16:28:30 +0000) -"-, unoptimized
        let myformula = tptpFormulae[20_899]
        XCTAssertEqual("u61248", myformula.name)
        XCTAssertEqual(TptpRole.Axiom, myformula.role)
        
        let myterm = MyTestTerm(myformula.root)
        XCTAssertEqual("~(v2339(VarCurr,bitIndex5))|v2338(VarCurr,bitIndex129)", myterm.description)
        
    }
    
    // MARK - parse fof files
    
    /// Parse HWV134+1.p and construct tree representation in less than 19 seconds.
    func testParseHWV134fof1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV134+1.p"
        let limit : NSTimeInterval = 70.0
        let (tptpFormulae,_) = check(path, limit:limit, count: 128_975)
        // 'HWV134+1.p' total:42.162s, limit:90.0s, count:128975 avg:0.326ms (2015-08-29 11:44:30 +0000)
        // 'HWV134+1.p' total:41.537s, limit:90.0s, count:128975 avg:0.322ms (2015-09-17 13:24:20 +0000)
        // 'HWV134+1.p' total:18.978s, limit:90.0s, count:128975 avg:0.147ms (2015-10-05 09:42:48 +0000) MacBookPro
        // 'HWV134+1.p' total:17.459s, limit:90.0s, count:128975 avg:0.135ms (2015-10-22 14:17:44 +0000) Mac mini
        // 'HWV134+1.p' total:12.155s, limit:20.0s, count:128975 avg:0.094ms (2015-11-12 08:04:06 +0100) Mac mini, Swift 2.1
        // 'HWV134+1.p' total:17.803s, limit:20.0s, count:128975 avg:0.138ms (2015-11-17 06:25:24 +0000) -"-
        // 'HWV134+1.p' total:63.087s, limit:70.0s, count:128975 avg:0.489ms (2015-11-17 16:33:00 +0000) -"-, unoptimized
        
        let myformula = MyTestTerm(tptpFormulae[128_974].root)
        XCTAssertEqual("(![VarCurr]:(v34(VarCurr)<=>v36(VarCurr)))", myformula.description)
    }
    
    /// Parse HWV062+1.p and construct tree representation in less than a second.
    func testParseHWV062fof1() {
        let path = "/Users/Shared/TPTP/Problems/HWV/HWV062+1.p"
        let limit : NSTimeInterval = 3.0
        let (tptpFormulae,_) = check(path, limit:limit, count: 2) // 209
        // 'HWV062+1.p' total:0.930s, limit:2.0s, count:2 avg:465.016ms (2015-08-29 11:42:18 +0000)
        // 'HWV062+1.p' total:0.837s, limit:2.0s, count:2 avg:418.707ms (2015-09-17 13:22:14 +0000)
        // 'HWV062+1.p' total:0.479s, limit:2.0s, count:2 avg:239.766ms (2015-10-05 09:41:32 +0000) MacBookPro
        // 'HWV062+1.p' total:0.504s, limit:2.0s, count:2 avg:252.009ms (2015-10-22 14:16:34 +0000) Mac mini
        // 'HWV062+1.p' total:0.458s, limit:0.9s, count:2 avg:229.370ms (2015-11-12 08:01:24 +0100) Mac mini, Swift 2.1
        // 'HWV062+1.p' total:0.493s, limit:1.0s, count:2 avg:246.690ms (2015-11-17 06:24:12 +0000) -"-
        // 'HWV062+1.p' total:2.852s, limit:3.0s, count:2 avg:1426.434ms 2015-11-17 16:28:17 +0000) -"-, unoptimized
        
        let last = MyTestTerm(tptpFormulae.last!.root)
        XCTAssertEqual("!=", last.symbol)
        XCTAssertNotNil(Symbols.defaultSymbols[last.symbol])
        let quadruple = Symbols.defaultSymbols[last.symbol]!
        
        XCTAssertEqual(SymbolNotation.Infix, quadruple.notation)
        let actual = last.description
        
        XCTAssertEqual("true!=false", actual)
        
        let forall = tptpFormulae.first!.root
        XCTAssertEqual("?", forall.symbol)
        XCTAssertEqual(2,forall.nodes!.count)
        
        // let forallvars = forall.nodes!.first!
        let forallvars = forall[[1]]!
        XCTAssertEqual(",", forallvars.symbol)
        XCTAssertEqual(332, forallvars.nodes!.count)
        
        // let exists = forall.nodes!.last!
        let exists = forall[[2]]!
        XCTAssertEqual("!", exists.symbol)
        XCTAssertEqual(2,exists.nodes!.count)
        
        // let existsvars = exists.nodes!.first!
        let existsvars = forall[[2,1]]!
        XCTAssertEqual(",", existsvars.symbol)
        XCTAssertEqual(4, existsvars.nodes!.count)
        
        // let forall2 = exists.nodes!.last!
        let forall2 = forall[[2,2]]!
        XCTAssertEqual("?", forall2.symbol)
        XCTAssertEqual(2,forall2.nodes!.count)
        
        // let forall2vars = forall2.nodes!.first!
        let forall2vars = forall[[2,2,1]]!
        XCTAssertEqual(",", forall2vars.symbol)
        XCTAssertEqual(16448, forall2vars.nodes!.count)
        
        for (index,term) in forall2vars.nodes!.enumerate() {
            let symbol = "V\(index+1)"
            // if index > 3 { break; }
            XCTAssertEqual(symbol, term.symbol)
        }
        
        // let conjunction = forall2.nodes!.last!
        let conjunction = forall[[2,2,2]]!
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
        
        let b = nodes[[1,2,2,2]]!   // nodes[0][[2,2,2]] position 1 is array index 0
        XCTAssertEqual(a, b)
        
        let bvars = b.allVariables
        let cvars = conjunction.allVariables
        
        XCTAssertEqual(cvars.count, bvars.count)
        let cbvars = Set(bvars.map { TptpNode($0) })
        XCTAssertEqual(cvars, cbvars)
        
        XCTAssertEqual(15312, b.allVariables.count)
    }
}
