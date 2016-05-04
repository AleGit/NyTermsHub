//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

let line = "========================="

// print header
print(line,NSDate(),line)
print(Process.info)
print(Yices.info)
print("tptp root path:",TptpPath.tptpRootPath)
print(line,line,line)
yices_init()

// print footer (at end of program)
defer {
    yices_exit()
    print(line,line,line)
    print(line,NSDate(),line)
}

DemoFileParsing.demoPrlcParseHWV134()

exit(0)

DemoFileParsing.parseConvertHWV134()



for (name,info) in Infos.files {
    let path = name.p!
    let (clauses,parsetime) = measure { TptpNode.roots(path) }
    print("\(path) parsed in \(parsetime.prettyTimeIntervalDescription).")
    let (yicesClauses,maptime) = measure { clauses.map {
        (clause) -> term_t in
        let (yc, yls, ylbs) = Yices.clause(clause)
        
        let yicesLiteralsSet = Set(yls)
        let yicesLiteralsBeforeSet = Set(ylbs)
        
        //            if yicesLiterals.elementCounts != yicesLiteralsBefore.elementCounts {
        //                assert(yicesLiteralsSet.isSupersetOf(yicesLiteralsBeforeSet))
        //                print("\(yicesLiterals) <- \(yicesLiteralsBefore)")
        //            }
        let added = yicesLiteralsSet.subtract(yicesLiteralsBeforeSet    )
        if added.count > 0 {
            print("added:",added,"\(yls) <- \(ylbs)")
        }
        let removed = yicesLiteralsBeforeSet.subtract(yicesLiteralsSet)
        if removed.count > 0 {
            let removedLiterals = ylbs.enumerate().filter {
                removed.contains($0.1)
                }.map {
                    clause.nodes![$0.0]
            }
            
            print("removed:",removed,"* \(yls) <- \(ylbs)", removedLiterals)
        }
        
        return yc
        }
    }
    print("\(yicesClauses.count) clauses mapped in \(maptime.prettyTimeIntervalDescription).")
}

// DemoClauseIndex.demo("PUZ001-1")
// DemoClauseIndex.demo("HWV074-1")

// DemoFileParsing.dimensionsDemo()

// demos
// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

// let files = Infos.files.filter { $0.1.0 < 1000 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }

//let files = Infos.files.filter { $0.1.0 == 17783 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }
//
//print(files)
//
//DemoComplementaries.demo(files, searches: [fastestSearch])

// Proofing.demo()




