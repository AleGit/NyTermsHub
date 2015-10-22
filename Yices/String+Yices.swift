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
        guard let string = NSString(CString: cstring, encoding: NSUTF8StringEncoding)
            else { return nil }
        
        self = string as String
    }
    
    public init?(term: term_t) {
        let cstring = yices_term_to_string(term, UInt32.max, 0, 0)
        guard cstring != nil else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = NSString(CString: cstring, encoding: NSUTF8StringEncoding)
            else { return nil }
        self = string as String
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
        guard let string = NSString(CString: cstring, encoding: NSUTF8StringEncoding)
            else { return nil }
        self = string as String
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
        guard let string = NSString(CString: cstring, encoding: NSUTF8StringEncoding)
            else { return nil }
        self = string as String
    }
    
    public init?(model: COpaquePointer) {
        let cstring = yices_model_to_string(model, UInt32.max, 0, 0)
        guard cstring != nil else {
            yices_print_error(stdout);
            return nil
        }
        defer {
            yices_free_string(cstring)
        }
        guard let string = NSString(CString: cstring, encoding: NSUTF8StringEncoding)
            else { return nil }
        self = string as String
        
    }
}
