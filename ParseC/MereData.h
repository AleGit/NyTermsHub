//
//  MereData.h
//  NyTerms
//
//  Created by Alexander Maringele on 27.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef MereData_h
#define MereData_h

#import <CoreFoundation/CoreFoundation.h>

typedef ptrdiff_t SID; /* string 'identifier', i.e. offset from strings base */
typedef ptrdiff_t EID; /* entry 'identifier', i.e. offset from entries base */
typedef ptrdiff_t NID; /* node 'identifier', i.e. offset from nodes base */

typedef enum { mere_connective, mere_predicate, mere_function, mere_variable } mere_node_type;

typedef struct {
    SID symbol;
    mere_node_type type;
    NID next; /* 0 => no sibling */
    NID child; /* 0 => no children */
} mere_node;

bool mere_parser_init(size_t);
void mere_parser_exit();

SID mere_string_store(char const * _Nonnull cstring);
char* _Nonnull mere_string_retrieve(SID);

EID mere_entry_create(SID sid);
void mere_entry_append(EID list, SID sid);
int mere_entry_count(EID list);
SID mere_entry_string(EID list, int index);

SID mere_create_node(SID, NID, NID);

#endif /* MereData_h */
