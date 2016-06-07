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
    
    func testNotUnifiable() {
        let list : [(TptpNode,TptpNode)] =
            [
                ("p(f(X),g(X))", "p(f(Y),f(Y))"),
                ("X"        ,"f(X)"     ),
                ("f(X)"     ,"X"   ),
                ("(p(X,X))" ,"p(Y,f(Y))" ),
                ("X", "f(g(h(f(g(h(X))))))"),
                
                // syntactical unification does not work in the following example
                // because of different notations for NOT EQUAL.
                ("Y!=Z"          ,"~(X=f(X))")
                ]
        
        for (a,b) in list {
            guard let unifier = a =?= b else {
                continue
            }
            XCTFail("\(a) =?= \(b) had yield a unifier \(unifier)")
            
            XCTAssertEqual(a * unifier, b * unifier,"(\(a) ≠ \(b)) * \(unifier)")
        }
    }
    
    func testUnifiable() {
        let e = [TptpNode:TptpNode]()
        
        let list : [(TptpNode,TptpNode, [TptpNode:TptpNode])] = [
            ("X"        ,"X"        , e),
            ("f(X)"     ,"f(X)"        , e),
            ("p(X,Y)"   ,"p(X,Y)"        , e),
            ("p(f(X),Y)"   ,"p(f(X),Y)"        , e),
            
            ("X"            ,"f(Y)"                 , ["X":"f(Y)"]),
            ("(p(X,Z))"     ,"p(Y,f(Y))"            , ["X":"Y","Z":"f(Y)"]),
            ("p(Y,f(Y))"    , "(p(X,Z))"            , ["Y":"X","Z":"f(X)"]),
            ("p(f(a,b,c))"  , "p(f(X,Y,Z))"         , ["X":"a", "Y":"b", "Z":"c"] ),
            
            ("X=f(X)"       ,"Y=Z"                  , ["X":"Y","Z":"f(Y)"]),
            ("Y=Z"          ,"X=f(X)"               , ["Y":"X","Z":"f(X)"]),
            ("~(X=f(X))"       ,"~(Y=Z)"                  , ["X":"Y","Z":"f(Y)"]),
            ("~(Y=Z)"          ,"~(X=f(X))"               , ["Y":"X","Z":"f(X)"]),
            ("X!=f(X)"       ,"Y!=Z"                  , ["X":"Y","Z":"f(Y)"]),
            ("Y!=Z"          ,"X!=f(X)"               , ["Y":"X","Z":"f(X)"]),
            // ("Y!=Z"          ,"~(X=f(X))"               , ["Y":"X","Z":"f(X)"]), // consitent notation is essential

            ("p(X,Y)"       ,"p(a,Z)"               , ["X":"a","Y":"Z"]),
            ("p(X,Y)"       ,"p(a,X)"               , ["X":"a","Y":"a"]),
            ("p(X,X)"       ,"p(Y,Z)"               , ["X":"Z","Y":"Z"]),
            ("p(X,Y)"       ,"p(Z,Z)"               , ["X":"Z","Y":"Z"]),
            ("f(g(h(f(g(h(Y))))))","X"              , ["X":"f(g(h(f(g(h(Y))))))"]),
            ]
        
        for (a,b,mgu) in list {
            XCTAssertEqual(a * mgu, b * mgu,"(\(a) ≠ \(b)) * \(mgu)")
            
            guard let unifier = a =?= b else {
                XCTFail("\(a) =?= \(b) did not yield a unifier")
                continue
            }
            
            XCTAssertEqual(a * unifier, b * unifier,"(\(a) ≠ \(b)) * \(unifier)")
            XCTAssertEqual(mgu, unifier,"\(mgu) ≠ \(unifier)")
        }
    }
    
    
    
    func testComplementaries() {
        let e = [TptpNode:TptpNode]()
        
        let list : [(TptpNode,TptpNode, [TptpNode:TptpNode])] = [
            ("~p(X,Y)"   ,"p(X,Y)"        , e),
            ("p(X,Y)"   ,"~p(X,Y)"        , e),
            ("~p(f(X),Y)"   ,"p(f(X),Y)"        , e),
            ("p(f(X),Y)"   ,"~p(f(X),Y)"        , e),
            
            ("~(p(X,Z))"     ,"p(Y,f(Y))"            , ["X":"Y","Z":"f(Y)"]),
            ("(p(X,Z))"     ,"~p(Y,f(Y))"            , ["X":"Y","Z":"f(Y)"]),
            
            ("~p(Y,f(Y))"    , "(p(X,Z))"            , ["Y":"X","Z":"f(X)"]),
            ("p(Y,f(Y))"    , "~(p(X,Z))"            , ["Y":"X","Z":"f(X)"]),
            
            ("~p(f(a,b,c))"  , "p(f(X,Y,Z))"         , ["X":"a", "Y":"b", "Z":"c"] ),
            ("p(f(a,b,c))"  , "~p(f(X,Y,Z))"         , ["X":"a", "Y":"b", "Z":"c"] ),
            
            ("X!=f(X)"       ,"Y=Z"                  , ["X":"Y","Z":"f(Y)"]),
            ("Y!=Z"          ,"X=f(X)"               , ["Y":"X","Z":"f(X)"]),
            ("X=f(X)"       ,"Y!=Z"                  , ["X":"Y","Z":"f(Y)"]),
            ("Y=Z"          ,"X!=f(X)"               , ["Y":"X","Z":"f(X)"]),
            
            ("~(X=f(X))"       ,"Y=Z"                  , ["X":"Y","Z":"f(Y)"]),
            ("~(Y=Z)"          ,"X=f(X)"               , ["Y":"X","Z":"f(X)"]),
            ("X=f(X)"       ,"~(Y=Z)"                  , ["X":"Y","Z":"f(Y)"]),
            ("Y=Z"          ,"~(X=f(X))"               , ["Y":"X","Z":"f(X)"]),
            
            ("~p(X,Y)"       ,"p(a,Z)"               , ["X":"a","Y":"Z"]),
            ("p(X,Y)"       ,"~p(a,Z)"               , ["X":"a","Y":"Z"]),
            
            ("~p(X,Y)"       ,"p(a,X)"               , ["X":"a","Y":"a"]),
            ("p(X,Y)"       ,"~p(a,X)"               , ["X":"a","Y":"a"]),
            
            ("~p(X,X)"       ,"p(Y,Z)"               , ["X":"Z","Y":"Z"]),
            ("p(X,X)"       ,"~p(Y,Z)"               , ["X":"Z","Y":"Z"]),
            
            ("~p(X,Y)"       ,"p(Z,Z)"               , ["X":"Z","Y":"Z"]),
            ("p(X,Y)"       ,"~p(Z,Z)"               , ["X":"Z","Y":"Z"]),
            
            ("~p(f(g(h(f(g(h(Y)))))))","p(X)"              , ["X":"f(g(h(f(g(h(Y))))))"]),
            ("p(f(g(h(f(g(h(Y)))))))","~p(X)"              , ["X":"f(g(h(f(g(h(Y))))))"]),
            ]
        
        for (a,b,mgu) in list {
            // XCTAssertEqual(a * mgu, b * mgu,"(\(a) ≠ \(b)) * \(mgu)")
            
            guard let unifier = a ~?= b else {
                XCTFail("\(a) ~?= \(b) did not yield a unifier")
                continue
            }
            
            if let absa = a.unnegatedNode {
                XCTAssertEqual(absa * unifier, b * unifier,"(\(absa) ≠ \(b)) * \(unifier)")
            }
            else if let absb = b.unnegatedNode {
                XCTAssertEqual(a * unifier, absb * unifier,"(\(a) ≠ \(absb)) * \(unifier)")
            }
            else {
                XCTFail("(\(a) ≠ \(b)) * \(unifier)")
            }
            
            // XCTAssertEqual(a * unifier, b * unifier,"(\(a) ≠ \(b)) * \(unifier)")
            XCTAssertEqual(mgu, unifier,"\(mgu) ≠ \(unifier)")
        }
    }
    
    func testPUZ001() {
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
