//  Created by Alexander Maringele.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation

public extension String {
    
    public init?(tau: type_t, width:UInt32, height:UInt32, offset:UInt32) {
        let cstring = yices_type_to_string(tau, width, height, offset)
        guard cstring != nil else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = String.fromCString(cstring) else { return nil }
        self = string
    }
    
    public init?(tau: type_t) {
        self.init(tau: tau, width:UInt32.max, height:0, offset: 0)
    }
    
    public init?(term: term_t, width:UInt32, height:UInt32, offset:UInt32) {
        let cstring = yices_term_to_string(term, width, height, offset)
        guard cstring != nil else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        
        guard let string = String.fromCString(cstring) else { return nil }
        self = string
    }
    
    public init?(term: term_t) {
        self.init(term: term, width:UInt32.max, height:0, offset: 0)
    }
    
    
    public init?(model: COpaquePointer, width:UInt32, height:UInt32, offset:UInt32) {
        let cstring = yices_model_to_string(model, width, height, offset)
        guard cstring != nil else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = String.fromCString(cstring) else { return nil }
        self = string
    }
    
    public init?(model: COpaquePointer) {
        self.init(model:model, widht:UInt32.max, height:0, offset:0)
    }
}
