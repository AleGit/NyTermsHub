//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))



let start = CFAbsoluteTimeGetCurrent()

if Process.arguments.count < 2 {
    print("puz001")
    process(tptpFiles["puz001"]!, search:trieSearch)
}
else if let path = tptpFiles[Process.arguments[1].lowercaseString] {
    process(path, search:trieSearch)
}
else {
    let path = Process.arguments[1]
    print(path)
    process(path, search:trieSearch)
}

print("complete runtime \(CFAbsoluteTimeGetCurrent()-start) s.")






