//  Created by alm on 30/08/15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

struct ParseFiles {
    
    static func demo() {
        
        for name in [ "LCL129-1", "SYN000-2", "PUZ051-1", "HWV074-1", "HWV105-1", "HWV062+1","HWV134+1", "HWV134-1" ] {
            let path = name.p
            
            let (formulae, duration) = measure {
                TptpNode.roots(path)
            }
            
            print(name,
                formulae.count,
                "formulae read in",
                duration.timeIntervalDescriptionMarkedWithUnits,
                "from",
                path)
        }
    }
}
/*
========================= 2016-02-17 08:25:56 +0000 =========================
========================= ========================= =========================
NyTerms with yices 2.4.2 (x86_64-apple-darwin15.2.0,release,2015-12-11)
TPTP_ROOT /Users/Shared/TPTP
LCL129-1 3 formulae read in 925µs 4ns from /Users/Shared/TPTP/Problems/LCL/LCL129-1.p
SYN000-2 19 formulae read in 1ms 506µs from /Users/Shared/TPTP/Problems/SYN/SYN000-2.p
PUZ051-1 43 formulae read in 6ms 832µs from /Users/Shared/TPTP/Problems/PUZ/PUZ051-1.p
HWV074-1 2581 formulae read in 426ms 474µs from /Users/Shared/TPTP/Problems/HWV/HWV074-1.p
HWV105-1 20900 formulae read in 594ms 21µs from /Users/Shared/TPTP/Problems/HWV/HWV105-1.p
HWV062+1 2 formulae read in 777ms 382µs from /Users/Shared/TPTP/Problems/HWV/HWV062+1.p
HWV134+1 128975 formulae read in 21s 74ms from /Users/Shared/TPTP/Problems/HWV/HWV134+1.p
HWV134-1 2332428 formulae read in 2m 26s from /Users/Shared/TPTP/Problems/HWV/HWV134-1.p
========================= ========================= =========================
========================= 2016-02-17 08:28:45 +0000 =========================
*/
