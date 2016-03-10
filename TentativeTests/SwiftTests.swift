//
//  SwiftTests.swift
//  NyTerms
//
//  Created bheight Alexander Maringele on 02.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable
import NyTerms

protocol ArithmeticType {
    func +(lhs: Self, rhs: Self) -> Self
    func -(lhs: Self, rhs: Self) -> Self
    func *(lhs: Self, rhs: Self) -> Self
    func /(lhs: Self, rhs: Self) -> Self
}

extension Int8 : ArithmeticType { }
extension Int16 : ArithmeticType { }
// extension Int32 : ArithmeticType { } // does not conform
extension Int64 : ArithmeticType { }

extension Int : ArithmeticType { }
extension Float : ArithmeticType { }
extension Double : ArithmeticType { }

protocol Cubicle {
    typealias S:ArithmeticType
    
    var cubature:S { get }
}

struct Cube<T:ArithmeticType> : Cubicle {
    typealias S = T
    
    let width : T
    let height : T
    let depth : T
    
    var cubature : T {
        return width * height * depth
    }
}


/// Dispensable 'tests' to comprehend language features.
class SwiftTests: XCTestCase {

    func testSizes() {
        
        XCTAssertEqual(sizeof(Int),8)
        XCTAssertEqual(sizeof(Double),8)
        XCTAssertEqual(sizeof(String),24)
        
        XCTAssertEqual(sizeof(NodeStruct),32)
        XCTAssertEqual(sizeof(NodeClass),8)
        XCTAssertEqual(sizeof(TptpNode),8)
        
        XCTAssertEqual(sizeof(Cube<Int8>),3)
        XCTAssertEqual(sizeof(Cube<Int16>),6)
        XCTAssertEqual(sizeof(Cube<Int64>),24)
        
        XCTAssertEqual(sizeof(Cube<Int>),24)
        XCTAssertEqual(sizeof(Cube<Double>),24)
        XCTAssertEqual(sizeof(Cube<Float>),12)
    }
    
    func testStrides() {
        
        XCTAssertEqual(strideof(Int),8)
        XCTAssertEqual(strideof(Double),8)
        XCTAssertEqual(strideof(String),24)
        
        XCTAssertEqual(strideof(NodeStruct),32)
        XCTAssertEqual(strideof(NodeClass),8)
        XCTAssertEqual(strideof(TptpNode),8)
        
        XCTAssertEqual(strideof(Cube<Int8>),3)
        XCTAssertEqual(strideof(Cube<Int16>),6)
        XCTAssertEqual(strideof(Cube<Int64>),24)
        
        XCTAssertEqual(strideof(Cube<Int>),24)
        XCTAssertEqual(strideof(Cube<Float>),12)
        XCTAssertEqual(strideof(Cube<Double>),24)
    }
    
    func testProcessArguments() {
        let arguments = Process.arguments
        print(arguments)
        XCTAssertEqual(arguments.count,7)
        XCTAssertTrue(arguments[0].hasSuffix("NyTerms"))
        
        let key = "-tptp_root"
        if let keyIndex = arguments.indexOf(key) {
            let valueIndex = keyIndex + 1
            XCTAssertTrue(valueIndex < arguments.count, "\(key) is last argument")
            let value = arguments[valueIndex]
            
            XCTAssertEqual(value, TptpPath.tptpRootPath)
            
        }
        else {
            XCTFail("\(key) not found in arguments")
        }
    }
    
    func testProcessInfo() {
        let info = NSProcessInfo.processInfo()
        
        let environment = info.environment.map { "\($0.0) : \($0.1)" }
        print(environment.joinWithSeparator("\n"))
        
        
    }
}


