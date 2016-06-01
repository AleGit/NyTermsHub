//
//  YicesTestCase.swift
//  NyTerms
//
//  Created by Alexander Maringele on 17.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//


import XCTest
@testable import NyTerms


class YicesTestCase : XCTestCase {
    override func setUp() {
        super.setUp()
        yices_init()
        resetGlobalStringSymbols()
    }
    
    override func tearDown() {
        yices_exit()
        super.tearDown()
    }
    
    private func typeInfo(tau:type_t) -> [String] {
        var typeinfos = [String]()
        
        if yices_type_is_bool(tau)==1 { typeinfos.append("is_bool") }
        if yices_type_is_int(tau)==1 { typeinfos.append("is_int") }
        if yices_type_is_real(tau)==1 { typeinfos.append("is_real") }
        if yices_type_is_arithmetic(tau)==1 { typeinfos.append("is_arithmetic") }
        if yices_type_is_bitvector(tau)==1 { typeinfos.append("is_bitvector") }
        if yices_type_is_tuple(tau)==1 { typeinfos.append("is_tuple") }
        if yices_type_is_function(tau)==1 { typeinfos.append("is_function") }
        if yices_type_is_scalar(tau)==1 { typeinfos.append("is_scalar") }
        if yices_type_is_uninterpreted(tau)==1 { typeinfos.append("is_uninterpreted") }
        
        return typeinfos
        
    }
    
    func testNegations() {
        
        let p = "p(f(X,Y))" as TptpNode
        let np = "~p(f(A,B))" as TptpNode
        
        XCTAssertEqual(p.description, "p(f(X,Y))")
        XCTAssertEqual(np.description, "~(p(f(A,B)))")
        
        let yp = Yices.clause(p).yicesClause    // p
        let ynp = Yices.clause(np).yicesClause   // ~p
        
        let nyp = yices_not(yp) // ~p
        let nynp = yices_not(ynp) // ~~p
        
        XCTAssertEqual(yp, nynp)    // p = ~~p
        XCTAssertEqual(ynp, nyp)    // ~p = ~p
        XCTAssertEqual(yices_not(nynp), nyp)
        
        //        for t in [yp, ynp, nyp, nynp] {
        //
        //            print(t,Yices.children(t).sort(), Yices.subterms(t).sort())
        //            printInfo(t)
        //        }
        
        print("*************************************************************")
        
        for t : term_t in 0..<100 {
            // printInfo(t, recursive: false)
            
            guard let (name,type,children) = Yices.info(term:t) else { continue }
            
            print("[\(t)] \t \(name):\(type.name), \(type.infos), \(children)")
        }
        print("*************************************************************")
        
        let ctx = yices_new_context(nil)
        defer { yices_free_context(ctx) }
        
        for f in [yp, ynp, nyp, nynp] {
            yices_assert_formula(ctx, f)
            if yices_check_context(ctx, nil) == STATUS_SAT {
                let mdl = yices_get_model(ctx, 1)
                defer { yices_free_model(mdl) }
                
                print (String(model:mdl))
            }
        }
        
        let status = yices_check_context(ctx, nil)
        XCTAssertEqual(STATUS_UNSAT, status)
        
        
        
        
    }
    
}