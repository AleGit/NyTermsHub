//
//  Yices+Info.swift
//  NyTerms
//
//  Created by Alexander Maringele on 20.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

import Foundation

struct Yices {
    
    static let version = String.fromCString(yices_version) ?? "yices_version: n/a"
    static let buildArch = String.fromCString(yices_build_arch) ?? "yices_build_arch: n/a"
    static let buildMode = String.fromCString(yices_build_mode) ?? "yices_build_mode: n/a"
    static let buildDate = String.fromCString(yices_build_date) ?? "yices_build_date: n/a"
    
    static let info = "Yices \(version) (\(buildArch),\(buildMode),\(buildDate))"
}

extension Yices {
    static func check(code : Int32, label: String) -> Bool {
        if code < 0 {
            print(label, errorString!)
            return false
        }
        
        return true
    }
    
    static var errorString : String? {
        let cstring = yices_error_string()
        guard cstring != nil else {
            return nil
        }
        
        guard let string = String.fromCString(cstring) else {
            return nil
        }
        
        return string
        
    
    }
}


