//
//  cdata.h
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef calm_h
#define calm_h

#import <CoreFoundation/CoreFoundation.h>

typedef size_t calm_id;
typedef calm_id calm_sid;     /* symbol identifier (filename, name, role) */
typedef calm_id calm_tid;     /* tree node identifier */
typedef void* CalmParsingTableRef;

#pragma mark - symbol table

/// Allocate memory to store and access symbols, terms, etc.
CalmParsingTableRef calmMakeParsingTable(size_t);
/// Free memory with symbols, terms, etc.
void calmDeleteParsingTable(CalmParsingTableRef*);

/// Store a symbol in parsing table and get symbol id.
calm_sid calmStoreSymbol(CalmParsingTableRef, const char * const);
/// Get next symbol id after given id in parsing table .
calm_sid calmNextSymbol(CalmParsingTableRef, calm_sid);
/// Get (pointer to) symbol in parsing table with given id.
const char* const calmGetSymbol(CalmParsingTableRef, calm_sid);


size_t calmGetTreeNodeSize(CalmParsingTableRef);
const char* const calmGetTreeNodeSymbol(CalmParsingTableRef, calm_tid);


calm_tid calmStoreAnnotatedCnf(CalmParsingTableRef,calm_sid,calm_sid,calm_tid,calm_tid);
calm_tid calmStoreConnective(CalmParsingTableRef,calm_sid,calm_tid);
calm_tid calmStoreRole(CalmParsingTableRef,const char* const);

calm_tid calmSetPredicate(CalmParsingTableRef,calm_tid);
calm_tid calmStoreFunctional(CalmParsingTableRef,calm_sid,calm_tid);
calm_tid calmStoreEquational(CalmParsingTableRef,calm_sid,calm_tid);
calm_tid calmStoreConstant(CalmParsingTableRef,calm_sid);
calm_tid calmStoreVariable(CalmParsingTableRef,calm_sid);


calm_tid calmNodeListCreate(CalmParsingTableRef, calm_tid, calm_tid);
void calmNodeListAppend(CalmParsingTableRef, calm_tid, calm_tid);

calm_id calm_label(char*);

#endif /* calm_h */
