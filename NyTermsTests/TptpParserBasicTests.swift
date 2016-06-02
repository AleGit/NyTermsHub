//
//  TptpParserBasicTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 30.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class TptpParserBasicTests: XCTestCase {

    override func setUp() {
        super.setUp()
        yices_init()
        Nylog.reset()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        yices_exit()
    }
    
//    func testParserNotAProblemName() {
//        for notAProblemName in [ "PUZ0001"] {
//            let parser = TptpProver(problem:notAProblemName)
//            XCTAssertNil(parser,notAProblemName)
//        }
//    }
//    
//    func testParserNotAProblemPath() {
//        for notAProblemPath in [ "PUZ0001-1.p" , "/PUZ001-1.p", "/Users/Shared/TPTP/PUZ001-1.p"] {
//            let parser = TptpProver(file:notAProblemPath)
//            XCTAssertNil(parser,notAProblemPath)
//        }
//    }
//
//    func testParserInitPUZ006_1() {
//        let (prover,b) = measure {
//            TptpProver(problem:"PUZ006-1")
//            
//        }
//        
//        XCTAssertNotNil(prover)
//        XCTAssertTrue(b < 0.03)
//        
//        Nylog.printit()
//        
//        if let dictionary =  prover?.clauseIndicesByRole {
//            for (key,value) in dictionary {
//                print(key,value)
//            }
//            
//        }
//        
//        
//        // print(prover?.clauseIndicesByRole)
//    }

}
