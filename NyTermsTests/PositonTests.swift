//  Created by Alexander Maringele .
//  Copyright © 2,15 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

class PositionTests: XCTestCase {
    
    func testRootPosition() {
        
        XCTAssertEqual(0, ε.count)
        XCTAssertEqual(Position(),ε)
        XCTAssertEqual(Position(Position()), ε)
        
        XCTAssertEqual([], ε) // ArrayLiteralConvertible
        
        XCTAssertEqual(ε+ε, ε)
    }
    
    func testPositionCompare() {
        let positions = [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]]
        
        for p1 in positions {
            for p2 in positions {
                XCTAssertEqual(p1 <= p2, p2.starts(with: p1))
                XCTAssertEqual(p1 < p2, p2.starts(with: p1) && p1 != p2)
                
            }
        }
    }
    
    func testPositionParallel() {
        let positions = [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]]
        
        for p1 in positions {
            for p2 in positions {
                XCTAssertEqual(p1 || p2, p1 != p2 && !(p1 < p2) && !(p2 < p1), "\(p1) \(p2)")
            }
        }
    }
    
    func testPositionMinus() {
        
        let positions = [ε, [1], [2],[1,1],[1,2],[2,1],[2,2],[2,3],[5,2,1,4,5,6,7,9], [1,5,2,6,7,8,9,10]]
        
        for p1 in positions {
            for p2 in positions {
                if p1 <= p2 {
                    XCTAssertNotNil(p2-p1)
                    XCTAssertEqual((p2-p1)!, Array(p2.dropFirst(p1.count)))
                }
                else {
                    XCTAssertNil(p2-p1)
                }
            }
        }
    }
    
    
    
    func testNodePositions() {
        XCTAssertEqual([ε], x.positions)
        XCTAssertEqual([ε,[0],[1]], fxy.positions)
        XCTAssertEqual([ε,[0], [0,0], [0,1],[1]], (fxy * [x:faa]).positions)
        
        XCTAssertEqual(fax, fax[ε]!)
        XCTAssertEqual(a, fax[[0]]!)
        XCTAssertEqual(x, fax[[1]]!)
        XCTAssertEqual(x, fxy[[0]]!)
        XCTAssertEqual(y, fxy[[1]]!)
        
        XCTAssertEqual(fax[x,[0]]!,fxy[x,[1]]!)
        XCTAssertEqual(fxy, fxa[y,[1]]!)
        
    }


    func testUnifiablePositions() {
        XCTAssertEqual( [ε], a.unifiablePositions(x))
        XCTAssertEqual( [Position](), x.unifiablePositions(a))
        XCTAssertEqual( [ε], fxy.unifiablePositions(z))
        
        XCTAssertEqual( [ε,[0]], fax.unifiablePositions(z))
        XCTAssertEqual( [ε,[1]], fxa.unifiablePositions(z))
        XCTAssertEqual( [ε,[0],[1]], faa.unifiablePositions(z))
        
        XCTAssertEqual( [ε,[0],[0,0],[0,1]], gfaa.unifiablePositions(z))
    }
}


