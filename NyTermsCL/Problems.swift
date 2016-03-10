//
//  Problems1k.swift
//  NyTerms
//
//  Created by Alexander Maringele on 02.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let puzzles = [
    ("PUZ001-1", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 100 ms
    ("PUZ001-2", STATUS_UNSAT, 11.11, 0.07, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ001-3", STATUS_SAT,   0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 200 ms
    ("PUZ002-1", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 200 ms
    ("PUZ003-1", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 300 ms
    ("PUZ004-1", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]),    // SUCCESS < 1 ms
    ("PUZ005-1", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),    // FAILED > 300 s
    ("PUZ006-1", STATUS_UNSAT, 11.11, 0.00, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ007-1", STATUS_UNSAT, 11.11, 0.00, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ008-1", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),    // FAILED > 300 s
    ("PUZ008-2", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 1 ms
    ("PUZ008-3", STATUS_UNSAT, 107.9, 0.00, [SymbolType.Predicate]),    // SUCCESS < 15 ms
    ("PUZ009-1", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]),    // SUCCESS < 1 ms
    ("PUZ010-1", STATUS_UNSAT, 9.999, 0.00, [SymbolType.Predicate]),    // SUCCESS#15 < 9 s
    ("PUZ011-1", STATUS_UNSAT, 11.1, 0.00, [SymbolType.Predicate]),     // SUCCESS
    ("PUZ012-1", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS
    ("PUZ013-1", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]),    // SUCCESS < 1 ms
    ("PUZ014-1", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]),    // SUCCESS < 1 ms
    ("PUZ015-1", STATUS_SAT  , 11.11, 0.57, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ015-2.006", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]), // SUCCESS < 1 ms
    ("PUZ015-3", STATUS_SAT, 1.0, 0.33, [SymbolType.Predicate]),
    ("PUZ016-1", STATUS_UNSAT, 11.11, 0.14, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ016-2.004", STATUS_SAT, 0.999, 0.00, [SymbolType.Predicate]),  // SUCCESS < 100 ms
    ("PUZ016-2.005", STATUS_UNSAT, 0.099, 0.00, [SymbolType.Predicate]),// SUCCESS < 1 ms
    ("PUZ017-1", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),    // FAILED > 300 s
    ("PUZ018-1", STATUS_UNSAT, 13.6, 0.00, [SymbolType.Predicate]),
    ("PUZ018-2", STATUS_SAT, 15.2, 0.00, [SymbolType.Predicate]),
    ("PUZ019-1", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),    // FAILED > 300 s
    ("PUZ020-1", STATUS_UNSAT, 11.11, 0.00, [SymbolType.Predicate,SymbolType.Equation]),    
    ("PUZ021-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#1 < 1s
    ("PUZ022-1", STATUS_UNSAT, 1.900, 0.00, [SymbolType.Predicate]),    // SUCCESS
    ("PUZ023-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#6 < 1 s
    ("PUZ024-1", STATUS_UNSAT, 0.999, 0.00, [SymbolType.Predicate]),    // SUCCESS < 400 ms
    ("PUZ025-1", STATUS_UNSAT, 3.999, 0.00, [SymbolType.Predicate]),    // SUCCESS#5 < 3 s
    ("PUZ026-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#8 < 2 s
    ("PUZ027-1", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),    // FAILED > 300 s
    ("PUZ028-1", STATUS_SAT, 12.2, 0.00, [SymbolType.Predicate]),
    ("PUZ028-2", STATUS_SAT, 13.7, 0.00, [SymbolType.Predicate]),
    ("PUZ028-3", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ028-4", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ028-5", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),      // > 300 Rating:0.0
    ("PUZ028-6", STATUS_UNSAT, 39.99, 0.00, [SymbolType.Predicate]),    // SUCCESS#8 < 33s
    ("PUZ029-1", STATUS_UNSAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ030-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#6 < 1 s
    ("PUZ030-2", STATUS_UNSAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ031-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#7 < 12s
    ("PUZ032-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#7 < 1 s
    ("PUZ033-1", STATUS_UNSAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ034-1.003", STATUS_SAT, 44.44, 0.00, [SymbolType.Predicate]),    // > 300 Rating:1.0
    ("PUZ034-1.004", STATUS_UNSAT, 44.44, 0.00, [SymbolType.Predicate]),  // > 300 Rating:0.62
    ("PUZ035-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#9 < 1s
    ("PUZ035-2", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#10 < 1 s
    ("PUZ035-3", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#5 < 1 s
    ("PUZ035-4", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#5 < 1 s
    ("PUZ035-5", STATUS_UNSAT, 99.99, 0.12, [SymbolType.Predicate]),      // > 300
    ("PUZ035-6", STATUS_UNSAT, 99.99, 0.12, [SymbolType.Predicate]),        // FAILED#7 > 600 s
    ("PUZ035-7", STATUS_UNSAT, 99.99, 0.00, [SymbolType.Predicate]),        // FAILED#7 > 600 s
    ("PUZ036-1.005", STATUS_UNSAT, 99.99, 0.17, [SymbolType.Predicate]),
    ("PUZ037-1"    , STATUS_UNSAT, 1.7, 0.17, [SymbolType.Predicate]),
    ("PUZ037-2", STATUS_UNSAT, 55.55, 0.17, [SymbolType.Predicate]),
    ("PUZ037-3", STATUS_UNSAT, 55.55, 0.17, [SymbolType.Predicate]),
    ("PUZ038-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#1 < 1 s
    ("PUZ039-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#1 < 1 s
    ("PUZ040-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#1 < 1 s
    ("PUZ041-1", STATUS_UNKNOWN, 1.0, 1.00, [SymbolType.Predicate]),
    ("PUZ042-1", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),            // saturates#1 < 1 s
    ("PUZ043-1", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ044-1", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ045-1", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ046-1", STATUS_SAT, 1.0, 0.00, [SymbolType.Predicate]),
    ("PUZ047-1", STATUS_UNSAT, 55.55, 0.00, [SymbolType.Predicate]),
    ("PUZ048-1", STATUS_SAT, 0.999, 0.00, [SymbolType.Predicate]),            // SUCCESS#1 < 200 ms
    ("PUZ049-1", STATUS_SAT, 1.0, 0.67, [SymbolType.Predicate]),
    ("PUZ050-1", STATUS_UNSAT, 22.22, 0.50, [SymbolType.Predicate]),            // saturates#1 < 1s
    ("PUZ051-1", STATUS_UNKNOWN, 1.0, 1.00, [SymbolType.Predicate]),
    ("PUZ052-1", STATUS_SAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ053-1", STATUS_SAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ054-1", STATUS_SAT, 0.099, 0.00, [SymbolType.Predicate]),            // SUCCESS#1 < 6 ms
    ("PUZ055-1", STATUS_UNKNOWN, 1.0, 1.00, [SymbolType.Predicate]),
    ("PUZ056-1", STATUS_UNSAT, 11.11, 0.43, [SymbolType.Predicate]),        
    ("PUZ056-2.005", STATUS_UNSAT, 22.22, 0.00, [SymbolType.Predicate]),        // saturates#1 < 1 s
    ("PUZ056-2.010", STATUS_UNSAT, 22.22, 0.17, [SymbolType.Predicate]),        // saturates#2 < 1 s
    ("PUZ056-2.015", STATUS_UNSAT, 22.22, 1.00, [SymbolType.Predicate]),        // saturates#2 < 1 s
    ("PUZ056-2.020", STATUS_UNSAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ056-2.022", STATUS_UNSAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ056-2.025", STATUS_UNSAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ056-2.027", STATUS_UNSAT, 1.0, 1.00, [SymbolType.Predicate]),
    ("PUZ056-2.030", STATUS_UNSAT, 55.55, 1.00, [SymbolType.Predicate]),
    ("PUZ057-1", STATUS_SAT, 11.11, 0.71, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ058-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ059-1", STATUS_SAT, 0.999, 0.00, [SymbolType.Predicate]),          // SUCCESS < 200 ms
    ("PUZ062-1", STATUS_UNSAT, 11.11, 0.80, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ062-2", STATUS_UNSAT, 11.11, 0.33, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ063-1", STATUS_UNSAT, 11.11, 0.20, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ063-2", STATUS_UNSAT, 11.11, 0.00, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ064-1", STATUS_UNSAT, 11.11, 0.80, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ064-2", STATUS_UNSAT, 11.11, 0.53, [SymbolType.Predicate,SymbolType.Equation]),        
    ("PUZ068-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ069-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ070-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ071-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
    ("PUZ072-1", STATUS_SAT, 11.11, 0.43, [SymbolType.Predicate,SymbolType.Equation]),          
]

let problems = [
    ("SYN421-1", STATUS_SAT, 33.33, 0.33, [SymbolType.Predicate]),
    ("HWV095-1", STATUS_UNSAT, 11.11, 0.17, [SymbolType.Predicate,SymbolType.Equation]),
("PUZ037-2", STATUS_UNSAT, 33.33, 0.17, [SymbolType.Predicate])]

struct Proofing {
    static func demo() {
        let fto = { (t:Double) -> Double in return t }
        
        let list = puzzles.filter {
            // range.contains(Int($0.2))
            (name,status,timeout,rating,types) in

            status != STATUS_UNKNOWN &&
                timeout < 100.0 &&
                rating < 0.1 &&
                !types.contains(SymbolType.Equation)
        }
        
        for (name,status,timeout,rating,category) in list {
            
            guard let path = name.p else {
                print("\(name) is not accessible")
                continue
            }
            print(path)
            
            yices_init()
            defer {
                yices_exit()
            }
            
            let clauses = TptpNode.roots(path)
            let prover = TrieProver(clauses: clauses)
            let (result,runtime) = measure {
                prover.run(timeLimit:fto(timeout))
            }
            let actual = prover.status
            print("  actual:", actual, "runtime:", runtime.timeIntervalDescriptionMarkedWithUnits)
            print("expected:", status, "timeout:", timeout.timeIntervalDescriptionMarkedWithUnits)
            print("  rating:", rating, (actual == status && result.1 <= timeout) ? "SUCCESS" : "FAILED", "\n")
            
        }
    }
}

