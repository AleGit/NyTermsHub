//
//  CParser.h
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef PrlcParser_h
#define PrlcParser_h

#import <CoreFoundation/CoreFoundation.h>
#import "prlc.h"

#pragma mark - PrlcLexer.l

extern int prlc_lineno;
extern unsigned long prlc_leng;
extern char * _Nullable prlc_text;
extern FILE * _Nullable prlc_in;

void prlc_output(void);

int prlc_lex(void);
void prlc_restart(FILE * _Nullable file);

#pragma mark - PrlcParser.y



int prlc_parse(void);
int prlc_error (const char * _Nullable s);

#pragma mark - parse functions and data structures

extern prlc_store* _Nullable prlcParsingStore;
extern prlc_tree_node* _Nullable prlcParsingRoot;







#endif /* MereParser_h */
