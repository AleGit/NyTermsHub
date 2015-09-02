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
extension term_t {
    /// deprecated
    private func pretty(width width:UInt32, height:UInt32, offset:UInt32) -> String? {
        // create temporary file to write to
        let file = tmpfile()
        // it seams as fmemopen is not available
        
        guard file != nil else {
            // temporary file could not be opened
            return nil
            // file was not opened so there is no need to close it.
        }
        
        defer {
            // file is open so it must be closed at end of scope,
            // even if an error is thrown below.
            fclose(file)
            // temporary file will be deleted automatically after closing it
        }
        
        let code = yices_pp_term(file, self, width, height, offset);
        
        guard code >= 0 else {
            // pretty printing did not work
            
            print("yices error code = \(yices_error_code())")
            return nil
        }
        
        // compute size of file
        let size = ftell(file)
        // allocate buffer to read file in
        let buffer = malloc(size+1)
        
        guard buffer != nil else {
            // buffer could not be allocated
            return nil
            // buffer was not allocated so there is no need to free it.
        }
        
        defer {
            // buffer is allocated so it must be freed at end of scope
            // (before the file is closed), even if an error is thrown below.
            free(buffer)
        }
        
        // go back to start of file
        rewind(file)
        // read the whole content of file
        fread(buffer, size, 1, file);
        
        guard let string = NSString(bytes: buffer, length: size, encoding: NSUTF8StringEncoding) else {
            // conversion of buffer to string did not work
            return nil
        }
        // everything went well
        return string as String
    }
}

