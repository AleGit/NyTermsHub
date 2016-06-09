//
//  Core.swift
//  NyTerms
//
//  Created by Alexander Maringele on 07.06.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

let line = "========================="

func setup() {
    // print header
    print(line,NSDate(),line)
    print(Process.info)
    
    Nylog.debug(Yices.info)
    Nylog.debug(Z3.info)
    
    Nylog.info("tptp root path: \(TptpPath.tptpRootPath)")
    
    yices_init()
    Nylog.printparts()
    
    print(line,line,line)
    
    let loglevel = Nylog.LogLevel(literal: Process.valueOf("-loglevel") ?? "")
    Nylog.reset(1.0, loglevel: loglevel)
    
}

func teardown() {
    yices_exit()

    print(line,line,line)
    
    Nylog.printparts()
    print(line,NSDate(),line)
    
}

func prove() {
    
    // let start = CFAbsoluteTimeGetCurrent()
    
    guard let problem = Process.valueOf("-problem") else {
        Nylog.error("Argument -problem not set.")
        return
    }
    
    guard let path = problem.p else {
        Nylog.error("\(problem) does not exist or is not accessible.")
        return
        
    }
    
    var timeout = CFTimeInterval(Process.valueOf("-timeout") ?? "1.0") ?? 0.1
    if timeout < 0.01 { timeout = 0.01 }                // 10 ms
    else if timeout > 60 * 60 { timeout = 60 * 60 }     // 1 h
    
    Nylog.info("Process file '\(path)' with timeout \(timeout.prettyTimeIntervalDescription)")
    
    let ((_,formulae,_),_) = Nylog.measure("Parse '\(path)'") {
        parse(path:path)
    }
    
    let clauses = formulae.map { $0.root }
    
    let prover = MingyProver(clauses: clauses)
    if let axs = axioms(globalStringSymbols) {
        prover.append(axs)
    }
    
    let (status,outoftime,runtime) = prover.run(timeout)
    
    Nylog.printparts()
    
    print(line,line,line)
    
    switch status {
    case STATUS_UNSAT:
        print("'\(path)' is unsatisfiable. (runtime=\(runtime.prettyTimeIntervalDescription))")
        
    case STATUS_SAT where !outoftime:
        print("'\(path)' is satisfiable. (runtime=\(runtime.prettyTimeIntervalDescription))")
        
    case _ where outoftime:
        print("'\(path)' timed out. (runtime=\(runtime.prettyTimeIntervalDescription))")
        
    default:
        print("'\(path)' \(status) (runtime=\(runtime.prettyTimeIntervalDescription))")
        
        
    }
    
    
    
}


