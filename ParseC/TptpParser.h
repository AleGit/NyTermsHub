//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef Nyaya_TptpGlobals_h
#define Nyaya_TptpGlobals_h

@class TptpNode;
@class TptpFormula;
@class TptpInclude;

#import <Foundation/Foundation.h>
#import "TptpEnums.h"


#pragma mark - formulae, includes

TptpFormula* _Nonnull  create_formula(TptpLanguage language,  NSString * _Nonnull name, TptpRole role, TptpNode * _Nonnull term, NSArray * _Nullable annotations);
TptpInclude * _Nonnull create_include(NSString * _Nonnull fileName,  NSArray<NSString*>* _Nullable  selection);

#pragma mark - string

NSString * _Nonnull create_string( const char * _Nonnull s);
NSMutableArray<NSString*> * _Nonnull create_strings1( NSString* _Nonnull  a);
void strings_append(NSMutableArray<NSString*> * _Nonnull a,  NSString* _Nonnull  b);

#pragma mark - nodes

TptpNode* _Nonnull create_quantified( NSString * _Nonnull name, TptpNode* _Nonnull  unitary,  NSArray<NSString*>* _Nonnull  vs);
TptpNode* _Nonnull create_functional(NSString * _Nonnull name,  NSArray<TptpNode*> * _Nonnull subnodes);
TptpNode* _Nonnull create_equational(NSString * _Nonnull name,  NSArray<TptpNode*> * _Nonnull subnodes);
TptpNode* _Nonnull create_connective(NSString * _Nonnull name,  NSArray<TptpNode*> * _Nonnull subnodes);
TptpNode* _Nonnull create_constant(NSString * _Nonnull name);
TptpNode* _Nonnull create_variable(NSString * _Nonnull name);
TptpNode* _Nonnull create_distinct_object(const char * _Nonnull cstring);
void register_predicate(TptpNode * _Nonnull term);

NSMutableArray<TptpNode*>* _Nonnull create_nodes0();
NSMutableArray<TptpNode*>* _Nonnull create_nodes1(TptpNode* _Nonnull a);
NSMutableArray<TptpNode*>* _Nonnull create_nodes2(TptpNode* _Nonnull a, TptpNode* _Nonnull b);
void nodes_append( NSMutableArray<TptpNode*> * _Nonnull a, TptpNode* _Nonnull  b);

TptpNode* _Nonnull append(TptpNode* _Nonnull parent, TptpNode* _Nonnull child);

#pragma mark - roles

TptpRole make_role(const char* _Nonnull  cstring);

#pragma mark - tptpLexer.l

extern int tptp_lineno;
extern char * _Nullable tptp_text;
extern FILE * _Nullable tptp_in;

int tptp_lex(void);
void tptp_restart(FILE * _Nullable file);

#pragma mark - tptpParser.y

int tptp_parse(void);
int tptp_error (const char * _Nullable s);

#pragma mark - parse

/// Parses TPTP file at path.
/// This function  is **NOT** thread safe and must not be called concurrently.
NSArray* _Nonnull parse_path( const NSString * _Nonnull path);

/// Parses TPTP string.
/// This function is **NOT** thread safe and must not be called concurrently.
NSArray* _Nonnull parse_string( const NSString * _Nonnull string);

#endif


