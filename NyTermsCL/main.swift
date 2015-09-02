//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

print("NyTerms with \(Yices.info):")
print(Process.arguments.joinWithSeparator("\n"))

guard Process.arguments.count > 1 else {
    Samples.parse4Samples()
    
    exit(0)
}

if Process.arguments.count > 1 {
    
    let path = Process.arguments[1]
    
    let start = NSDate()
    let result = parsePath(path)
    let duration = NSDate().timeIntervalSinceDate(start)
    

    print("\(result.formulae.count) formualae parsed in \(duration) s.")
    
}






