//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Foundation

/// Absolute path to a tptp file (problem, axiom).
///
///     '/Users/alm/TPTP/Problems/PUZ/PUZ001-1.p'
///     '/Users/alm/TPTP/Axioms/PUZ001-0.ax'
public typealias TptpPath = String

/// A tptp path to a file contains three components.
///
/// - 'root' is the TPTP directory with problems and axioms,
/// - 'local' is a local path from root and starts with 'Axioms' or 'Problems',
/// - 'last' and the file name of the axiom or problem.
///
/// (root:/Users/alm/TPTP/,local:Problems/PUZ/,last:PUZ001-1.p)
///
/// (root:/Users/alm/TPTP/,local:Axioms/,last:PUZ001-0.ax)
typealias TptpPathComponents = (root:TptpPath,local:TptpPath,last:TptpPath)

public extension TptpPath {
    /// Splits a tptp path to its components.
    private func tptpPathComponents () -> TptpPathComponents {
        var rootPath = [TptpPath]()
        var localPath = [TptpPath]()
        
        var isRootPathComponent = true
        for pathcomponent in ((self as NSString).stringByDeletingLastPathComponent as NSString).pathComponents {
            switch pathcomponent {
            case "Axioms", "Problems":
                isRootPathComponent = false;
            default:
                break;
            }
            
            if isRootPathComponent {
                rootPath.append(pathcomponent)
            } else {
                localPath.append(pathcomponent)
            }
        }
        
        return (NSString.pathWithComponents(rootPath), NSString.pathWithComponents(localPath), (self as NSString).lastPathComponent)
    }
    
    /// It's assumed that 'file' shares the same root directory as 'self'.
    public func tptpPathTo(file:TptpPath) -> TptpPath {
        let (root,_,_) = self.tptpPathComponents()
        let (_,directory,name) = file.tptpPathComponents()
        
        let path = directory.isEmpty ? (root as NSString).stringByAppendingPathComponent(name) : ((root as NSString).stringByAppendingPathComponent(directory) as NSString).stringByAppendingPathComponent(name)
        
        return path
    }
    
    /// Find path to tptp include file (usually an axiom).
    public func tptpPathTo(include: TptpInclude) -> TptpPath {
        return self.tptpPathTo(include.fileName)
    }
}
