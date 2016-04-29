//
//  cdata.c
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "calm.h"

#define CALM_PARSING_TABLE_SIGNATURE 0xFEDCBA9876543210

#pragma mark 'private' functions (declarations)

typedef CalmId calm_pid;   // trie node identifier
typedef CalmId calm_tid;
typedef CalmSID calm_sid;

typedef int calm_cidx;

typedef enum { CALM_FAILED = -1, CALM_OK = 0 } CALM_STATUS;
typedef enum { CALM_TYPE_UNKNOWN = 0, CALM_VARIABLE, CALM_FUNCTIONAL, CALM_EQUATIONAL, CALM_CONNECTIVE } CALM_TYPE;

typedef struct {
    CalmSID sid;
    calm_pid nexts[256];
} calm_prefix_node;

typedef struct calm_term_node {
    CalmSID sid;
    calm_tid sibling;
    calm_tid child;
    CALM_TYPE type;
} calm_term_node;

typedef struct {
    void * memory;
    size_t capacity;
    size_t size;
} calm_memory;

typedef struct {
    char *memory;
    size_t capacity;
    size_t size;
} calm_char_store;

typedef struct {
    calm_prefix_node *memory;
    size_t capacity;
    size_t size;
} calm_prefix_store;

typedef struct {
    calm_term_node *memory;
    size_t capacity;
    size_t size;
} calm_term_store;


typedef struct {
    unsigned long signature;
    calm_char_store* strings;
    calm_prefix_store* prefixes;
    calm_term_store* terms;
} calm_table;

/* memory */

calm_memory* calm_memory_create(size_t capacity, size_t unitsize);
CALM_STATUS calm_memory_ensure(calm_memory* ref, size_t capacity, size_t unitsize);
void calm_memory_delete(calm_memory** refref);

/* (string) store */

calm_char_store* calm_char_store_create(size_t capacity);
CALM_STATUS calm_char_store_ensure(calm_char_store* store_ref, size_t capacity);
void calm_char_store_delete(calm_char_store** store_ref);
CalmSID calm_char_store_append(calm_char_store* store_ref, const char* const cstring);
const char* const calm_char_store_retrieve(calm_char_store* store_ref, const CalmSID sid);

/* trie */

calm_prefix_store* calm_prefix_store_create(size_t capacity);
CALM_STATUS calm_prefix_store_ensure(calm_prefix_store* trie_ref, size_t capacity);
void calm_prefix_store_delete(calm_prefix_store** trie_ref);

calm_pid calm_prefix_store_append(calm_prefix_store * trie_ref, calm_sid);
calm_prefix_node* calm_prefix_store_retrieve(calm_prefix_store* trie_ref, calm_pid tid);

calm_pid calm_prefix_build_step(calm_prefix_store* trie_ref, calm_pid tid, calm_cidx cidx);
calm_pid calm_prefix_build_path(calm_prefix_store* trie_ref, const char* const cstring);

/* (term) vertices */

calm_term_store* calm_term_store_create(size_t);
CALM_STATUS calm_term_store_ensure(calm_term_store*, size_t);
void calm_term_store_delete(calm_term_store**);

calm_tid calm_term_store_append(calm_term_store*,calm_sid,calm_tid,calm_tid,CALM_TYPE);
calm_term_node* calm_term_store_retrieve(calm_term_store*, calm_tid);



/* -------------------------------------------------------------------------- */

calm_table* calm_table_create(const size_t);
void calm_table_delete(calm_table**);
CalmSID calm_table_store(const calm_table*, const char * const);
const char * const calm_table_retrieve(const calm_table* const, const CalmSID);
CalmSID calm_table_next(const calm_table* const, const CalmSID);

#pragma mark - auxiliary functions

calm_cidx calm_cidx_get(const char* const cstring, size_t pos) {
    calm_cidx cidx = cstring[pos];
    while (cidx < 0) {
        // printf("%s %zu %d %d\n", cstring,pos,cidx,cidx+256);
        cidx += 256;
    }
    return cidx;
}


calm_table* calm_table_check(void* symbolTableRef) {
    calm_table* ref = (calm_table*)symbolTableRef;
    assert(ref->signature == CALM_PARSING_TABLE_SIGNATURE);
    return ref;
}

CalmId calm_label(char *cstring) { printf("%s\n",cstring); return 0; }


#pragma mark - shared definitions
calm_memory* calm_memory_create(size_t capacity, size_t unitsize) {
    
    calm_memory* ref = calloc(1, sizeof(calm_memory));
    
    if (ref == NULL) return NULL;
    
    ref->capacity = 0;
    ref->size = 0;
    
    if (calm_memory_ensure(ref, capacity > 0 ? capacity : 1, unitsize) == CALM_FAILED) {
        free(ref);
        return NULL;
    }
    
    return ref;
}

CALM_STATUS calm_memory_ensure(calm_memory* ref, size_t capacity, size_t unitsize) {
    
    if (capacity <= ref->capacity) return CALM_OK;
    
    size_t old_capacity = ref->capacity;
    size_t new_capacity = old_capacity > 0 ? old_capacity : 1;
    while (new_capacity < capacity) new_capacity *= 2;
    
    void* new_memory = realloc(ref->memory, new_capacity * unitsize);
    
    if (new_memory == NULL)  return CALM_FAILED;
    
    ref->memory = new_memory;
    ref->capacity = new_capacity;
    
    printf("capacity: %zu ≤ %zu ≤ %zu\n", old_capacity, capacity, new_capacity);
    
    return CALM_OK;
    
}

void calm_memory_delete(calm_memory** refref) {
    if (*refref == NULL) return;
    
    if ((*refref)->memory != NULL) {
        free((*refref)->memory);
    }
    
    free(*refref);
    *refref = NULL;
}

#pragma mark - (strings) store

calm_char_store* calm_char_store_create(size_t capacity) {
    assert(sizeof(calm_memory) == sizeof(calm_char_store));
    assert(offsetof(calm_memory, memory) == offsetof(calm_char_store, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_char_store, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_char_store, size));
    
    calm_char_store* store_ref = (calm_char_store*)calm_memory_create(capacity, sizeof(char));
    
    if (store_ref == NULL) return NULL;
    
    *(store_ref->memory) = '\0';  // 0-terminator of empty string
    store_ref->size = 1;
    
    return store_ref;
}

CALM_STATUS calm_char_store_ensure(calm_char_store* store_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)store_ref, capacity, sizeof(char));
}

void calm_char_store_delete(calm_char_store** store_ref_ref) {
    calm_memory_delete((calm_memory**)store_ref_ref);
}

CalmSID calm_char_store_append(calm_char_store* store_ref, const char* const cstring) {
    assert(store_ref->memory != NULL);
    assert(store_ref->capacity >= 1);
    assert(store_ref->capacity >= store_ref->size);
    assert(store_ref->size >= 1);
    assert(*(store_ref->memory) == '\0');
    
    size_t sid = store_ref->size;
    size_t len = strlen(cstring);
    
    if (len == 0) return (CalmSID)0;   // empty string's sid is always zero.
    
    if (calm_char_store_ensure(store_ref, store_ref->size + len + 1) != CALM_OK) {
        return (CalmSID)0;
    }
    
    char *dest = store_ref->memory + store_ref->size;
    
    char *copy = strncpy(dest, cstring, len+1);
    
    assert(copy == dest);
    assert(strlen(dest) == len);
    assert(*(dest+len) == '\0');
    
    store_ref->size += len+1;
    
    return sid;
}

const char* const calm_char_store_retrieve(calm_char_store* store_ref, const CalmSID sid) {
    if(store_ref == NULL || sid >= store_ref->size) {
        return NULL;
    }
    
    return store_ref->memory + sid;
}

#pragma mark - (strings) trie

calm_prefix_store* calm_prefix_store_create(size_t capacity) {
    assert(sizeof(calm_memory) == sizeof(calm_prefix_store));
    assert(offsetof(calm_memory, memory) == offsetof(calm_prefix_store, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_prefix_store, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_prefix_store, size));
    
    calm_prefix_store* trie_ref = (calm_prefix_store*)calm_memory_create(capacity, sizeof(calm_prefix_node));
    
    if (trie_ref == NULL) return NULL;
    
    calm_pid tid = calm_prefix_store_append(trie_ref, 0);
    
    assert(tid == 0);
    assert((trie_ref->memory)->sid == 0);
    assert((trie_ref->memory)->nexts[0] == 0);
    assert((trie_ref->memory)->nexts[255] == 0);
    
    return trie_ref;
}

CALM_STATUS calm_prefix_store_ensure(calm_prefix_store* trie_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)trie_ref, capacity, sizeof(calm_prefix_node));
}

void calm_prefix_store_delete(calm_prefix_store** trie_ref_ref) {
    calm_memory_delete((calm_memory**)trie_ref_ref);
}

calm_pid calm_prefix_store_append(calm_prefix_store * trie_ref, calm_sid sid) {
    calm_pid tid = trie_ref->size;
    
    if ( calm_prefix_store_ensure(trie_ref, (trie_ref->size)+1) != CALM_OK) {
        return (calm_pid)0;
    }
    
    trie_ref->size += 1;
    
    calm_prefix_node *node = (trie_ref->memory + tid);
    
    node->sid = sid;
    for (calm_cidx cidx=0; cidx<256; cidx++) {
        node->nexts[cidx] = (calm_pid)0;
    }
    
    return tid;
    
}
calm_prefix_node* calm_prefix_store_retrieve(calm_prefix_store* trie_ref, calm_pid tid) {
    if (trie_ref == NULL || tid >= trie_ref->size) {
        return NULL;
    }
    
    return trie_ref->memory + tid;
}

calm_pid calm_prefix_build_step(calm_prefix_store* trie_ref, calm_pid tid, calm_cidx cidx) {
    assert(0 <= cidx);
    assert(cidx < 256);
    
    calm_prefix_node * node_ref = calm_prefix_store_retrieve(trie_ref, tid);
    assert(node_ref != NULL);
    
    calm_pid next_tid = node_ref->nexts[cidx];
    
    if (next_tid == 0) {
        void* old_memory = trie_ref->memory;
        size_t old_capacity = trie_ref->capacity;
        size_t old_size = trie_ref->size;
        
        next_tid = calm_prefix_store_append(trie_ref, 0);
        
        assert(trie_ref->capacity >= old_capacity);
        assert(trie_ref->size == old_size+1);
        
        if (old_memory != trie_ref->memory) {
            node_ref = calm_prefix_store_retrieve(trie_ref, tid);
            assert(node_ref != NULL);
        }
        
        node_ref->nexts[cidx] = next_tid;
    }
    
    return next_tid;
    
    
}

calm_pid calm_prefix_build_path(calm_prefix_store* trie_ref, const char* const cstring) {
    assert(trie_ref != NULL);
    assert(trie_ref->memory != NULL);
    assert(trie_ref->capacity > 0);
    assert(trie_ref->size > 0);
    
    calm_pid tid = (calm_pid)0;
    size_t len = strlen(cstring);
    size_t pos = (size_t)0;
    
    while (pos < len) {
        calm_cidx cidx = calm_cidx_get(cstring,pos);
        
        tid = calm_prefix_build_step(trie_ref, tid, cidx);
        
        assert(0 < tid);
        assert(tid < trie_ref->size);
        
        pos += 1;
    }
    
    return tid;
}

#pragma mark - vertices (terms)

calm_term_store* calm_term_store_create(size_t capacity) {
    
    assert(sizeof(calm_memory) == sizeof(calm_term_store));
    assert(offsetof(calm_memory, memory) == offsetof(calm_term_store, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_term_store, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_term_store, size));
    
    calm_term_store* term_store_ref = (calm_term_store*)calm_memory_create(capacity, sizeof(calm_term_node));
    
    if (term_store_ref == NULL) return NULL;
    
    calm_tid vid = calm_term_store_append(term_store_ref, 0,0,0,CALM_TYPE_UNKNOWN);
    
    assert(vid == 0);
    assert((term_store_ref->memory)->sid == 0);
    
    return term_store_ref;
    
}

CALM_STATUS calm_term_store_ensure(calm_term_store* term_store_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)term_store_ref, capacity, sizeof(calm_term_node));
}

void calm_term_store_delete(calm_term_store** term_store_ref_ref) {
    calm_memory_delete((calm_memory**)term_store_ref_ref);
}

calm_tid calm_term_store_append(calm_term_store* term_store_ref, calm_sid sid, calm_tid sibling, calm_tid child, CALM_TYPE type) {
    calm_tid vid = term_store_ref->size;
    
    if ( calm_term_store_ensure(term_store_ref, (term_store_ref->size)+1) != CALM_OK) {
        return (calm_tid)0;
    }
    
    term_store_ref->size += 1;
    
    calm_term_node *vertex = (term_store_ref->memory + vid);
    
    vertex->sid = sid;          // no name
    vertex->sibling = sibling;      // no sibling
    vertex->child = child;        // no child
    vertex->type = type;   // no type
    
    return vid;
}

calm_term_node* calm_term_store_retrieve(calm_term_store* term_store_ref, calm_tid vid) {
    if (term_store_ref == NULL || vid > term_store_ref->size) return NULL;
    
    return term_store_ref->memory + vid;
}

#pragma mark - symbol table

calm_table* calm_table_create(const size_t capacity) {
    calm_table *table_ref = calloc(1,sizeof(calm_table));
    table_ref->signature = CALM_PARSING_TABLE_SIGNATURE;
    table_ref->strings = calm_char_store_create(capacity);
    table_ref->prefixes = calm_prefix_store_create(capacity);
    table_ref->terms = calm_term_store_create(capacity/10);
    return table_ref;
    
}
void calm_table_delete(calm_table** refref) {
    assert(refref != NULL);
    calm_table* ref = *refref;
    assert(ref->signature == CALM_PARSING_TABLE_SIGNATURE);
    
    if (ref != NULL) {
        
        calm_char_store_delete(&(ref->strings));
        assert(ref->strings == NULL);
        
        calm_prefix_store_delete(&(ref->prefixes));
        assert(ref->prefixes == NULL);
        
        calm_term_store_delete(&(ref->terms));
        assert(ref->terms == NULL);
        
        free(ref);
        *refref = NULL;
    }
    
    assert(*refref == NULL);
}

CalmSID calm_table_store(const calm_table* const table_ref, const char * const cstring) {
    assert(table_ref != NULL);
    assert(table_ref->prefixes != NULL);
    assert(table_ref->strings != NULL);
    
    if (strlen(cstring) == 0) return 0;
    
    calm_pid tid = calm_prefix_build_path(table_ref->prefixes, cstring);
    assert(0 < tid);
    
    calm_prefix_node* node_ref = calm_prefix_store_retrieve(table_ref->prefixes, tid);
    if (node_ref->sid == 0) {
        node_ref->sid = calm_char_store_append(table_ref->strings, cstring);
    }
    
    return node_ref->sid;
    
    
}

CalmSID calm_table_next(const calm_table* const table_ref, const CalmSID sid) {
    const char* const cstring = calm_table_retrieve(table_ref,sid);
    
    if (cstring == NULL) return (CalmSID)0;
    
    size_t len = strlen(cstring);
    
    CalmSID next_sid = sid + len + 1;
    
    if (next_sid >= table_ref->strings->size) return (CalmSID)0;
    
    return next_sid;
}

const char * const calm_table_retrieve(const calm_table* const table_ref, const CalmSID sid) {
    assert(table_ref != NULL);
    assert(table_ref->strings != NULL);
    
    return calm_char_store_retrieve(table_ref->strings, sid);
}


/* ************************************************************************** */


#pragma mark - 'public' functions definitions

CalmParsingTableRef calmMakeParsingTable(size_t capacity) {
    return calm_table_create(capacity);
}

void calmDeleteParsingTable(CalmParsingTableRef* symbolTableRefRef) {
    calm_table_delete((calm_table**)symbolTableRefRef);
}

CalmSID calmStoreSymbol(CalmParsingTableRef symbolTableRef, const char * const cstring) {
    return calm_table_store(calm_table_check(symbolTableRef), cstring);
}

CalmSID calmNextSymbol(CalmParsingTableRef symbolTableRef, CalmSID sid) {
    return calm_table_next(calm_table_check(symbolTableRef), sid);
}

const char* const calmGetSymbol(CalmParsingTableRef symbolTableRef, CalmSID sid) {
    return calm_table_retrieve(calm_table_check(symbolTableRef), sid);
}



/* */


CalmTID calmStoreConnective(CalmParsingTableRef symbolTableRef, CalmSID sid, CalmTID firstchild) {
    return calm_term_store_append(calm_table_check(symbolTableRef)->terms, sid, 0, firstchild, CALM_CONNECTIVE);
}



CalmTID calmStoreEquational(CalmParsingTableRef symbolTableRef,CalmSID sid, CalmTID firstchild) {
    return calm_term_store_append(calm_table_check(symbolTableRef)->terms, sid, 0, firstchild, CALM_EQUATIONAL);
}

CalmTID calmStoreFunctional(CalmParsingTableRef symbolTableRef,CalmSID sid, CalmTID firstchild) {
    return calm_term_store_append(calm_table_check(symbolTableRef)->terms, sid, 0, firstchild, CALM_FUNCTIONAL);
}

CalmTID calmStoreConstant(CalmParsingTableRef symbolTableRef, CalmSID sid) {
    return calm_term_store_append(calm_table_check(symbolTableRef)->terms, sid, 0, 0, CALM_FUNCTIONAL);
}

CalmTID calmStoreVariable(CalmParsingTableRef symbolTableRef, CalmSID sid) {
    return calm_term_store_append(calm_table_check(symbolTableRef)->terms, sid, 0, 0, CALM_VARIABLE);
    
}

/****/

CalmTID calmLinkTerms(CalmParsingTableRef symbolTableRef,CalmTID first,CalmTID next) {
    calm_term_node *node = calm_term_store_retrieve(calm_table_check(symbolTableRef)->terms, first);
    assert(node != NULL);
    assert(node->sibling == 0);
    
    node->sibling = next;
    
    return first;
    
}

void calmTermsAppend(CalmParsingTableRef symbolTableRef, CalmTID first, CalmTID last) {
    calm_term_node *node = calm_term_store_retrieve(calm_table_check(symbolTableRef)->terms, first);
    assert(node != NULL);
    
    if (node->sibling == 0) {
        node->sibling = last;
    }
    else {
        calmTermsAppend(symbolTableRef, node->sibling, last);
    }
    
    
}




