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
    associatedtype S:ArithmeticType
    
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
    
    func testCollections() {
        var arrayOfTriples = [
            (a:0, b:"Hello", c:3.4),
            (a:2, b:"World", c:8.76),
            (a:-10, b:"!", c:-17.3)
        ]
        
        XCTAssertEqual("World", arrayOfTriples[1].b)
        
        var entry = arrayOfTriples[1] // a value copy
        entry.b = "America" // copy is changed but not original
        XCTAssertEqual("World", arrayOfTriples[1].b)
        
        arrayOfTriples[1].b = "Earth"   // changing part entry in array
        XCTAssertEqual("Earth", arrayOfTriples[1].b)
        
        arrayOfTriples[1] = (3,"Europe",18.0) // assign different entry
        XCTAssertEqual("Europe", arrayOfTriples[1].b)
        
        arrayOfTriples[1] = entry // assign changed copy
        XCTAssertEqual("America", arrayOfTriples[1].b)
        
    }
    
    func testIntegerMinMax() {
        print("\(Int.self)", sizeof(Int), Int.min, Int.max)
        
        print("\(Int8.self)", sizeof(Int8), Int8.min, Int8.max)
        print("\(Int16.self)", sizeof(Int16), Int16.min, Int16.max)
        print("\(Int32.self)", sizeof(Int32), Int32.min, Int32.max)
        
        print("\(Int64.self)", sizeof(Int64), Int64.min, Int64.max)
        
        
        print("\(UInt.self)", sizeof(UInt), UInt.min, UInt.max)
        
        print("\(UInt8.self)", sizeof(UInt8), UInt8.min, UInt8.max)
        print("\(UInt16.self)", sizeof(UInt16), UInt16.min, UInt16.max)
        print("\(UInt32.self)", sizeof(UInt32), UInt32.min, UInt32.max)
        
        print("\(UInt64.self)", sizeof(UInt64), UInt64.min, UInt64.max)
    }
}


