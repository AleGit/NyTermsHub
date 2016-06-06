//
//  UnificationTests.swift
//  NyTerms
//
//  Created by Alexander Maringele on 29.02.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import XCTest
@testable import NyTerms

class UnificationTests: XCTestCase {
    
    func test_X_X() {
        
        let list : [(TptpNode,TptpNode, [TptpNode:TptpNode]?)] = [
        ("X"        ,"X"        , [TptpNode:TptpNode]()),
        ("f(X)"     ,"f(X)"        , [TptpNode:TptpNode]()),
        ("p(X,Y)"   ,"p(X,Y)"        , [TptpNode:TptpNode]()),
        ("p(f(X),Y)"   ,"p(f(X),Y)"        , [TptpNode:TptpNode]()),
        ("X"        ,"f(X)"     , nil),
        ("f(X)"     ,"X"     , nil),
        ("X"        ,"f(Y)"     , ["X":"f(Y)"]),
        ("(p(X,X))" ,"p(Y,f(Y))" , nil),
        ("(p(X,Z))" ,"p(Y,f(Y))" , ["X":"Y","Z":"f(Y)"]),
        ("p(Y,f(Y))" , "(p(X,Z))" ,["Y":"X","Z":"f(X)"])
        ]
        
        for (a,b,mgu) in list {
            
            
                let result = a =?= b
                
                guard let expected = mgu, let actual = result else {
                    // Both must be nil
                    XCTAssertNil(mgu)
                    XCTAssertNil(result)
                    
                    
                    continue
                }
                
                XCTAssertEqual(expected,actual,"\(a) =?= \(b) = \(expected) <\(actual)>")
                
                
                

            

        }
        
        
        let mgu = x =?= x
        
        XCTAssertNotNil(mgu)
        
            }
    
    func testComplementaries() {
        let name = "PUZ001-1"
        guard let path = name.p else {
            XCTFail("\(name) is not accessible")
            return
        }
        
        let literals = TptpNode.literals(path)
        print("# of literals:",literals.count)
        
        let step = min(literals.count/4,1000)
        
        var count = 0
        
        for (indexA,literalA) in literals.enumerate() {
            for (indexB,literalB) in literals[0..<indexA].enumerate() {
                let mgu = (literalA ~?= (literalB ** 1)) // make them variable distinct
                if mgu != nil {
                    count += 1
                    
                    if count % step == 0 {
                        print(indexA,indexB,count)
                    }
                }
            }
            
        }
        print(count)
        
        
    }
    
}
