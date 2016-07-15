//
//  Yices+Info.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct Yices {
    
    static let version = String(cString: yices_version) ?? "yices_version: n/a"
    static let buildArch = String(cString: yices_build_arch) ?? "yices_build_arch: n/a"
    static let buildMode = String(cString: yices_build_mode) ?? "yices_build_mode: n/a"
    static let buildDate = String(cString: yices_build_date) ?? "yices_build_date: n/a"
    
    static let info = "Yices \(version) (\(buildArch),\(buildMode),\(buildDate))"
}

extension Yices {
    static func check(_ code : Int32, label: String) -> Bool {
        if code < 0 {
            Nylog.error("\(label) \(code) \(errorString)")
            return false
        }
        
        return true
    }
    
    static var errorString : String {
        let cstring = yices_error_string()
        guard cstring != nil else {
            return "yices_error_string() n/a"
        }
        
        guard let string = String(validatingUTF8: cstring!) else {
            return "yices_error_string() n/c"
        }
        
        return string
        
    
    }
}


