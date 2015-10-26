//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

class TermTests: XCTestCase {
    
    func testTermEquality() {
        XCTAssertEqual("a", a.symbol)
        XCTAssertFalse(a.isVariable)
        XCTAssertTrue(a.isConstant)
        
        XCTAssertEqual("X", x.symbol)
        XCTAssertTrue(x.isVariable)
        XCTAssertFalse(x.isConstant)
        
        XCTAssertEqual("f", fax.symbol)
        XCTAssertFalse(fxa.isVariable)
        XCTAssertFalse(fxa.isConstant)
        
        XCTAssertEqual("f", fax.symbol)
        XCTAssertFalse(fax.isVariable)
        XCTAssertFalse(fax.isConstant)
        
        XCTAssertEqual(a, a)
        XCTAssertEqual(a.hashValue, a.hashValue)
        XCTAssertEqual(x, x)
        XCTAssertEqual(x, x)
        XCTAssertEqual(fax, fax)
        XCTAssertEqual(fax.hashValue, fax.hashValue)
        XCTAssertEqual(fxa, fxa)
        XCTAssertEqual(fxa.hashValue, fxa.hashValue)
        
        XCTAssertNotEqual(fax, fxa)
        XCTAssertEqual(fax.hashValue, fxa.hashValue)
    }
    
    func testTermMgu() {
        
        
        // unifyable
        XCTAssertEqual([x:x], (x =?= x)!)   // questionable
        
        XCTAssertEqual([x:a], (x =?= a)!)
        XCTAssertEqual([x:a], (a =?= x)!)
        
        XCTAssertEqual([x:a], (fax =?= fxa)!)
        XCTAssertEqual([x:a], (fxa =?= fax)!)
        
        // XCTAssertEqual([x:fax], (x =?= fax)!) // fails occur check
        // XCTAssertEqual([x:fax], (fax =?= x)!) // fails occur check
        
        // XCTAssertEqual([x:fxa], (x =?= fxa)!) // fails occur check
        // XCTAssertEqual([x:fxa], (fxa =?= x)!) // fails occur check
        
        
        let fab = "f(a,b)" as TestNode
        let gab = "g(a,b)" as TestNode
        
        XCTAssertEqual([x:a,y:b], (fxy =?= fab)!)
        XCTAssertNil(fxy =?= gab)
        XCTAssertNil(fab =?= gab)
        
    
    }
    
    func testTermConcatination() {
        XCTAssertEqual([x:a], [x:a] * [x:fax])
        XCTAssertEqual([x:faa], [x:fax] * [x:a])
        
        XCTAssertEqual([x:a,y:x], [x:a] * [y:x])
        
        XCTAssertEqual([x:fax, y:x], [x:fxy] * [x:a] * [y:x])
        XCTAssertEqual([x:fax, y:x], ([x:fxy] * [x:a]) * [y:x])
        XCTAssertEqual([x:fax, y:x], [x:fxy] * ([x:a] * [y:x]))
    }
    
    func testTermSubstitution() {
        
        XCTAssertTrue( [x:fxy].isSubstitution)
        XCTAssertFalse( [x:fxy].isRenaming)
        
        XCTAssertTrue( [x:y].isSubstitution)
        XCTAssertTrue( [x:y].isRenaming)
        
        
        XCTAssertFalse( [fxy:y].isSubstitution)
        XCTAssertFalse( [fxy:y].isRenaming)
        
        
        XCTAssertEqual(faa, fxy ** a)
        XCTAssertEqual(faa, fxa ** a)
        XCTAssertEqual(faa, fax ** a)
        XCTAssertEqual(fxy * [x:cbot,y:cbot], fxy** )
        
        XCTAssertEqual(a, a * [x:fxy] * [x:a] * [y:x])
        XCTAssertEqual(a, a * ([x:fxy] * [x:a]) * [y:x])
        XCTAssertEqual(a, a * [x:fxy] * ([x:a] * [y:x]))
        
        XCTAssertEqual(fax, x * [x:fxy] * [x:a] * [y:x])
        XCTAssertEqual(fax, x * ([x:fxy] * [x:a]) * [y:x])
        XCTAssertEqual(fax, x * [x:fxy] * ([x:a] * [y:x]))
    }
    
    func testTermPosition() {
        XCTAssertEqual([Position()], x.allPositions)
        XCTAssertEqual([Position(),[1],[2]], fxy.allPositions)
        XCTAssertEqual([Position(),[1], [1,1], [1,2],[2]], (fxy * [x:faa]).allPositions)
        
        XCTAssertEqual(fax, fax[Position()]!)
        XCTAssertEqual(a, fax[[1]]!)
        XCTAssertEqual(x, fax[[2]]!)
        XCTAssertEqual(x, fxy[[1]]!)
        XCTAssertEqual(y, fxy[[2]]!)

        XCTAssertEqual(fax[x,[1]]!,fxy[x,[2]]!)
        XCTAssertEqual(fxy, fxa[y,[2]]!)
        
    }

}
