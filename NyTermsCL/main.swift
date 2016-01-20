//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))

let key = "hwv074"
let searches = [trieSearch, linearSearch]

func measure(f:()->()) {
    let start = CFAbsoluteTimeGetCurrent()
    
    f()
    
    print("\tcomplete runtime \(CFAbsoluteTimeGetCurrent()-start) s.\n")
}

if Process.arguments.count < 2 {
    for search in searches {
        
        measure { process(tptpFiles[key]!, search:search) }
    }
}
else if let path = tptpFiles[Process.arguments[1].lowercaseString] {
    for search in searches {
        measure { process(path, search:search) }
    }
}
else {
    let path = Process.arguments[1]
    print(path)
    measure { process(path, search:trieSearch) }
}






