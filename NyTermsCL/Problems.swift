//
//  Problems1k.swift
//  NyTerms
//
//  Created by Alexander Maringele on 02.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let puzzles = [
    ("PUZ001-1", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS < 100 ms
    ("PUZ001-2", STATUS_UNSAT, 111.1, 0.07),    // equational
    ("PUZ001-3", STATUS_SAT,   0.999, 0.00),    // SUCCESS < 200 ms
    ("PUZ002-1", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS < 200 ms
    ("PUZ003-1", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS < 300 ms
    ("PUZ004-1", STATUS_UNSAT, 0.099, 0.00),    // SUCCESS < 1 ms
    ("PUZ005-1", STATUS_UNSAT, 301.1, 0.00),    // FAILED > 300 s
    ("PUZ006-1", STATUS_UNSAT, 111.1, 0.00),    // equational
    ("PUZ007-1", STATUS_UNSAT, 111.1, 0.00),    // equational
    ("PUZ008-1", STATUS_UNSAT, 301.1, 0.00),    // FAILED > 300 s
    ("PUZ008-2", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS < 1 ms
    ("PUZ008-3", STATUS_UNSAT, 107.9, 0.00),    // SUCCESS < 15 ms
    ("PUZ009-1", STATUS_UNSAT, 0.099, 0.00),    // SUCCESS < 1 ms
    ("PUZ010-1", STATUS_UNSAT, 9.999, 0.00),    // SUCCESS#15 < 9 s
    ("PUZ011-1", STATUS_UNSAT, 11.1, 0.00),     // SUCCESS
    ("PUZ012-1", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS
    ("PUZ013-1", STATUS_UNSAT, 0.099, 0.00),    // SUCCESS < 1 ms
    ("PUZ014-1", STATUS_UNSAT, 0.099, 0.00),    // SUCCESS < 1 ms
    ("PUZ015-1", STATUS_SAT  , 111.1, 0.57),    // equational
    ("PUZ015-2.006", STATUS_UNSAT, 0.099, 0.00), // SUCCESS < 1 ms
    ("PUZ015-3", STATUS_SAT, 1.0, 0.33),
    ("PUZ016-1", STATUS_UNSAT, 111.1, 0.14),    // equational
    ("PUZ016-2.004", STATUS_SAT, 0.999, 0.00),  // SUCCESS < 100 ms
    ("PUZ016-2.005", STATUS_UNSAT, 0.099, 0.00),// SUCCESS < 1 ms
    ("PUZ017-1", STATUS_UNSAT, 301.1, 0.00),    // FAILED > 300 s
    ("PUZ018-1", STATUS_UNSAT, 13.6, 0.00),
    ("PUZ018-2", STATUS_SAT, 15.2, 0.00),
    ("PUZ019-1", STATUS_UNSAT, 301.1, 0.00),    // FAILED > 300 s
    ("PUZ020-1", STATUS_UNSAT, 111.1, 0.00),    // equational
    ("PUZ021-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#1 < 1s
    ("PUZ022-1", STATUS_UNSAT, 1.900, 0.00),    // SUCCESS
    ("PUZ023-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#6 < 1 s
    ("PUZ024-1", STATUS_UNSAT, 0.999, 0.00),    // SUCCESS < 400 ms
    ("PUZ025-1", STATUS_UNSAT, 3.999, 0.00),    // SUCCESS#5 < 3 s
    ("PUZ026-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#8 < 2 s
    ("PUZ027-1", STATUS_UNSAT, 301.1, 0.00),    // FAILED > 300 s
    ("PUZ028-1", STATUS_SAT, 12.2, 0.00),
    ("PUZ028-2", STATUS_SAT, 13.7, 0.00),
    ("PUZ028-3", STATUS_SAT, 1.0, 0.00),
    ("PUZ028-4", STATUS_SAT, 1.0, 0.00),
    ("PUZ028-5", STATUS_UNSAT, 301.1, 0.00),      // > 300 Rating:0.0
    ("PUZ028-6", STATUS_UNSAT, 39.99, 0.00),    // SUCCESS#8 < 33s
    ("PUZ029-1", STATUS_UNSAT, 1.0, 0.00),
    ("PUZ030-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#6 < 1 s
    ("PUZ030-2", STATUS_UNSAT, 1.0, 0.00),
    ("PUZ031-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#7 < 12s
    ("PUZ032-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#7 < 1 s
    ("PUZ033-1", STATUS_UNSAT, 1.0, 0.00),
    ("PUZ034-1.003", STATUS_SAT, 601.1, 0.00),    // > 300 Rating:1.0
    ("PUZ034-1.004", STATUS_UNSAT, 601.1, 0.00),  // > 300 Rating:0.62
    ("PUZ035-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#9 < 1s
    ("PUZ035-2", STATUS_UNSAT, 222.2, 0.00),            // saturates#10 < 1 s
    ("PUZ035-3", STATUS_UNSAT, 222.2, 0.00),            // saturates#5 < 1 s
    ("PUZ035-4", STATUS_UNSAT, 222.2, 0.00),            // saturates#5 < 1 s
    ("PUZ035-5", STATUS_UNSAT, 301.1, 0.12),      // > 300
    ("PUZ035-6", STATUS_UNSAT, 666.6, 0.12),
    ("PUZ035-7", STATUS_UNSAT, 666.6, 0.00),
    ("PUZ036-1.005", STATUS_UNSAT, 301.1, 0.17),
    ("PUZ037-1"    , STATUS_UNSAT, 1.7, 0.17),
    ("PUZ037-2", STATUS_UNSAT, 300.0, 0.17),
    ("PUZ037-3", STATUS_UNSAT, 300.0, 0.17),
    ("PUZ038-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#1 < 1 s
    ("PUZ039-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#1 < 1 s
    ("PUZ040-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#1 < 1 s
    ("PUZ041-1", STATUS_UNKNOWN, 1.0, 1.00),
    ("PUZ042-1", STATUS_UNSAT, 222.2, 0.00),            // saturates#1 < 1 s
    ("PUZ043-1", STATUS_SAT, 1.0, 0.00),
    ("PUZ044-1", STATUS_SAT, 1.0, 0.00),
    ("PUZ045-1", STATUS_SAT, 1.0, 0.00),
    ("PUZ046-1", STATUS_SAT, 1.0, 0.00),
    ("PUZ047-1", STATUS_UNSAT, 300.0, 0.00),
    ("PUZ048-1", STATUS_SAT, 0.999, 0.00),            // SUCCESS#1 < 200 ms
    ("PUZ049-1", STATUS_SAT, 1.0, 0.67),
    ("PUZ050-1", STATUS_UNSAT, 222.2, 0.50),            // saturates#1 < 1s
    ("PUZ051-1", STATUS_UNKNOWN, 1.0, 1.00),
    ("PUZ052-1", STATUS_SAT, 300.0, 1.00),
    ("PUZ053-1", STATUS_SAT, 300.0, 1.00),
    ("PUZ054-1", STATUS_SAT, 0.099, 0.00),            // SUCCESS#1 < 6 ms
    ("PUZ055-1", STATUS_UNKNOWN, 1.0, 1.00),
    ("PUZ056-1", STATUS_UNSAT, 111.1, 0.43),        // equational
    ("PUZ056-2.005", STATUS_UNSAT, 222.2, 0.00),        // saturates#1 < 1 s
    ("PUZ056-2.010", STATUS_UNSAT, 222.2, 0.17),        // saturates#2 < 1 s
    ("PUZ056-2.015", STATUS_UNSAT, 222.2, 1.00),        // saturates#2 < 1 s
    ("PUZ056-2.020", STATUS_UNSAT, 300.0, 1.00),
    ("PUZ056-2.022", STATUS_UNSAT, 300.0, 1.00),
    ("PUZ056-2.025", STATUS_UNSAT, 300.0, 1.00),
    ("PUZ056-2.027", STATUS_UNSAT, 1.0, 1.00),
    ("PUZ056-2.030", STATUS_UNSAT, 300.0, 1.00),
    ("PUZ057-1", STATUS_SAT, 111.1, 0.71),          // equational
    ("PUZ058-1", STATUS_SAT, 111.1, 0.43),          // equational
    ("PUZ059-1", STATUS_SAT, 0.999, 0.00),          // SUCCESS < 200 ms
    ("PUZ062-1", STATUS_UNSAT, 111.1, 0.80),        // equational
    ("PUZ062-2", STATUS_UNSAT, 111.1, 0.33),        // equational
    ("PUZ063-1", STATUS_UNSAT, 111.1, 0.20),        // equational
    ("PUZ063-2", STATUS_UNSAT, 111.1, 0.00),        // equational
    ("PUZ064-1", STATUS_UNSAT, 111.1, 0.80),        // equational
    ("PUZ064-2", STATUS_UNSAT, 111.1, 0.53),        // equational
    ("PUZ068-1", STATUS_SAT, 111.1, 0.43),          // equational
    ("PUZ069-1", STATUS_SAT, 111.1, 0.43),          // equational
    ("PUZ070-1", STATUS_SAT, 111.1, 0.43),          // equational
    ("PUZ071-1", STATUS_SAT, 111.1, 0.43),          // equational
    ("PUZ072-1", STATUS_SAT, 111.1, 0.43),          // equational
]

let problems = [
    ("SYN421-1", STATUS_SAT, 1.0, 0.00),
    ("HWV095-1", STATUS_UNSAT, 1.0, 0.00),
("PUZ037-2", STATUS_UNSAT, 1.0, 0.00),]

struct Proofing {
    static func demo() {
        let list = puzzles.filter {
            // range.contains(Int($0.2))
            (_,_,timeout,rating) in
            ( (0.0 <= timeout) && (timeout == 666.6) )     // expected runtime
                &&
                ( 0.0 <= rating && rating <= 0.5 )   // rating
        }
        
        for (name,status,timeout,rating) in list {
            
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
                prover.run(timeLimit:timeout)
            }
            let actual = prover.status
            print("  actual:", actual, "runtime:", runtime.timeIntervalDescriptionMarkedWithUnits)
            print("expected:", status, "timeout:", timeout.timeIntervalDescriptionMarkedWithUnits)
            print("  rating:", rating, (actual == status && result.1 <= timeout) ? "SUCCESS" : "FAILED", "\n")
            
        }
    }
}

