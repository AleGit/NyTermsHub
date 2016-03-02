//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

let line = "========================="

// print header
print(line,NSDate(),line)
print(line,line,line)

// print info
print("NyTerms with \(Yices.info)")
print("TPTP_ROOT",TptpPath.tptpRootPath)
print(line,line,line)

// print footer after demos
defer {
    print(line,line,line)
    print(line,NSDate(),line)
}

// demos
// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

//let files = Infos.files.filter { $0.1.0 == 17783 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }
//
//print(files)
//
//Complementaries.demo(files, searches: [fastestSearch])

Proofing.demo()





