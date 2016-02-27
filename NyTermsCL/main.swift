//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

let line = "========================="
print(line,NSDate(),line)
print(line,line,line)

print("NyTerms with \(Yices.info)")
print("TPTP_ROOT",TptpPath.tptpRootPath)

// BuildTries.demo()
// BuildTries.demo134()
// ParseFiles.demo()

let key = "hwv066"
let searches = [trieStructSearch, trieClassSearch]

var runtime : CFAbsoluteTime = 0

for search in searches {
        
        (_, runtime) = measure { process(tptpFiles[key]!!, search:search) }
    
    
    print ("runtime:",runtime.timeIntervalDescriptionMarkedWithUnits)
        
    }


print(line,line,line)
print(line,NSDate(),line)


