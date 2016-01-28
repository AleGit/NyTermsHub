//
//  AuxiliaryTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 27.01.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//


import XCTest
@testable
import NyTerms

private let tptpFiles = [
    "puz001" : ("/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p",12,21),
    "hwv057" : ("/Users/Shared/TPTP/Problems/HWV/HWV057-1.p",3671,  8503),
    "hwv058" : ("/Users/Shared/TPTP/Problems/HWV/HWV058-1.p",3649,  8437),
    "hwv066" : ("/Users/Shared/TPTP/Problems/HWV/HWV066-1.p",15233,  35166),
    "hwv074" : ("/Users/Shared/TPTP/Problems/HWV/HWV074-1.p",2581,   6017),
    "hwv105" : ("/Users/Shared/TPTP/Problems/HWV/HWV105-1.p",20900,  52662),
    "hwv119" : ("/Users/Shared/TPTP/Problems/HWV/HWV119-1.p",17783,  53121),
    "hwv121" : ("/Users/Shared/TPTP/Problems/HWV/HWV121-1.p",31945,  93332),
//    "hwv134" : ("/Users/Shared/TPTP/Problems/HWV/HWV134-1.p",2332428,6570884),
]

private let key = "hwv121"

var path : String {
    return tptpFiles[key]!.0
}
var expectedClauses : Int {
    return tptpFiles[key]!.1
}
var expectedLiterals : Int {
    return tptpFiles[key]!.2
}

final class SimpleNode : Node {
    static var global = 0
    let symbol : String
    let nodes : [SimpleNode]?
    let counter = global++
    
    required init(symbol:String, nodes:[SimpleNode]?) {
        self.symbol = symbol
        self.nodes = nodes
    }
    
    var hashValue : Int { return counter.hashValue }
}

func ==(lhs:SimpleNode, rhs:SimpleNode) -> Bool {
    
    return lhs.counter == rhs.counter
    
}

extension SimpleNode : StringLiteralConvertible {
    // TODO: Implementation of `StringLiteralConvertible` should not depend on `TptpNode`.
    convenience init(stringLiteral value: StringLiteralType) {
        let term = SimpleNode(TptpNode(stringLiteral:value))
        self.init(symbol: term.symbol, nodes: term.nodes)
    }
}


class AuxiliaryTests: XCTestCase {
    
    typealias NodeType = TptpNode
    
    lazy var literals : [NodeType] = {
        print("reading literals '\(key) ...")
        
        let (array, runtime) = measure {
            () -> [NodeType] in
            let (result,tptpFormulae,tptpIncludes) = parse(path:path)
            XCTAssertEqual(1,result.count)
            XCTAssertEqual(0, result.first!)
            XCTAssertEqual(expectedClauses,tptpFormulae.count)
            XCTAssertEqual(0,tptpIncludes.count)
            XCTAssertTrue( tptpFormulae.reduce(true) { $0 && $1.root.isClause } )
            let array = tptpFormulae.flatMap { $0.root.nodes ?? [TptpNode]() }
            // let array = tptpFormulae.flatMap { $0.root.nodes?.map { NodeType($0) } ?? [NodeType]() }
            return array
        }
        XCTAssertEqual(expectedLiterals,array.count)
        
        print("\(array.count) literals read in \(runtime) seconds.")
        return array
    }()
    
    lazy var integers : [Int] = {
        print("generating intergers")
        
        let (array, runtime) = measure {
            () -> [Int] in
            
            var array = [Int]()
            array.reserveCapacity(expectedLiterals)
            
            for _ in 0..<expectedLiterals {
                array.append(Int(arc4random_uniform(UInt32(expectedLiterals))))
            }
            
            return array
        }
        
        print("\(array.count) integers generated in \(runtime)")
        return array
        
    }()
    
    func check(f:(Int)->Void) {
        for var size = 1; size < expectedLiterals / 2; size *= 2 {
            f(size)
        }
    }
    
    func testIntegerIntersection() {
        check {
            size in
            let (set1,set2) = (Set(self.integers[0..<size]),Set(self.integers[size..<2*size]))
            let (set3,runtime) = measure {
                set1.intersect(set2).map { self.literals[$0] }
            }
            
            print(size,runtime,set3.count)
        }
    }
    
    func testNodeIntersections() {
        check {
            size in
            let (set1,set2) = (Set(self.literals[0..<size]),Set(self.literals[size..<2*size]))
            let (set3,runtime) = measure {
                set1.intersect(set2)
            }
            
            print(size,runtime,set3.count)
        }
        
    }
    
    func testNodeConversion() {
        for (akey,avalue) in tptpFiles {
            print(akey,avalue)
            let (array1, runtime1) = measure {
                () -> [TptpNode] in
                let (_,tptpFormulae,_) = parse(path:avalue.0)
                return tptpFormulae.map { $0.root }
            }
            
            print(akey, runtime1, array1.count)
            
            let (array2, runtime2) = measure {
                return array1.map { SimpleNode($0) }
            }
            
            print(akey, runtime2, array2.count, runtime2/runtime1)

            
            let (array3, runtime3) = measure {
                return array1.map { TptpNode($0) }
            }
            
            print(akey, runtime3, array3.count, runtime3/runtime1)
            
            let zipped = zip(array1,array3)
            
            let same = zipped.reduce(true)
                { $0 && $1.0 === $1.1 }
            XCTAssertTrue(same)
        }
    }
}
