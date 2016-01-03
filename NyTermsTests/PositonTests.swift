//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

class PositionTests: XCTestCase {
    func testRootPosition() {
        XCTAssertEqual(0, ε.count)
        XCTAssertEqual(Position(),ε)
        XCTAssertEqual("ε",ε)
        XCTAssertEqual(Position([Int]()), ε)
        XCTAssertEqual(ε+ε, ε)
    }
    
    func testPositionConcatination() {
        var positions = [String:Position]()
        
        for s in ["ε", "1", "2","1.1","1.2","2.1","2.2","2.3","5.2.1.4.5.6.7.9", "1.5.2.6.7.8.9.10"] {
            positions[s] = Position(stringLiteral:s)
        }
        
        for (s1,p1) in positions {
            for (s2, p2) in positions {
                switch (p1,p2) {
                case (ε,ε) :
                    XCTAssertEqual(ε,p1+p2)
                case (_,ε):
                    XCTAssertEqual(p1,p1+p2)
                case (ε,_):
                    XCTAssertEqual(p2,p1+p2)
                default:
                    XCTAssertEqual(s1+"."+s2,(p1+p2).description)
                }
            }
        }
    }


    func testUnifiablePositions() {
        XCTAssertEqual( [ε], a.unifiablePositions(x))
        XCTAssertEqual( [Position](), x.unifiablePositions(a))
        XCTAssertEqual( [ε], fxy.unifiablePositions(z))
        
        XCTAssertEqual( [ε,"1"], fax.unifiablePositions(z))
        XCTAssertEqual( [ε,"2"], fxa.unifiablePositions(z))
        XCTAssertEqual( [ε,"1","2"], faa.unifiablePositions(z))
        
        XCTAssertEqual( [ε,"1","1.1","1.2"], gfaa.unifiablePositions(z))
    }
    
//        let εε = ε + ε
//        let p1 = "1" as Position
//        let p2 = "2" as Position
//        let p12 = "1.2" as Position
//        let p21 = "2.1" as Position
//        
//        XCTAssertEqual(ε, ε + ε)
//        XCTAssertEqual(ε, εε + ε)
//        
//        XCTAssertEqual(p12, p1+p2+ε)
//        XCTAssertEqual(p12, ε + p1 + p2)
//        XCTAssertEqual(p12, ε + p1 + p2 + ε)
//        XCTAssertEqual(p12, ε + p1 + p2 + ε)
//        XCTAssertEqual(p12, ε + p1 + ε + p2 + ε)
//        
//        XCTAssertEqual(p21, p2 + p1 + ε)
//        XCTAssertEqual(p21, ε + p2 + p1)
//        XCTAssertEqual(p21, ε + p2 + p1 + ε)
//        XCTAssertEqual(p21, ε + p2 + ε + p1 + ε)

//
//    func testPositionLessOrEqual() {
//        
//        let p1 = "1" as Position
//        let p2 = "2" as Position
//        let p12 = "1.2" as Position
//        let p21 = "2.1" as Position
//        
//        XCTAssertTrue(ε <= ε)
//        XCTAssertTrue(ε <= p1)
//        XCTAssertTrue(ε <= p2)
//        XCTAssertTrue(ε <= p12)
//        XCTAssertTrue(ε <= p21)
//        
//        XCTAssertFalse(p1 <= ε)
//        XCTAssertTrue(p1 <= p1)
//        XCTAssertFalse(p1 <= p2)
//        XCTAssertTrue(p1 <= p12)
//        XCTAssertFalse(p1 <= p21)
//        
//        XCTAssertFalse(p2 <= ε)
//        XCTAssertFalse(p2 <= p1)
//        XCTAssertTrue(p2 <= p2)
//        XCTAssertFalse(p2 <= p12)
//        XCTAssertTrue(p2 <= p21)
//        
//        XCTAssertFalse(p12 <= ε)
//        XCTAssertFalse(p12 <= p1)
//        XCTAssertFalse(p12 <= p2)
//        XCTAssertTrue(p12 <= p12)
//        XCTAssertFalse(p12 <= p21)
//        
//        XCTAssertFalse(p21 <= ε)
//        XCTAssertFalse(p21 <= p1)
//        XCTAssertFalse(p21 <= p2)
//        XCTAssertFalse(p21 <= p12)
//        XCTAssertTrue(p21 <= p21)
//    }
//    
//    func testPositionLess() {
//        
//        let p1 = "1" as Position
//        let p2 = "2" as Position
//        let p12 = "1.2" as Position
//        let p21 = "2.1" as Position
//        
//        XCTAssertFalse(ε < ε)
//        XCTAssertTrue(ε < p1)
//        XCTAssertTrue(ε < p2)
//        XCTAssertTrue(ε < p12)
//        XCTAssertTrue(ε < p21)
//        
//        XCTAssertFalse(p1 < ε)
//        XCTAssertFalse(p1 < p1)
//        XCTAssertFalse(p1 < p2)
//        XCTAssertTrue(p1 < p12)
//        XCTAssertFalse(p1 < p21)
//        
//        XCTAssertFalse(p2 < ε)
//        XCTAssertFalse(p2 < p1)
//        XCTAssertFalse(p2 < p2)
//        XCTAssertFalse(p2 < p12)
//        XCTAssertTrue(p2 < p21)
//        
//        XCTAssertFalse(p12 < ε)
//        XCTAssertFalse(p12 < p1)
//        XCTAssertFalse(p12 < p2)
//        XCTAssertFalse(p12 < p12)
//        XCTAssertFalse(p12 < p21)
//        
//        XCTAssertFalse(p21 < ε)
//        XCTAssertFalse(p21 < p1)
//        XCTAssertFalse(p21 < p2)
//        XCTAssertFalse(p21 < p12)
//        XCTAssertFalse(p21 < p21)
//    }
//    
//    func testPositionParallel() {
//        
//        let p1 = "1" as Position
//        let p2 = "2" as Position
//        let p12 = "1.2" as Position
//        let p21 = "2.1" as Position
//        
//        XCTAssertFalse(ε || ε)
//        XCTAssertFalse(ε || p1)
//        XCTAssertFalse(ε || p2)
//        XCTAssertFalse(ε || p12)
//        XCTAssertFalse(ε || p21)
//        
//        XCTAssertFalse(p1 || ε)
//        XCTAssertFalse(p1 || p1)
//        XCTAssertTrue(p1 || p2)
//        XCTAssertFalse(p1 || p12)
//        XCTAssertTrue(p1 || p21)
//        
//        XCTAssertFalse(p2 || ε)
//        XCTAssertTrue(p2 || p1)
//        XCTAssertFalse(p2 || p2)
//        XCTAssertTrue(p2 || p12)
//        XCTAssertFalse(p2 || p21)
//        
//        XCTAssertFalse(p12 || ε)
//        XCTAssertFalse(p12 || p1)
//        XCTAssertTrue(p12 || p2)
//        XCTAssertFalse(p12 || p12)
//        XCTAssertTrue(p12 || p21)
//        
//        XCTAssertFalse(p21 || ε)
//        XCTAssertTrue(p21 || p1)
//        XCTAssertFalse(p21 || p2)
//        XCTAssertTrue(p21 || p12)
//        XCTAssertFalse(p21 || p21)
//    }
//    
//    func testPositionMinus() {
//        
//        let p1 = "1" as Position
//        let p2 = "2" as Position
//        let p12 = "1.2" as Position
//        let p21 = "2.1" as Position
//        
//        XCTAssertEqual(ε, (ε-ε)!)
//        XCTAssertEqual(p1, (p1-ε)!)
//        XCTAssertEqual(p2, (p2-ε)!)
//        XCTAssertEqual(p12, (p12-ε)!)
//        XCTAssertEqual(p21, (p21-ε)!)
//        
//        XCTAssertNil(ε-p1)
//        XCTAssertEqual(ε, (p1-p1)!)
//        XCTAssertNil(p2-p1)
//        XCTAssertEqual(p2, (p12-p1)!)
//        XCTAssertNil(p21-p1)
//        
//        XCTAssertNil(ε-p2)
//        XCTAssertNil(p1-p2)
//        XCTAssertEqual(ε, (p2-p2)!)
//        XCTAssertNil(p12-p2)
//        XCTAssertEqual(p1, (p21-p2)!)
//        
//        XCTAssertNil(ε-p12)
//        XCTAssertNil(p1-p12)
//        XCTAssertNil(p2-p12)
//        XCTAssertEqual(ε, (p12-p12)!)
//        XCTAssertNil(p21-p12)
//        
//        XCTAssertNil(ε-p21)
//        XCTAssertNil(p1-p21)
//        XCTAssertNil(p2-p21)
//        XCTAssertNil(p12-p21)
//        XCTAssertEqual(ε, (p21-p21)!)
//        
//    }
}


