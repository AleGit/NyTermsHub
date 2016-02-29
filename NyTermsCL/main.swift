//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

let line = "========================="
print(line,NSDate(),line)
print(line,line,line)
print("NyTerms with \(Yices.info)")
print("TPTP_ROOT",TptpPath.tptpRootPath)
print(line,line,line)

// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

let files = Infos.files.filter { $0.1.0 < 100_000 }.sort { $0.1.0 < $1.1.1 }.map { $0.0 }

print(files)

Complementaries.demo(files, searches: [linearSearch, classSearch])

print(line,line,line)
print(line,NSDate(),line)



