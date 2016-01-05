//  Created by Alexander Maringele .
//  Copyright © 2,15 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

class PositionTests: XCTestCase {
    
    func testRootPosition() {
        
        XCTAssertEqual(0, ε.count)
        XCTAssertEqual(Position(),ε)
        XCTAssertEqual(Position([Int]()), ε)
        
        XCTAssertEqual([], ε) // ArrayLiteralConvertible
        
        XCTAssertEqual(ε+ε, ε)
    }
    
    func testPositionConcatination() {
        var positions = [String:Position<Int>]()
        
        for s in [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]] {
            positions[s.description] = s
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
    
    func testPositionCompare() {
        var positions = [String:Position<Int>]()
        
        for s in [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]] {
            positions[s.description] = s
        }
        
        for (s1,p1) in positions {
            for (s2, p2) in positions {
                switch (p1,p2) {
                case (ε,ε) :
                    XCTAssertTrue(p1 <= p2)
                    XCTAssertFalse(p1 < p2)
                    
                case (_,ε):
                    XCTAssertTrue(p2 <= p1)
                    XCTAssertTrue(p2 < p1)
                    
                case (ε,_):
                    XCTAssertTrue(p1 <= p2)
                    XCTAssertTrue(p1 < p2)
                    
                default:
                    XCTAssertEqual(p1 <= p2, s2.hasPrefix(s1))
                    XCTAssertEqual(p1 < p2, s2.hasPrefix(s1) && s1 != s2)
                }
            }
        }
    }
    
    func testPositionParallel() {
        var positions = [String:Position<Int>]()
        
        for s in [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]] {
            positions[s.description] = s
        }
        
        for (s1,p1) in positions {
            for (s2, p2) in positions {
                switch (p1,p2) {
                case (_,ε), (ε,_):
                    XCTAssertFalse(p1 || p2)
                    
                default:
                    XCTAssertEqual(p1 || p2, !s1.hasPrefix(s2) && !s2.hasPrefix(s1))
                }
            }
        }
    }
    
    func testPositionMinus() {
        let distance = ".".startIndex.distanceTo(".".endIndex)
        
        var positions = [String:Position<Int>]()
        
        for s in [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]] {
            positions[s.description] = s
        }
        
        for (s1,p1) in positions {
            for (s2, p2) in positions {
                switch (p1,p2) {
                case (ε,_):
                    XCTAssertEqual(p2-p1, p2)
                    
                case (_,_) where p1 < p2:
                    let s = s2[s2.rangeOfString(s1)!.endIndex.advancedBy(distance)..<s2.endIndex]
                    XCTAssertEqual((p2 - p1)?.description, s )
                    
                case (_,_) where p1 <= p2:
                    XCTAssertEqual(p2 - p1, ε)
                    
                default:
                    XCTAssertNil(p2 - p1)
                }
            }
        }
    }
    
    
    
    func testNodePositions() {
        XCTAssertEqual([ε], x.positions)
        XCTAssertEqual([ε,[1],[2]], fxy.positions)
        XCTAssertEqual([ε,[1], [1,1], [1,2],[2]], (fxy * [x:faa]).positions)
        
        XCTAssertEqual(fax, fax[ε]!)
        XCTAssertEqual(a, fax[[1]]!)
        XCTAssertEqual(x, fax[[2]]!)
        XCTAssertEqual(x, fxy[[1]]!)
        XCTAssertEqual(y, fxy[[2]]!)
        
        XCTAssertEqual(fax[x,[1]]!,fxy[x,[2]]!)
        XCTAssertEqual(fxy, fxa[y,[2]]!)
        
    }


    func testUnifiablePositions() {
        XCTAssertEqual( [ε], a.unifiablePositions(x))
        XCTAssertEqual( [Position](), x.unifiablePositions(a))
        XCTAssertEqual( [ε], fxy.unifiablePositions(z))
        
        XCTAssertEqual( [ε,[1]], fax.unifiablePositions(z))
        XCTAssertEqual( [ε,[2]], fxa.unifiablePositions(z))
        XCTAssertEqual( [ε,[1],[2]], faa.unifiablePositions(z))
        
        XCTAssertEqual( [ε,[1],[1,1],[1,2]], gfaa.unifiablePositions(z))
    }
}


