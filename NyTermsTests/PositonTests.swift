//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import XCTest
@testable import NyTerms

class PositonTests: XCTestCase {
    
    func testUnifiablePositions() {
        XCTAssertEqual( [Position()], a.unifiablePositions(x))
        XCTAssertEqual( [Position](), x.unifiablePositions(a))
        XCTAssertEqual( [Position()], fxy.unifiablePositions(z))
        
        XCTAssertEqual( [Position(),[1]], fax.unifiablePositions(z))
        XCTAssertEqual( [Position(),[2]], fxa.unifiablePositions(z))
        XCTAssertEqual( [Position(),[1],[2]], faa.unifiablePositions(z))
    }
}


