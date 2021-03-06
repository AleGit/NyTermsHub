//
//  prlc.h
//  NyTerms
//
//  Created by Alexander Maringele on 04.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef prlc_h
#define prlc_h

#import <CoreFoundation/CoreFoundation.h>

typedef enum {
    PRLC_UNDEFINED = 0,
    
    PRLC_FILE,
    
    PRLC_FOF,
    PRLC_CNF,
    PRLC_INCLUDE,
    
    PRLC_NAME,
    PRLC_ROLE,
    PRLC_ANNOTATION,
    
    PRLC_QUANTIFIER,
    PRLC_CONNECTIVE,
    
    PRLC_EQUATIONAL,
    PRLC_PREDICATE,
    
    PRLC_FUNCTION,
    PRLC_VARIABLE
} PRLC_TREE_NODE_TYPE;

typedef struct prlc_tree_node {
    const char* symbol;
    PRLC_TREE_NODE_TYPE type;
    
    struct prlc_tree_node* sibling;
    struct prlc_tree_node* lastSibling;
    struct prlc_tree_node* child;
} prlc_tree_node;

typedef struct prlc_prefix_node {
    const char* symbol;
    struct prlc_prefix_node* nexts[256];
} prlc_prefix_node;



typedef struct {
    void *memory;
    size_t capacity;
    size_t unit;
    size_t size;
} prlc_memory;

typedef struct {
    prlc_memory symbols;
    prlc_memory p_nodes;
    prlc_memory t_nodes;
} prlc_store;

typedef prlc_store* PrlcStoreRef;
typedef prlc_tree_node* PrlcTreeNodeRef;
typedef char* PrlcStringRef;

#pragma mark - memory
prlc_store* prlcCreateStore(size_t);
void prlcDestroyStore(prlc_store**);

prlc_tree_node* treeNode(prlc_store* store, size_t index);

#pragma mark - store

/// Stores every symbol just once
const char* const prlcStoreSymbol(prlc_store* store, const char* const symbol);
const char* const prlcGetSymbol(prlc_store* store, const char* symbol);
const char* const prlcFirstSymbol(prlc_store *store);
const char* const prlcNextSymbol(prlc_store* store, const char* const symbol);

prlc_tree_node* prlcStoreNodeFile(prlc_store* store, const char* const name, prlc_tree_node* input);
prlc_tree_node* prlcStoreNodeInclude(prlc_store* store, const char* const file, prlc_tree_node* selection);
prlc_tree_node* prlcStoreNodeAnnotated(prlc_store* store, PRLC_TREE_NODE_TYPE type,
                                       const char* const name, prlc_tree_node* role, prlc_tree_node* formula, prlc_tree_node* annotations);
prlc_tree_node* prlcStoreNodeRole(prlc_store* store, const char* const name);
prlc_tree_node* prlcStoreNodeConnective(prlc_store* store, const char* const symbol, prlc_tree_node* firstChild);

/// Store a quantified formula.
prlc_tree_node* prlcStoreNodeQuantified(prlc_store* store, const char* const quantifier, prlc_tree_node* variables, prlc_tree_node* formula);

prlc_tree_node* prlcStoreNodeFunctional(prlc_store* store, const char* const symbol, prlc_tree_node* firstChild);
prlc_tree_node* prlcStoreNodeEquational(prlc_store* store, const char* const symbol, prlc_tree_node* firstChild);
prlc_tree_node* prlcStoreNodeConstant(prlc_store* store, const char* const symbol);
prlc_tree_node* prlcStoreNodeVariable(prlc_store* store, const char* const symbol);

prlc_tree_node* prlcStoreNodeName(prlc_store* store, const char* const name);

prlc_tree_node*  prlcSetPredicate(prlc_tree_node *t_node);

prlc_tree_node* prlcNodeAppendNode(prlc_tree_node *first, prlc_tree_node *last);
prlc_tree_node *prlcNodeAppendChild(prlc_tree_node* parent, prlc_tree_node *last);

void prlcNodeSetChild(PrlcTreeNodeRef parent, PrlcTreeNodeRef child) __attribute__ ((deprecated));;

void* prlcLabel(const char* const label);

PrlcTreeNodeRef prlcFirstTreeNode(prlc_store*);
PrlcTreeNodeRef prlcTreeNodeAtIndex(prlc_store*, size_t);




#endif /* prlc_h */
