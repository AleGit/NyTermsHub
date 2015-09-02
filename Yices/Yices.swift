//
//  Yices.swift
//  NyTerms
//
//  Created by Alexander Maringele on 26.08.15.
//  Copyright © 2015 Alexander Maringele. All rights reserved.
//

import Foundation


public struct Yices {
    
    public static let version = NSString(UTF8String: yices_version)
    public static let buildArch = NSString(UTF8String: yices_build_arch)
    public static let buildMode = NSString(UTF8String: yices_build_mode)
    public static let buildDate = NSString(UTF8String: yices_build_date)
    
    public static let info = "yices \(version!) (\(buildArch!),\(buildMode!),\(buildDate!))"
}

