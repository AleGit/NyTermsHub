//
//  Problems1k.swift
//  NyTerms
//
//  Created by Alexander Maringele on 02.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let errors = [
    ("PUZ010-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ017-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ019-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ027-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ030-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
]

let puzzles = [
    ("PUZ001-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ001-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ002-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ003-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ004-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ005-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ006-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ007-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ008-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ008-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ008-3", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ009-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    // ("PUZ010-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ011-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ012-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ013-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ014-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ015-2.006", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ016-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ016-2.005", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    // ("PUZ017-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    // ("PUZ018-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ019-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ020-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ021-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ022-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ023-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ024-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ025-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ026-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    // ("PUZ027-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ028-5", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ028-6", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ029-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    // ("PUZ030-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ030-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ031-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ032-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ033-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ034-1.004", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-3", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-4", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-5", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-6", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-7", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ036-1.005", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ037-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ037-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ037-3", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ038-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ039-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ040-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ042-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ047-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ050-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.005", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.010", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.015", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.020", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.022", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.025", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.027", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ056-2.030", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ062-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ062-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ063-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ063-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ064-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ064-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
]

struct Proofing {
    static func demo() {
        for (name,status) in puzzles {
            
            guard let path = name.p else {
                print("\(name), is not accessible")
                continue
            }
            print(path)
            
            yices_init()
            defer {
                yices_exit()
            }
            
            let clauses = TptpNode.roots(path)
            let prover = TrieProver(clauses: clauses)
            let (rounds,runtime) = measure {
                prover.run(25)
            }
            let status = prover.status
            print(status, "runtime",runtime.timeIntervalDescriptionMarkedWithUnits, "rounds", rounds)
                assert(status == prover.status)
            
        }
    }
}

