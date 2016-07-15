//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

class TptpParseResult: NSObject {
    var formulae = [TptpFormula] ()
    var includes = [TptpInclude] ()
    
    func appendFormulae(_ array:[TptpFormula]) {
        formulae += array
    }
    
    func appendIncludes(_ array:[TptpInclude]) {
        includes += array
    }
}

typealias TptpParseResultTriple = (status:[Int], formulae:[TptpFormula], includes:[TptpInclude])

/// Parses the content of the tptp file at absolute `path`.
/// When that tptp file contains *include* lines multiple files will be read.
/// It returns a triple with the list of parse status, 
/// the list for successfully parsed *annotated formulae*
/// and the list of all *include* lines.
func parse(path:String) -> TptpParseResultTriple {
    
    let parseResult = TptpParseResult()
    let status = parse_path(path,parseResult)
    
    return process(status, path:path, parseResult:parseResult)
}

private func process(_ status:Int32, path:String, parseResult:TptpParseResult) -> TptpParseResultTriple {
    
    // assert(status == 0, "parse path '\(path)' failed with code = \(status)")
    
    var results = [Int(status)]
    var formulae = parseResult.formulae
    var includes = parseResult.includes
    
    for include in includes {
        guard let includePath = path.tptpPathTo(include) else {
            let err = errorNumberAndDescription()
            results.append(Int(err.0))
            
            continue
        }
        let (includeResults,includeFormulae,includeIncludes) = parse(path:includePath)
        assert(includeIncludes.count == 0, "Include file '\(includePath)' contains \(includeIncludes.count). \(includeIncludes)")
        results += includeResults
        includes += includeIncludes
        
        if let selection = include.formulaSelection {
            let s = Set(selection)
            formulae += includeFormulae.filter { s.contains($0.name) }
        }
        else {
            formulae += includeFormulae
        }
    }
    
    return (results, formulae, includes)
}

/// Parses the content of `string` which may contain multiple annotated formulae, but must not contain include lines.
/// It returns the list of successfully parsed *annotated formulae*.
func parse(string:String) -> TptpParseResultTriple {
    
    let parseResult = TptpParseResult()
    let status = parse_string(string,parseResult)

    return process(status, path:TptpPath.tptpRootPath, parseResult:parseResult)
}


/// A TptpFormula represents one of the following tptp types
/// - cnf_annotated
/// - fof_annotated
final class TptpFormula: NSObject {
    let language : TptpLanguage
    let name : String
    let role : TptpRole
    let root : TptpNode
    let annotations : [String]?
    
    init(language:TptpLanguage, name:String, role:TptpRole, root:TptpNode, annotations:[String]?) {
        self.language = language
        self.name = name
        self.role = role
        self.root = root
        self.annotations = annotations
    }
    
    override var description : String {
        if let annos = annotations {
            return "\(language)(\(name), \(role), \(root), \(annos))."
        }
        return "\(language)(\(name),\(role),\(root))."
    }
}

extension TptpFormula : StringLiteralConvertible {
    typealias UnicodeScalarLiteralType = StringLiteralType
    convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Convenience initializer from string literal.
    /// - cnf(agatha,hypothesis, ( lives(agatha) )).
    /// - fof(pel55_1,axiom, ( ? [X] : ( lives(X) & killed(X,agatha) ) )).
    convenience init(stringLiteral value: StringLiteralType) {
        
        let formulae = parse(string:value).formulae
        assert(formulae.count == 1, "\(value) \(formulae)")
        
        switch formulae.count {
        case 0:
            self.init(language: TptpLanguage.cnf, name: "parse_error", role: TptpRole.unknown, root: TptpNode(constant:"parse_error"), annotations:nil)
        default:
            self.init(language: formulae[0].language, name: formulae[0].name, role: formulae[0].role, root: formulae[0].root, annotations: formulae[0].annotations)
        }
    }
    
    convenience init(language:TptpLanguage, stringLiteral value:String) {
        let literal = "\(language)(anonymous,\(TptpRole.unknown),\(value))."
        self.init(stringLiteral: literal)
    }
    
    /// Convenience factory method to create a cnf root
    static func CNF(stringLiteral value:String) -> TptpFormula {
        return TptpFormula(language: TptpLanguage.cnf, stringLiteral: value)
    }
    ///  Convenience factory method to create a fof root
    static func FOF(stringLiteral value:String) -> TptpFormula {
        return TptpFormula(language: TptpLanguage.fof, stringLiteral: value)
    }
}


