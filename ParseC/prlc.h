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
    PRLC_CONNECTIVE,
    PRLC_EQUATIONAL,
    PRLC_PREDICATE,
    PRLC_FUNCTION,
    PRLC_VARIABLE
} PRLC_TREE_NODE_TYPE;

typedef struct prlc_prefix_node {
    const char* symbol;
    struct prlc_prefix_node* nexts[256];
} prlc_prefix_node;

typedef struct prlc_tree_node {
    char* symbol;
    PRLC_TREE_NODE_TYPE type;

    struct prlc_tree_node* sibling;
    struct prlc_tree_node* lastSibling;
    struct prlc_tree_node* child;
} prlc_tree_node;

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

#pragma mark - memory
prlc_store* prlcCreateStore(size_t);
void prlcDestroyStore(prlc_store**);

#pragma mark - store

/// Stores every symbol just once
const char* const prlcStoreSymbol(prlc_store* store, const char* const symbol);
const char* const prlcFirstSymbol(prlc_store *store);
const char* const prlcNextSymbol(prlc_store* store, const char* const symbol);



#endif /* prlc_h */
