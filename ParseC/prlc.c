//
//  prlc.c
//  NyTerms
//
//  Created by Alexander Maringele on 04.05.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "prlc.h"

const char* const prlcStoreSymbol(prlc_store* store, const char* const symbol);

#pragma mark - allocate and free store

void prlc_alloc_memory(prlc_memory* memory, size_t capacity, size_t unit) {
    memory->memory = calloc(capacity,unit);
    memory->capacity = capacity;
    memory->unit = unit;
    memory->size = 0;
}

void prlc_copy_predefined_symbols(prlc_store *store) {
    
    prlcStoreSymbol(store, "");
    
    prlcStoreSymbol(store, "~");
    prlcStoreSymbol(store, "|");
    prlcStoreSymbol(store, "&");
    
    prlcStoreSymbol(store, "-->");
    prlcStoreSymbol(store, ",");
    
    prlcStoreSymbol(store, "<=>");
    prlcStoreSymbol(store, "=>");
    prlcStoreSymbol(store, "<=");
    
    prlcStoreSymbol(store, "<~>");
    prlcStoreSymbol(store, "~|");
    prlcStoreSymbol(store, "~&");
    
    
    prlcStoreSymbol(store, "!");
    prlcStoreSymbol(store, "?");
    
    prlcStoreSymbol(store, "=");
    prlcStoreSymbol(store, "!=");
    
}

prlc_store* prlcCreateStore(size_t capacity) {
    prlc_store* store = calloc(1,sizeof(prlc_store));

    prlc_alloc_memory(&(store->symbols), capacity, sizeof(char));
    prlc_alloc_memory(&(store->p_nodes), capacity, sizeof(prlc_prefix_node));
    prlc_alloc_memory(&(store->t_nodes), capacity/2, sizeof(prlc_tree_node));
    
    prlc_copy_predefined_symbols(store);

    return store;
}

void prlcDestroyStore(prlc_store** store) {
    free((*store)->symbols.memory);
    free((*store)->p_nodes.memory);
    free((*store)->t_nodes.memory);
    
    free(*store);
    *store = NULL;
}

#pragma mark -

prlc_prefix_node* prlc_prefix_node_new(prlc_store* store) {
    assert(store->p_nodes.size < store->p_nodes.capacity);
    
    prlc_prefix_node* base = store->p_nodes.memory;
    prlc_prefix_node* p_node = base + store->p_nodes.size;
    store->p_nodes.size += 1;
    
    return p_node;
}

prlc_prefix_node* prlc_prefix_path_step(prlc_store* store, prlc_prefix_node* p_node, const char* const symbol) {
    if (strlen(symbol) == 0) return p_node;
    
    int cidx = symbol[0];
    if (cidx < 0) cidx += 256;
    
    // printf("%d %c %s\n", cidx, cidx, symbol);
    
    prlc_prefix_node* next_node = p_node->nexts[cidx];
    
    if (next_node == NULL) {
        next_node = prlc_prefix_node_new(store);
        p_node->nexts[cidx] = next_node;
    }
    
    return prlc_prefix_path_step(store, next_node, symbol+1);
    
}

prlc_prefix_node* prlc_prefix_path_build(prlc_store* store, const char* const symbol) {
    prlc_prefix_node *p_node = NULL;
    if (store->p_nodes.size == 0) {
        p_node = prlc_prefix_node_new(store);
    }
    else {
        p_node = store->p_nodes.memory;
    }
    
    p_node = prlc_prefix_path_step(store, p_node, symbol);
    
    return p_node;
}

const char* const prlc_copy_symbol(prlc_store* store, const char* const symbol) {
    
    size_t len = strlen(symbol);
    
    assert(store->symbols.size + len < store->symbols.capacity);
    
    char *base = store->symbols.memory;
    char *copy = strcpy(base + store->symbols.size, symbol);
    
    assert(strlen(copy) == len);
    assert(*(copy+len) == '\0');
    
    store->symbols.size += strlen(symbol) + 1;
    
    assert(store->symbols.size <= store->symbols.capacity);
    
    return copy;
    
}

const char* const prlcStoreSymbol(prlc_store* store, const char* const symbol) {
    prlc_prefix_node *p_node = prlc_prefix_path_build(store, symbol);
    
    if (p_node->symbol == NULL) {
        p_node->symbol = prlc_copy_symbol(store, symbol);
    }
    
    return p_node->symbol;
}

const char* const prlcFirstSymbol(prlc_store *store) {
    if (store->symbols.size == 0) return NULL;
    else {
        return store->symbols.memory;
    }
}


const char* const prlcNextSymbol(prlc_store* store, const char* const symbol) {
    char *base = store->symbols.memory;
    
    assert (symbol - base < store->symbols.size);
    
    const char *next = symbol + strlen(symbol)+1;
    
    if ( next - base < store->symbols.size) return next;
    else return NULL;
}
