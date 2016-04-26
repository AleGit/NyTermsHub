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

#pragma mark - MereLexer.l

extern int mere_lineno;
extern unsigned long mere_leng;
extern char * _Nullable mere_text;
extern FILE * _Nullable mere_in;

void mere_output(void);

int mere_lex(void);
void mere_restart(FILE * _Nullable file);

#pragma mark - MereParser.y

typedef size_t SID; /* string identifier */
typedef size_t EID; /* entry identifier */
typedef size_t NID; /* node identifier */

int mere_parse(void);
int mere_error (const char * _Nullable s);

#pragma mark - parse functions and data structures

typedef struct {
    SID sid;
    EID next;   /* 0 => no next entry */
} mere_entry;

typedef enum { mere_connective, mere_predicate, mere_function, mere_variable } mere_node_type;

typedef struct {
    SID symbol;
    mere_node_type type;
    NID next; /* 0 => no sibling */
    NID child; /* 0 => no children */
} mere_node;

bool mere_parser_init(size_t);
void mere_parser_exit();

SID mere_store_string(char const * _Nonnull cstring, size_t len);
char* _Nonnull mere_retrieve_string(SID);

EID mere_entry_create(SID sid);
void mere_entry_append(EID list, SID sid);
int mere_entry_count(EID list);
SID mere_entry_string(EID list, int index);

SID mere_create_node(SID, NID, NID);



#endif /* MereParser_h */
