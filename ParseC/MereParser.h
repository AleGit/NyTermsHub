//
//  CParser.h
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef MereParser_h
#define MereParser_h

#import <CoreFoundation/CoreFoundation.h>
#import "calm.h"

#pragma mark - MereLexer.l

extern int mere_lineno;
extern unsigned long mere_leng;
extern char * _Nullable mere_text;
extern FILE * _Nullable mere_in;

void mere_output(void);

int mere_lex(void);
void mere_restart(FILE * _Nullable file);

#pragma mark - MereParser.y



int mere_parse(void);
int mere_error (const char * _Nullable s);

#pragma mark - parse functions and data structures

extern _Nullable CalmParsingTableRef mereParsingTable;
extern calm_id mereLastInput;







#endif /* MereParser_h */
