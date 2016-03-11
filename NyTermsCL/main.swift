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

// print footer (at end of program)
defer {
    print(line,line,line)
    print(line,NSDate(),line)
}

// demos
// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

// let files = Infos.files.filter { $0.1.0 < 1000 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }

//let files = Infos.files.filter { $0.1.0 == 17783 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }
//
//print(files)
//
// Complementaries.demo(files, searches: [fastestSearch])

// Proofing.demo()




