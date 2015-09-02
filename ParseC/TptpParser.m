//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#include "TptpParser.h"
#import "NyTerms-Swift.h"

#pragma mark - global storage for parser

NSMutableArray *_parser_storage_;                   // created strings, terms, arrays
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

TptpFormula *create_formula(TptpLanguage language,  NSString *name, TptpRole role,  TptpTerm *term,  NSArray<NSString*> *annotations) {
    assert(name != nil);
    assert(term != nil);
    // annoatations can be nil, i.e. there are not annotations.
    
    TptpFormula *formula = [[TptpFormula alloc] initWithLanguage:language name:name role:role formula:term annotations:annotations];
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
TptpTerm *create_quantified(NSString *name, TptpTerm* unitary, NSArray<NSString*>* vs) {
    assert(name != nil);
    assert(unitary != nil);
    assert(vs != nil);
    
    NSMutableArray*vnodes = create_array(0);
    for (NSString *v in vs) {
        [vnodes addObject: create_variable(v) ];
    }
    TptpTerm *tuple = create_connective(@",", vnodes);
    
    TptpTerm *term = [[TptpTerm alloc] initWithSymbol:name terms:@[tuple,unitary]];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create term with symbol and list of subterms.
TptpTerm *create_functional(NSString *name, NSArray<TptpTerm*> *subnodes) {
    TptpTerm *term = [[TptpTerm alloc] initWithFunctional:name terms:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

void register_predicate(TptpTerm * _Nonnull term) {
    [TptpTerm predicate:term];
}

TptpTerm *create_equational(NSString *name, NSArray<TptpTerm*> *subnodes) {
    TptpTerm *term = [[TptpTerm alloc] initWithEquational:name terms:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

TptpTerm *create_connective(NSString *name, NSArray<TptpTerm*> *subnodes) {
    assert(name != nil);
    assert(subnodes != nil);
    
    TptpTerm *term = [[TptpTerm alloc] initWithConnective:name terms:subnodes];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create constant, i.e. term with empty list of subterms.
TptpTerm *create_constant(NSString *name) {
    assert(name != nil);
    
    TptpTerm *term = [[TptpTerm alloc] initWithConstant:name];
    [_parser_storage_ addObject:term];
    return term;
    
}

/// Create variable, i.e. term without list of subterms.
TptpTerm *create_variable(NSString *name) {
    assert(name != nil);
    
    TptpTerm *term = [[TptpTerm alloc] initWithVariable:name];
    [_parser_storage_ addObject:term];
    return term;
}

/// Create distinct object, i.e. constant with symbol in single quotes.
TptpTerm *create_distinct_object(const char *cstring) {
    assert(cstring != NULL);
    
    NSString *string = [NSString stringWithUTF8String:cstring];
    return create_constant(string);
}

/// Create emtpy array of terms.
NSMutableArray<TptpTerm*>*create_nodes0() { return create_array(0); }
/// Create array with single term.
NSMutableArray<TptpTerm*>*create_nodes1(TptpTerm* a) {
    assert(a != nil);
    return create_array(1,a);
}
/// Create array with two terms.
NSMutableArray<TptpTerm*>* create_nodes2(TptpTerm* a, TptpTerm* b) {
    assert(a != nil);
    assert(b != nil);
    return create_array(2,a,b);
}

/// Add term to array of terms.
/// - disjunction    : disjunction '|' literal
/// - arguments      : arguments ',' term
/// - fof_tuple_list : fof_tuple_list ',' fof_logic_formula
void nodes_append(NSMutableArray<TptpTerm*> *a, TptpTerm* b) {
    assert(a != nil);
    assert(b != nil);
    [a addObject:b];
}

/// associative binary connectives are treated like n-ary connectives
/// - fof_binary_assoc : fof_or_formula | fof_and_formula
/// - fof_or_formula  : fof_or_formula '|' fof_unitary_formula
/// - fof_and_formula : fof_and_formula '&' fof_unitary_formula
TptpTerm* append(TptpTerm* parent, TptpTerm* child) {
    assert(parent != nil);
    assert(child != nil);
    assert(parent != child);
    [parent append:child];
    
    return parent; // create_node(parent.symbol, terms);
}

#pragma mark - roles

/// Map cstrings to role enums.
TptpRole make_role(const char* cstring) {
    assert(cstring != NULL);    // although handled this function should not be called with a null pointer.
    assert(cstring[0] != 0x00); // although handled this function should not be called with an empty cstring.
    
    switch (cstring ? cstring[0] : 0x00) {
        case 'a':
            if(!strcmp("axiom", cstring)) return TptpRoleAxiom;
            if(!strcmp("assumption", cstring)) return TptpRoleAssumption;
        case 'c':
            if(!strcmp("conjecture", cstring)) return TptpRoleConjecture;
        case 'd':
            if(!strcmp("definition", cstring)) return TptpRoleDefinition;
        case 'f':
            if(!strcmp("fi_domain", cstring)) return TptpRoleFiDomain;
            if(!strcmp("fi_functors", cstring)) return TptpRoleFiFunctors;
            if(!strcmp("fi_predicates", cstring)) return TptpRoleFiPredicates;
        case 'h':
            if(!strcmp("hypothesis", cstring)) return TptpRoleHypothesis;
        case 'l':
            if(!strcmp("lemma", cstring)) return TptpRoleLemma;
        case 'n':
            if(!strcmp("negated_conjecture", cstring)) return TptpRoleNegatedConjecture;
        case 'p':
            if(!strcmp("plain", cstring)) return TptpRolePlain;
        case 't':
            if(!strcmp("theorem", cstring)) return TptpRoleTheorem;
            if(!strcmp("type", cstring)) return TptpRoleDataType;
        case 'u':
            // if(!strncmp("unknown", cstring)) return TptpRoleUnknown;
        default:
            assert(!strcmp("unknown", cstring));    // allthough handled this function should not be called with an undefined cstring
            return TptpRoleUnknown;
    }
}

#pragma mark - parse

NSArray* parse_file(FILE *file) {
    assert(file != NULL);
    
    NSMutableArray *storage = [NSMutableArray array];
    NSMutableArray<TptpFormula*>* formulae = [NSMutableArray array];
    NSMutableArray<TptpInclude*>* includes = [NSMutableArray array];
    
    int result = 0;
    
    tptp_in = file;
    tptp_restart(file);
    tptp_lineno = 1;
    
    if (file) {
        
        _parser_storage_ = storage;
        _parser_includes_ = includes;
        _parser_formulae_ = formulae;
        
        
        result = tptp_parse();
        fclose(file);
    }
    else {
        result = -1;
    }
    
    return @[
             @(result),
            formulae,
            includes
            ];
}

/// Open file with path and call tptp parser on it.
NSArray* parse_path(NSString *path) {
    const char *p = path.UTF8String;
    FILE *file = fopen(p,"r");
    return parse_file(file);
}

/// Create temporary file with content of string and call tptp parser on it.
NSArray* parse_string(NSString *string) {
    const char *s = string.UTF8String;
    
    FILE *file = tmpfile();
    if (file) {
        fprintf(file,"%s", s);
        rewind(file);
    }
    
    return parse_file(file);
    
}
