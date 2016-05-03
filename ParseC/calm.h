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
    
    ///    <TPTP_file>  ::= <TPTP_input>*
    ///
    ///    <TPTP_input> ::= <annotated_formula> | <include>
    ///
    ///    <annotated_formula>  ::= ... | <fof_annotated> | <cnf_annotated> | ...
    CALM_TPTP_FILE,
    
    ///    <fof_annotated>      ::= fof(<name>,<formula_role>,<fof_formula><annotations>).
    CALM_TPTP_FOF_ANNOTATED,
    ///    <cnf_annotated>      ::= cnf(<name>,<formula_role>,<cnf_formula><annotations>).
    CALM_TPTP_CNF_ANNOTATED,
    
    ///    <include> ::= include(<file_name><formula_selection>).
    CALM_TPTP_INCLUDE,
    CALM_NAME,  // name, namelist
    
    CALM_TPTP_ROLE,
    CALM_TPTP_ANNOTATIONS,

    CALM_CONNECTIVE,
    CALM_EQUATIONAL,
    CALM_PREDICATE,     // includes PROPOSTION
    CALM_FUNCTIONAL,    // includes CONSTANT
    CALM_VARIABLE
    
    /* annotated_formula | include */
    
    
} CALM_TREE_NODE_TYPE;

typedef struct {
    /// sid denotes the name id of the node
    calm_sid sid;
    
    /// sibling denotes the next node in a sequence of nodes
    ///
    /// sibling == 'nexttid' for first and intermediate nodes
    ///
    /// sibling == 0 for last node
    calm_tid sibling;
    
    /// lastSibling is only relevant for the first node of a sequence
    ///
    /// lastSibling == 'lasttid' for first node in sequence
    ///
    /// lastSibling == 'nexttid' (==sibling) for intermediate nodes in sequence
    ///
    /// lastSibling == 0 for last node (lasttid) in sequence
    calm_tid lastSibling;
    
    /// child denotes a sequence of child nodes
    ///
    /// child == 'first child tid'
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

calm_tid calmStoreInclude(CalmParsingTableRef,calm_sid,calm_tid);

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
void calmNodeSetChild(CalmParsingTableRef, calm_tid, calm_tid);
void calmNodeSetSymbol(CalmParsingTableRef, calm_tid, const char* const);

calm_tid calmStoreNameNode(CalmParsingTableRef, calm_sid);

calm_id calm_label(char*);

#pragma mark - retrieval
/// Get (pointer to) symbol in parsing table with given id.
const char* const calmGetSymbol(CalmParsingTableRef, calm_sid);
/// Get (pointer to) tree node with givern id.
const calm_tree_node* calmGetTreeNode(CalmParsingTableRef, calm_tid);

size_t calmGetTreeNodeStoreSize(CalmParsingTableRef);
calm_tree_node calmCopyTreeNodeData(CalmParsingTableRef, calm_tid);
//const char* const calmGetNodeTreeSymbol(CalmParsingTableRef, calm_tid);
//calm_tid calmGetTreeNodeSibling(CalmParsingTableRef, calm_tid);
//calm_tid calmGetTreeNodeChild(CalmParsingTableRef, calm_tid);
//CALM_TREE_NODE_TYPE calmGetTreeNodeType(CalmParsingTableRef, calm_tid);

#endif /* calm_h */
