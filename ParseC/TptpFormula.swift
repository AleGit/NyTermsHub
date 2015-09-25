//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

import Cocoa

/// Parses the content of the tptp file at absolute `path`.
/// When that tptp file contains *include* lines multiple files will be read.
/// It returns a triple with the list of parse status, 
/// the list for successfully parsed *annotated formulae*
/// and the list of all *include* lines.
public func parsePath(path:String) -> (status:[Int], formulae:[TptpFormula], includes:[TptpInclude]) {
    
    let array = parse_path(path)
    var result = [Int(array[0] as! NSNumber)]
    var formulae = array[1] as! [TptpFormula]
    var includes = array[2] as! [TptpInclude]
    
    for include in includes {
        let ipath = path.tptpPathTo(include)
        let (iresult,iformulae,iincludes) = parsePath(ipath)
        result += iresult
        includes += iincludes
        
        if let selection = include.formulaSelection {
            let s = Set(selection)
            formulae += iformulae.filter { s.contains($0.name) }
        }
        else {
            formulae += iformulae
        }
    }
    
    return (result, formulae, includes)
}

/// Parses the content of `string` which may contain multiple annotated formulae, but must not contain include lines.
/// It returns a pair with parse status and the list of successfully parsed *annotated formulae*.
public func parseString(string:String) -> (status:Int, formulae:[TptpFormula]) {
    
    let array = parse_string(string)
    let result = Int(array[0] as! NSNumber)
    let formulae = array[1] as! [TptpFormula]
    assert((array[2] as! [TptpInclude]).count == 0)
    return (result, formulae)
}

/// A TptpFormula represents one of the following tptp types
/// - cnf_annotated
/// - fof_annotated
public final class TptpFormula: NSObject {
    public let language : TptpLanguage
    public let name : String
    public let role : TptpRole
    public let formula : TptpTerm
    public let annotations : [String]?
    
    public init(language:TptpLanguage, name:String, role:TptpRole, formula:TptpTerm, annotations:[String]?) {
        
        self.language = language
        self.name = name
        self.role = role
        self.formula = formula
        self.annotations = annotations
    }
    
    public override var description : String {
        if let annos = annotations {
            return "\(language)(\(name), \(role), \(formula), \(annos))."
        }
        return "\(language)(\(name),\(role),\(formula))."
    }
}

extension TptpFormula : StringLiteralConvertible {
    public typealias UnicodeScalarLiteralType = StringLiteralType
    public convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.init(stringLiteral: value)
    }
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    public convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.init(stringLiteral: value)
    }
    
    /// Convenience initializer from string literal.
    /// - cnf(agatha,hypothesis, ( lives(agatha) )).
    /// - fof(pel55_1,axiom, ( ? [X] : ( lives(X) & killed(X,agatha) ) )).
    public convenience init(stringLiteral value: StringLiteralType) {
        let (status,formulae) = parseString(value)
        
        assert(status == 0)
        assert(formulae.count == 1)
        
        switch formulae.count {
        case 0:
            self.init(language: TptpLanguage.CNF, name: "parse_error", role: TptpRole.Unknown, formula: TptpTerm(constant:"parse_error"), annotations:nil)
        default:
            self.init(language: formulae[0].language, name: formulae[0].name, role: formulae[0].role, formula: formulae[0].formula, annotations: formulae[0].annotations)
        }
    }
    
    public convenience init(language:TptpLanguage, stringLiteral value:String) {
        let literal = "\(language)(anonymous,\(TptpRole.Unknown),\(value))."
        self.init(stringLiteral: literal)
    }
    
    /// Convenience factory method to create a cnf formula
    public static func CNF(stringLiteral value:String) -> TptpFormula {
        return TptpFormula(language: TptpLanguage.CNF, stringLiteral: value)
    }
    ///  Convenience factory method to create a fof formula
    public static func FOF(stringLiteral value:String) -> TptpFormula {
        return TptpFormula(language: TptpLanguage.FOF, stringLiteral: value)
    }
}
