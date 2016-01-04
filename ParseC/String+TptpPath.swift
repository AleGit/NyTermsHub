//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Absolute path to a tptp file, i.e. a problem or an axiom.
///
/// /Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p
///
/// /Users/Shared/TPTP/Axioms/PUZ001-0.ax
typealias TptpPath = String

/// A tptp path to a file contains three components.
///
/// - 'root' is the TPTP directory with problems and axioms,
/// - 'local' is a local path from root and starts with 'Axioms' or 'Problems',
/// - 'last' and the file name of the axiom or problem.
///
/// (root:/Users/Shared/TPTP/,local:Problems/PUZ/,last:PUZ001-1.p)
///
/// (root:/Users/Shared/TPTP/,local:Axioms/,last:PUZ001-0.ax)
typealias TptpPathComponents = (root:TptpPath,local:TptpPath,last:TptpPath)

extension TptpPath {
    /// Splits a tptp path to its components.
    ///
    /// "/Users/Shared/TPTP/Problems/PUZ/PUZ001-1.p" -> (root:"/Users/Shared/TPTP/",local:"Problems/PUZ/",last:"PUZ001-1.p")
    private func tptpPathComponents () -> TptpPathComponents {
        var rootPath = [TptpPath]()
        var localPath = [TptpPath]()
        
        var isRootPathComponent = true
        for pathComponent in ((self as NSString).stringByDeletingLastPathComponent as NSString).pathComponents {
            switch pathComponent {
            case "Axioms", "Problems":
                isRootPathComponent = false;
            default:
                break;
            }
            
            if isRootPathComponent {
                rootPath.append(pathComponent)
            } else {
                localPath.append(pathComponent)
            }
        }
        
        return (NSString.pathWithComponents(rootPath), NSString.pathWithComponents(localPath), (self as NSString).lastPathComponent)
    }
    
    /// TPTP problem files can include axioms, i.e. the local path to an axiom file.
    /// It is assumed that `file` share the same root path as `self`.
    func tptpPathTo(file:TptpPath) -> TptpPath {
        let (root,_,_) = self.tptpPathComponents()
        let (_,directory,name) = file.tptpPathComponents()
        
        guard !directory.isEmpty else { return (root as NSString).stringByAppendingPathComponent(name) }
        
        return ((root as NSString).stringByAppendingPathComponent(directory) as NSString).stringByAppendingPathComponent(name)
    }
    
    /// Find path to tptp include file (usually an axiom).
    func tptpPathTo(include: TptpInclude) -> TptpPath {
        return self.tptpPathTo(include.fileName)
    }
}
