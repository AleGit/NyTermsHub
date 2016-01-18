//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))

func measure(f:()->()) {
    let start = CFAbsoluteTimeGetCurrent()
    
    f()
    
    print("\tcomplete runtime \(CFAbsoluteTimeGetCurrent()-start) s.\n")
}

if Process.arguments.count < 2 {
    for f in [trieSearch, linearSearch] {
        
        measure { process(tptpFiles["hwv119"]!, search:f) }
    }
}
else if let path = tptpFiles[Process.arguments[1].lowercaseString] {
    for f in [linearSearch, trieSearch] {
        measure { process(path, search:trieSearch) }
    }
}
else {
    let path = Process.arguments[1]
    print(path)
    measure { process(path, search:trieSearch) }
}






