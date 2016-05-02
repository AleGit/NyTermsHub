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

typedef enum {
    CALM_TYPE_UNKNOWN = 0,
    CALM_VARIABLE,
    CALM_CONSTANT,
    CALM_FUNCTIONAL,
    CALM_PREDICATE,
    CALM_EQUATIONAL,
    CALM_CONNECTIVE,
    
    /* annotated_formula | include */
    CALM_TPTP_ROLE,
    CALM_TPTP_ANNOTATIONS,
    CALM_TPTP_CNF_ANNOTATED,
    CALM_TPTP_FOF_ANNOTATED,
    CALM_TPTP_INCLUDE
} CALM_TREE_NODE_TYPE;

typedef struct {
    calm_sid sid;
    calm_tid sibling;
    calm_tid child;
    CALM_TREE_NODE_TYPE type;
} calm_tree_node;

#pragma mark - symbol table

/// Allocate memory to store and access symbols, terms, etc.
CalmParsingTableRef calmMakeParsingTable(size_t);
/// Free memory with symbols, terms, etc.
void calmDeleteParsingTable(CalmParsingTableRef*);

/// Store a symbol in parsing table and get symbol id.
calm_sid calmStoreSymbol(CalmParsingTableRef, const char * const);
/// Get next symbol id after given id in parsing table .
calm_sid calmNextSymbol(CalmParsingTableRef, calm_sid);


size_t calmGetTreeStoreSize(CalmParsingTableRef);
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

#pragma mark - retrieval
/// Get (pointer to) symbol in parsing table with given id.
const char* const calmGetSymbol(CalmParsingTableRef, calm_sid);
/// Get (pointer to) tree node with givern id.
const calm_tree_node* calmGetTreeNode(CalmParsingTableRef, calm_tid);

#endif /* calm_h */
