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

let files = Infos.files.filter {
    // $0.1.0 == 17783
    // $0.0.contains("134")
    !$0.0.isEmpty
    }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }

print(files)

DemoComplementaries.demo(files, searches: [fastestSearch])




// DemoClauseIndex.demo("PUZ001-1")
// DemoClauseIndex.demo("HWV074-1")

// DemoFileParsing.dimensionsDemo()

// demos
// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

// let files = Infos.files.filter { $0.1.0 < 1000 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }



// Proofing.demo()




