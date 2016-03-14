//
//  CParser.h
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef CParser_h
#define CParser_h

#import <CoreFoundation/CoreFoundation.h>

#pragma mark - MereLexer.l

extern int mere_lineno;
extern char * _Nullable mere_text;
extern FILE * _Nullable mere_in;

int mere_lex(void);
void mere_restart(FILE * _Nullable file);

#pragma mark - MereParser.y

int mere_parse(void);
int mere_error (const char * _Nullable s);

#pragma mark - parse

/// Parses TPTP file at path.
/// This function  is **NOT** thread safe and must not be called concurrently.
// int parse_path( const NSString * _Nonnull path, TptpParseResult * _Nonnull result);

/// Parses TPTP string.
/// This function is **NOT** thread safe and must not be called concurrently.
// int parse_string( const NSString * _Nonnull string, TptpParseResult * _Nonnull result);


#endif /* CParser_h */
