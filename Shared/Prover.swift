//  Created by Alexander Maringele on 28.10.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

protocol Prover {
    init(path:String)
    init(string:String)
    
    func run() -> Bool?
}
