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
    print(Yices.info)
    print(Z3.info)
    print("tptp root path:",TptpPath.tptpRootPath)
    
    yices_init()
    
    
    
    
    print(line,line,line)
    
}

func teardown() {
    
    Nylog.printparts()
    
    yices_exit()
    print(line,line,line)
    print(line,NSDate(),line)
    
}

func prove() {
    
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
    
    let loglevel = Nylog.LogLevel(literal: Process.valueOf("-loglevel") ?? "")
    Nylog.reset(1.0, loglevel: loglevel)
    
    Nylog.info("Process file '\(path)' with timeout \(timeout.prettyTimeIntervalDescription)")
    
    let ((_,formulae,_),_) = Nylog.measure("Parse '\(path)'") {
        parse(path:path)
    }
    
    let clauses = formulae.map { $0.root }
    
    let prover = MingyProver(clauses: clauses)
    
    prover.run(timeout)
    
}


