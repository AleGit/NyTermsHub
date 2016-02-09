//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#include "TptpParser.h"
#import "NyTerms-Swift.h"

#pragma mark - global storage for parser

NSMutableArray *_parser_storage_;                   // created strings, nodes, arrays
NSMutableArray<TptpFormula*> *_parser_formulae_;    // list of correctly parsed formulae
NSMutableArray<TptpInclude*> *_parser_includes_;    // list of correctly parsed includes

#pragma mark - 'private'

/// Create array with 'n' objects and keep it in global storage.
NSMutableArray* create_array(int n, ...) {
    assert(n>=0);
    
    NSMutableArray *array = [NSMutableArray array];
    
    if (n>0) {
        int i;
        id e;
        va_list ap;
        va_start(ap, n);
        for (i=1;i <= n; i++) {
            e = va_arg(ap,id);
            
            assert(e != nil);
            
            [array addObject:e];
        }
    }
    
    [_parser_storage_ addObject:array];
    return array;
}

#pragma mark - formulae, includes

TptpFormula *create_formula(TptpLanguage language,  NSString *name, TptpRole role,  TptpNode *node,  NSArray<NSString*> *annotations) {
    assert(name != nil);
    assert(node != nil);
    // annoatations can be nil, i.e. there are no annotations at all.
    
    TptpFormula *formula = [[TptpFormula alloc] initWithLanguage:language name:name role:role root:node annotations:annotations];
    [_parser_formulae_ addObject:formula];
    return formula;
}

TptpInclude *create_include( NSString *fileName,  NSArray<NSString*> *selection) {
    assert(fileName != nil);
    // selection can be nil: all formulas of file are included.

    TptpInclude *include = [[TptpInclude alloc] initWithFileName:fileName formulaSelection:selection];
    [_parser_includes_ addObject:include];
    return include;
}


#pragma mark - string

/// Create string from c string and keep it in global storage.
NSString *create_string(const char *s) {
    assert(s != NULL);
    
    NSString *string = [NSString stringWithUTF8String:s];
    [_parser_storage_ addObject:string];
    return string;
}

/// Create array with one string.
NSMutableArray *create_strings1(NSString *a) {
    assert(a != nil);
    
    return create_array(1,a);
}

/// Add string to array of strings.
/// - name_list         : name_list ',' name
/// - fof_variable_list : fof_variable_list ',' variable
void strings_append(NSMutableArray<NSString*> *a, NSString* b) {
    assert(a != nil);
    assert(b != nil);
    
    [a addObject:b];
}

#pragma mark - nodes

/// Create (universal, existential) quantified term with list of variables and unitary subterm.
TptpNode *create_quantified(NSString *name, TptpNode* unitary, NSArray<NSString*>* vs) {
    assert(name != nil);
    assert(unitary != nil);
    assert(vs != nil);
    
    NSMutableArray*vnodes = create_array(0);
    for (NSString *v in vs) {
        [vnodes addObject: create_variable(v) ];
    }
    TptpNode *tuple = create_connective(@",", vnodes);
    
    TptpNode *term = [[TptpNode alloc] initWithSymbol:name nodes:@[tuple,unitary]];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create term with (predicate or function) symbol and list of subterms.
TptpNode *create_functional(NSString *name, NSArray<TptpNode*> *subnodes) {
    TptpNode *term = [[TptpNode alloc] initWithFunctional:name nodes:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

TptpNode *create_equational(NSString *name, NSArray<TptpNode*> *subnodes) {
    TptpNode *term = [[TptpNode alloc] initWithEquational:name nodes:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

TptpNode *create_connective(NSString *name, NSArray<TptpNode*> *subnodes) {
    assert(name != nil);
    assert(subnodes != nil);
    
    TptpNode *term = [[TptpNode alloc] initWithConnective:name nodes:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create constant, i.e. term with empty list of subterms.
TptpNode *create_constant(NSString *name) {
    assert(name != nil);
    
    TptpNode *term = [[TptpNode alloc] initWithConstant:name];
    [_parser_storage_ addObject:term];
    return term;
    
}

/// Create variable, i.e. term without list of subterms.
TptpNode *create_variable(NSString *name) {
    assert(name != nil);
    
    TptpNode *term = [[TptpNode alloc] initWithVariable:name];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create distinct object, i.e. constant with symbol in single quotes.
TptpNode *create_distinct_object(const char *cstring) {
    assert(cstring != NULL);
    
    NSString *string = [NSString stringWithUTF8String:cstring];
    return create_constant(string);
}

/// Create emtpy array of terms.
NSMutableArray<TptpNode*>*create_nodes0() { return create_array(0); }
/// Create array with single term.
NSMutableArray<TptpNode*>*create_nodes1(TptpNode* a) {
    assert(a != nil);
    return create_array(1,a);
}
/// Create array with two terms.
NSMutableArray<TptpNode*>* create_nodes2(TptpNode* a, TptpNode* b) {
    assert(a != nil);
    assert(b != nil);
    return create_array(2,a,b);
}

/// Add term to array of terms.
/// - disjunction    : disjunction '|' literal
/// - arguments      : arguments ',' term
/// - fof_tuple_list : fof_tuple_list ',' fof_logic_formula
void nodes_append(NSMutableArray<TptpNode*> *a, TptpNode* b) {
    assert(a != nil);
    assert(b != nil);
    [a addObject:b];
}

/// associative binary connectives are treated like n-ary connectives
/// - fof_binary_assoc : fof_or_formula | fof_and_formula
/// - fof_or_formula  : fof_or_formula '|' fof_unitary_formula
/// - fof_and_formula : fof_and_formula '&' fof_unitary_formula
TptpNode* append(TptpNode* parent, TptpNode* child) {
    assert(parent != nil);
    assert(child != nil);
    assert(parent != child);
    [parent append:child];
    
    return parent; // create_node(parent.symbol, nodes);
}

#pragma mark - roles

/// Map cstrings to role enums.
TptpRole make_role(const char* cstring) {
    assert(cstring != NULL);    // allthough handled this function should not be called with a null pointer.
    assert(strlen(cstring)>=4); // the shortest role `type` has 4 characters.
    assert(strlen(cstring)<=18); // the longest role `negated_conjecture` has 18 characters.
    
    switch (cstring ? cstring[0] : 0x00) {
        case 'a':
            if(!strcmp("axiom", cstring)) return TptpRoleAxiom;
            else if(!strcmp("assumption", cstring)) return TptpRoleAssumption;
            else return TptpRoleUnknown;
        case 'c':
            if(!strcmp("conjecture", cstring)) return TptpRoleConjecture;
            else return TptpRoleUnknown;
        case 'd':
            if(!strcmp("definition", cstring)) return TptpRoleDefinition;
            else return TptpRoleUnknown;
        case 'f':
            if(!strcmp("fi_domain", cstring)) return TptpRoleFiDomain;
            if(!strcmp("fi_functors", cstring)) return TptpRoleFiFunctors;
            if(!strcmp("fi_predicates", cstring)) return TptpRoleFiPredicates;
            else return TptpRoleUnknown;
        case 'h':
            if(!strcmp("hypothesis", cstring)) return TptpRoleHypothesis;
            else return TptpRoleUnknown;
        case 'l':
            if(!strcmp("lemma", cstring)) return TptpRoleLemma;
            else return TptpRoleUnknown;
        case 'n':
            if(!strcmp("negated_conjecture", cstring)) return TptpRoleNegatedConjecture;
            else return TptpRoleUnknown;
        case 'p':
            if(!strcmp("plain", cstring)) return TptpRolePlain;
            else return TptpRoleUnknown;
        case 't':
            if(!strcmp("theorem", cstring)) return TptpRoleTheorem;
            else if(!strcmp("type", cstring)) return TptpRoleDataType;
            else return TptpRoleUnknown;
        case 'u':
            // if(!strncmp("unknown", cstring)) return TptpRoleUnknown;
        default:
            assert(!strcmp("unknown", cstring));    // allthough handled this function should not be called with an undefined cstring
            return TptpRoleUnknown;
    }
}

#pragma mark - parse

int parse_file(FILE *file,TptpParseResult *result) {
    assert(file != NULL);
    
    NSMutableArray *storage = [NSMutableArray array];
    NSMutableArray<TptpFormula*>* formulae = [NSMutableArray array];
    NSMutableArray<TptpInclude*>* includes = [NSMutableArray array];
    
    int code = 0;
    
    tptp_in = file;
    tptp_restart(file);
    tptp_lineno = 1;
    
    if (file) {
        
        _parser_storage_ = storage;
        _parser_includes_ = includes;
        _parser_formulae_ = formulae;
        
        code = tptp_parse();
        
        _parser_storage_ = nil;
        _parser_includes_ = nil;
        _parser_formulae_ = nil;
        
        fclose(file);
    }
    else {
        code = -1;
    }
    
    [result appendFormulae:formulae];
    [result appendIncludes:includes];
    
    return code;
}

/// Open file with path and call tptp parser on it.
int parse_path(NSString *path, TptpParseResult *result) {
    const char *p = path.UTF8String;
    FILE *file = fopen(p,"r");
    return parse_file(file,result);
}

/// Create temporary file with content of string and call tptp parser on it.
int parse_string(NSString *string, TptpParseResult *result) {
    const char *s = string.UTF8String;
    
    FILE *file = tmpfile();
    if (file) {
        fprintf(file,"%s", s);
        rewind(file);
    }
    
    return parse_file(file,result);
    
}
