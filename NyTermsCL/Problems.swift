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
    ("PUZ035-1", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
    ("PUZ035-2", STATUS_UNSAT), // .p:% Status   : Unsatisfiable
]

let puzzles = [
    ("PUZ001-1", STATUS_UNSAT),
    ("PUZ001-2", STATUS_UNSAT),
    ("PUZ001-3", STATUS_SAT),
    ("PUZ002-1", STATUS_UNSAT),
    ("PUZ003-1", STATUS_UNSAT),
    ("PUZ004-1", STATUS_UNSAT),
    ("PUZ005-1", STATUS_UNSAT),
    ("PUZ006-1", STATUS_UNSAT),
    ("PUZ007-1", STATUS_UNSAT),
    ("PUZ008-1", STATUS_UNSAT),
    ("PUZ008-2", STATUS_UNSAT),
    ("PUZ008-3", STATUS_UNSAT),
    ("PUZ009-1", STATUS_UNSAT),
    ("PUZ010-1", STATUS_UNSAT),
    ("PUZ011-1", STATUS_UNSAT),
    ("PUZ012-1", STATUS_UNSAT),
    ("PUZ013-1", STATUS_UNSAT),
    ("PUZ014-1", STATUS_UNSAT),
    ("PUZ015-1", STATUS_SAT),
    ("PUZ015-2.006", STATUS_UNSAT),
    ("PUZ015-3", STATUS_SAT),
    ("PUZ016-1", STATUS_UNSAT),
    ("PUZ016-2.004", STATUS_SAT),
    ("PUZ016-2.005", STATUS_UNSAT),
    ("PUZ017-1", STATUS_UNSAT),
    ("PUZ018-1", STATUS_UNSAT),
    ("PUZ018-2", STATUS_SAT),
    ("PUZ019-1", STATUS_UNSAT),
    ("PUZ020-1", STATUS_UNSAT),
    ("PUZ021-1", STATUS_UNSAT),
    ("PUZ022-1", STATUS_UNSAT),
    ("PUZ023-1", STATUS_UNSAT),
    ("PUZ024-1", STATUS_UNSAT),
    ("PUZ025-1", STATUS_UNSAT),
    ("PUZ026-1", STATUS_UNSAT),
    ("PUZ027-1", STATUS_UNSAT),
    ("PUZ028-1", STATUS_SAT),
    ("PUZ028-2", STATUS_SAT),
    ("PUZ028-3", STATUS_SAT),
    ("PUZ028-4", STATUS_SAT),
    ("PUZ028-5", STATUS_UNSAT),
    ("PUZ028-6", STATUS_UNSAT),
    ("PUZ029-1", STATUS_UNSAT),
    ("PUZ030-1", STATUS_UNSAT),
    ("PUZ030-2", STATUS_UNSAT),
    ("PUZ031-1", STATUS_UNSAT),
    ("PUZ032-1", STATUS_UNSAT),
    ("PUZ033-1", STATUS_UNSAT),
    ("PUZ034-1.003", STATUS_SAT),
    ("PUZ034-1.004", STATUS_UNSAT),
    ("PUZ035-1", STATUS_UNSAT),
    ("PUZ035-2", STATUS_UNSAT),
    ("PUZ035-3", STATUS_UNSAT),
    ("PUZ035-4", STATUS_UNSAT),
    ("PUZ035-5", STATUS_UNSAT),
    ("PUZ035-6", STATUS_UNSAT),
    ("PUZ035-7", STATUS_UNSAT),
    ("PUZ036-1.005", STATUS_UNSAT),
    ("PUZ037-1", STATUS_UNSAT),
    ("PUZ037-2", STATUS_UNSAT),
    ("PUZ037-3", STATUS_UNSAT),
    ("PUZ038-1", STATUS_UNSAT),
    ("PUZ039-1", STATUS_UNSAT),
    ("PUZ040-1", STATUS_UNSAT),
    ("PUZ042-1", STATUS_UNSAT),
    ("PUZ043-1", STATUS_SAT),
    ("PUZ044-1", STATUS_SAT),
    ("PUZ045-1", STATUS_SAT),
    ("PUZ046-1", STATUS_SAT),
    ("PUZ047-1", STATUS_UNSAT),
    ("PUZ048-1", STATUS_SAT),
    ("PUZ049-1", STATUS_SAT),
    ("PUZ050-1", STATUS_UNSAT),
    ("PUZ052-1", STATUS_SAT),
    ("PUZ053-1", STATUS_SAT),
    ("PUZ054-1", STATUS_SAT),
    ("PUZ056-1", STATUS_UNSAT),
    ("PUZ056-2.005", STATUS_UNSAT),
    ("PUZ056-2.010", STATUS_UNSAT),
    ("PUZ056-2.015", STATUS_UNSAT),
    ("PUZ056-2.020", STATUS_UNSAT),
    ("PUZ056-2.022", STATUS_UNSAT),
    ("PUZ056-2.025", STATUS_UNSAT),
    ("PUZ056-2.027", STATUS_UNSAT),
    ("PUZ056-2.030", STATUS_UNSAT),
    ("PUZ057-1", STATUS_SAT),
    ("PUZ058-1", STATUS_SAT),
    ("PUZ059-1", STATUS_SAT),
    ("PUZ062-1", STATUS_UNSAT),
    ("PUZ062-2", STATUS_UNSAT),
    ("PUZ063-1", STATUS_UNSAT),
    ("PUZ063-2", STATUS_UNSAT),
    ("PUZ064-1", STATUS_UNSAT),
    ("PUZ064-2", STATUS_UNSAT),
    ("PUZ068-1", STATUS_SAT),
    ("PUZ069-1", STATUS_SAT),
    ("PUZ070-1", STATUS_SAT),
    ("PUZ071-1", STATUS_SAT),
    ("PUZ072-1", STATUS_SAT),
]

let problems = [
    ("SYN421-1", STATUS_SAT),
    ("HWV095-1", STATUS_UNSAT),
("PUZ037-2", STATUS_UNSAT),]

struct Proofing {
    static func demo() {
        let list = puzzles.filter { $0.1 == STATUS_UNSAT // && $0.0 == "PUZ010-1"
        }
        for (name,status) in list {
            
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
            let (result,runtime) = measure {
                prover.run(timeLimit:600)
            }
            print("result",result)
            print(prover.status, "runtime",runtime.timeIntervalDescriptionMarkedWithUnits)
                print(status == prover.status)
            
        }
    }
}

