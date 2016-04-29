//
//  cdata.c
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "calm.h"

#define CALM_SYMBOL_TABLE_SIGNATURE 0xFEDCBA9876543210

#pragma mark 'private' functions (declarations)

typedef CalmId calm_sid;   // string identifier
typedef CalmId calm_tid;   // trie node identifier
typedef CalmId calm_vid;

typedef int calm_cidx;

typedef enum { CALM_FAILED = -1, CALM_OK = 0 } CALM_STATUS;

typedef struct {
    calm_sid sid;
    calm_tid nexts[256];
} calm_trie_node;

typedef struct calm_vertex {
    calm_sid sid;
    calm_vid *children; // dynamically allocated
    size_t size;    // 0...256
    size_t capacity; // 0,4,16,256
} calm_vertex;

typedef struct {
    void * memory;
    size_t capacity;
    size_t size;
} calm_memory;

typedef struct {
    char *memory;
    size_t capacity;
    size_t size;
} calm_store;

typedef struct {
    calm_trie_node *memory;
    size_t capacity;
    size_t size;
} calm_trie;

typedef struct {
    calm_vertex *memory;
    size_t capacity;
    size_t size;
} calm_vertices;


typedef struct {
    unsigned long signature;
    calm_store* store;
    calm_trie* trie;
} calm_table;

/* memory */

calm_memory* calm_memory_create(size_t capacity, size_t unitsize);
CALM_STATUS calm_memory_ensure(calm_memory* ref, size_t capacity, size_t unitsize);
void calm_memory_delete(calm_memory** refref);

/* (string) store */

calm_store* calm_store_create(size_t capacity);
CALM_STATUS calm_store_ensure(calm_store* store_ref, size_t capacity);
void calm_store_delete(calm_store** store_ref);
calm_sid calm_store_save(calm_store* store_ref, const char* const cstring);
const char* const calm_store_retrieve(calm_store* store_ref, const calm_sid sid);

/* trie */

calm_trie* calm_trie_create(size_t capacity);
CALM_STATUS calm_trie_ensure(calm_trie* trie_ref, size_t capacity);
void calm_trie_delete(calm_trie** trie_ref);

calm_tid calm_trie_node_append(calm_trie * trie_ref);
calm_trie_node* calm_trie_retrieve(calm_trie* trie_ref, calm_tid tid);

calm_tid calm_trie_node_next(calm_trie* trie_ref, calm_tid tid, calm_cidx cidx);
calm_tid calm_trie_build_prefix(calm_trie* trie_ref, const char* const cstring);

/* (term) vertices */

calm_vertices* calm_vertices_create(size_t);
CALM_STATUS calm_vertices_ensure(calm_vertices*, size_t);
void calm_vertices_delete(calm_vertices**);

calm_vid calm_vertex_append(calm_vertices*);
calm_vertex* calm_verex_retrieve(calm_vertices*, calm_vid);



/* -------------------------------------------------------------------------- */

calm_table* calm_table_create(const size_t);
void calm_table_delete(calm_table**);
calm_sid calm_table_store(const calm_table*, const char * const);
const char * const calm_table_retrieve(const calm_table* const, const calm_sid);
calm_sid calm_table_next(const calm_table* const, const calm_sid);


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

calm_store* calm_store_create(size_t capacity) {
    assert(sizeof(calm_memory) == sizeof(calm_store));
    assert(offsetof(calm_memory, memory) == offsetof(calm_store, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_store, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_store, size));
    
    calm_store* store_ref = (calm_store*)calm_memory_create(capacity, sizeof(char));
    
    if (store_ref == NULL) return NULL;
    
    *(store_ref->memory) = '\0';  // 0-terminator of empty string
    store_ref->size = 1;
    
    return store_ref;
}

CALM_STATUS calm_store_ensure(calm_store* store_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)store_ref, capacity, sizeof(char));
}

void calm_store_delete(calm_store** store_ref_ref) {
    calm_memory_delete((calm_memory**)store_ref_ref);
}

calm_sid calm_store_save(calm_store* store_ref, const char* const cstring) {
    assert(store_ref->memory != NULL);
    assert(store_ref->capacity >= 1);
    assert(store_ref->capacity >= store_ref->size);
    assert(store_ref->size >= 1);
    assert(*(store_ref->memory) == '\0');
    
    size_t sid = store_ref->size;
    size_t len = strlen(cstring);
    
    if (len == 0) return (calm_sid)0;   // empty string's sid is always zero.
    
    if (calm_store_ensure(store_ref, store_ref->size + len + 1) != CALM_OK) {
        return (calm_sid)0;
    }
    
    char *dest = store_ref->memory + store_ref->size;
    
    char *copy = strncpy(dest, cstring, len+1);
    
    assert(copy == dest);
    assert(strlen(dest) == len);
    assert(*(dest+len) == '\0');
    
    store_ref->size += len+1;
    
    return sid;
}

const char* const calm_store_retrieve(calm_store* store_ref, const calm_sid sid) {
    if(store_ref == NULL || sid >= store_ref->size) {
        return NULL;
    }
    
    return store_ref->memory + sid;
}

#pragma mark - (strings) trie

calm_trie* calm_trie_create(size_t capacity) {
    assert(sizeof(calm_memory) == sizeof(calm_trie));
    assert(offsetof(calm_memory, memory) == offsetof(calm_trie, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_trie, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_trie, size));
    
    calm_trie* trie_ref = (calm_trie*)calm_memory_create(capacity, sizeof(calm_trie_node));
    
    if (trie_ref == NULL) return NULL;
    
    calm_tid tid = calm_trie_node_append(trie_ref);
    
    assert(tid == 0);
    assert((trie_ref->memory)->sid == 0);
    assert((trie_ref->memory)->nexts[0] == 0);
    assert((trie_ref->memory)->nexts[255] == 0);
    
    return trie_ref;
}

CALM_STATUS calm_trie_ensure(calm_trie* trie_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)trie_ref, capacity, sizeof(calm_trie_node));
}

void calm_trie_delete(calm_trie** trie_ref_ref) {
    calm_memory_delete((calm_memory**)trie_ref_ref);
}

calm_tid calm_trie_node_append(calm_trie * trie_ref) {
    calm_tid tid = trie_ref->size;
    
    if ( calm_trie_ensure(trie_ref, (trie_ref->size)+1) != CALM_OK) {
        return (calm_tid)0;
    }
    
    trie_ref->size += 1;
    
    calm_trie_node *node = (trie_ref->memory + tid);
    
    node->sid = (calm_sid)0;
    for (calm_cidx cidx=0; cidx<256; cidx++) {
        node->nexts[cidx] = (calm_tid)0;
    }
    
    return tid;
    
}
calm_trie_node* calm_trie_retrieve(calm_trie* trie_ref, calm_tid tid) {
    if (trie_ref == NULL || tid >= trie_ref->size) {
        return NULL;
    }
    
    return trie_ref->memory + tid;
}

calm_tid calm_trie_node_next(calm_trie* trie_ref, calm_tid tid, calm_cidx cidx) {
    assert(0 <= cidx);
    assert(cidx < 256);
    
    calm_trie_node * node_ref = calm_trie_retrieve(trie_ref, tid);
    assert(node_ref != NULL);
    
    calm_tid next_tid = node_ref->nexts[cidx];
    
    if (next_tid == 0) {
        void* old_memory = trie_ref->memory;
        size_t old_capacity = trie_ref->capacity;
        size_t old_size = trie_ref->size;
        
        next_tid = calm_trie_node_append(trie_ref);
        
        assert(trie_ref->capacity >= old_capacity);
        assert(trie_ref->size == old_size+1);
        
        if (old_memory != trie_ref->memory) {
            node_ref = calm_trie_retrieve(trie_ref, tid);
            assert(node_ref != NULL);
        }
        
        node_ref->nexts[cidx] = next_tid;
    }
    
    return next_tid;
    
    
}

calm_cidx calm_cidx_get(const char* const cstring, size_t pos) {
    calm_cidx cidx = cstring[pos];
    while (cidx < 0) {
        // printf("%s %zu %d %d\n", cstring,pos,cidx,cidx+256);
        cidx += 256;
    }
    return cidx;
}

calm_tid calm_trie_build_prefix(calm_trie* trie_ref, const char* const cstring) {
    assert(trie_ref != NULL);
    assert(trie_ref->memory != NULL);
    assert(trie_ref->capacity > 0);
    assert(trie_ref->size > 0);
    
    calm_tid tid = (calm_tid)0;
    size_t len = strlen(cstring);
    size_t pos = (size_t)0;
    
    while (pos < len) {
        calm_cidx cidx = calm_cidx_get(cstring,pos);
        
        tid = calm_trie_node_next(trie_ref, tid, cidx);
        
        assert(0 < tid);
        assert(tid < trie_ref->size);
        
        pos += 1;
    }
    
    return tid;
}

#pragma mark - vertices (terms)

calm_vertices* calm_vertices_create(size_t capacity) {
    
    assert(sizeof(calm_memory) == sizeof(calm_vertices));
    assert(offsetof(calm_memory, memory) == offsetof(calm_vertices, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_vertices, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_vertices, size));
    
    calm_vertices* vertices_ref = (calm_vertices*)calm_memory_create(capacity, sizeof(calm_vertex));
    
    if (vertices_ref == NULL) return NULL;
    
    calm_vid vid = calm_vertex_append(vertices_ref);
    
    assert(vid == 0);
    assert((vertices_ref->memory)->sid == 0);
    
    return vertices_ref;
    
}

CALM_STATUS calm_vertices_ensure(calm_vertices* vertices_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)vertices_ref, capacity, sizeof(calm_vertex));
}

void calm_vertices_delete(calm_vertices** vertices_ref_ref) {
    calm_memory_delete((calm_memory**)vertices_ref_ref);
}

calm_vid calm_vertex_append(calm_vertices* vertices_ref) {
    calm_vid vid = vertices_ref->size;
    
    if ( calm_vertices_ensure(vertices_ref, (vertices_ref->size)+1) != CALM_OK) {
        return (calm_vid)0;
    }
    
    vertices_ref->size += 1;
    
    calm_vertex *vertex = (vertices_ref->memory + vid);
    
    vertex->sid = (calm_sid)0;
    vertex->children = NULL;
    vertex->capacity = 0;
    vertex->size = 0;
    
    // implicityl variable "" (empty name)
    
    return vid;
    
}

calm_vertex* calm_verex_retrieve(calm_vertices* vertices_ref, calm_vid vid) {
    if (vertices_ref == NULL || vid > vertices_ref->size) return NULL;
    
    return vertices_ref->memory + vid;
}

#pragma mark - symbol table

calm_table* calm_table_create(const size_t capacity) {
    calm_table *table_ref = calloc(1,sizeof(calm_table));
    table_ref->signature = CALM_SYMBOL_TABLE_SIGNATURE;
    table_ref->store = calm_store_create(capacity);
    table_ref->trie = calm_trie_create(capacity);
    return table_ref;
    
}
void calm_table_delete(calm_table** refref) {
    assert(refref != NULL);
    calm_table* ref = *refref;
    assert(ref->signature == CALM_SYMBOL_TABLE_SIGNATURE);
    
    if (ref != NULL) {
        
        calm_store_delete(&(ref->store));
        assert(ref->store == NULL);
        calm_trie_delete(&(ref->trie));
        assert(ref->trie == NULL);
        free(ref);
        *refref = NULL;
    }
    
    assert(*refref == NULL);
}

calm_sid calm_table_store(const calm_table* const table_ref, const char * const cstring) {
    assert(table_ref != NULL);
    assert(table_ref->trie != NULL);
    assert(table_ref->store != NULL);
    
    if (strlen(cstring) == 0) return 0;
    
    calm_tid tid = calm_trie_build_prefix(table_ref->trie, cstring);
    assert(0 < tid);
    
    calm_trie_node* node_ref = calm_trie_retrieve(table_ref->trie, tid);
    if (node_ref->sid == 0) {
        node_ref->sid = calm_store_save(table_ref->store, cstring);
    }
    
    return node_ref->sid;
    
    
}

calm_sid calm_table_next(const calm_table* const table_ref, const calm_sid sid) {
    const char* const cstring = calm_table_retrieve(table_ref,sid);
    
    if (cstring == NULL) return (calm_sid)0;
    
    size_t len = strlen(cstring);
    
    calm_sid next_sid = sid + len + 1;
    
    if (next_sid >= table_ref->store->size) return (calm_sid)0;
    
    return next_sid;
}

const char * const calm_table_retrieve(const calm_table* const table_ref, const calm_sid sid) {
    assert(table_ref != NULL);
    assert(table_ref->store != NULL);
    
    return calm_store_retrieve(table_ref->store, sid);
}


/* ************************************************************************** */

calm_table* calm_table_check(void* symbolTableRef) {
    calm_table* ref = (calm_table*)symbolTableRef;
    assert(ref->signature == CALM_SYMBOL_TABLE_SIGNATURE);
    return ref;
}

#pragma mark - 'public' functions

CalmSymbolTableRef calmMakeSymbolTable(size_t capacity) {
    return calm_table_create(capacity);
}
void calmDeleteSymbolTable(CalmSymbolTableRef* symbolTableRefRef) {
    calm_table_delete((calm_table**)symbolTableRefRef);
}

CalmId calmStoreSymbol(CalmSymbolTableRef symbolTableRef, const char * const cstring) {
    return calm_table_store(calm_table_check(symbolTableRef), cstring);
}

CalmId calmNextSymbol(CalmSymbolTableRef symbolTableRef, CalmId sid) {
    return calm_table_next(calm_table_check(symbolTableRef), sid);
}

const char* const calmGetSybmol(CalmSymbolTableRef symbolTableRef, CalmId sid) {
    return calm_table_retrieve(calm_table_check(symbolTableRef), sid);
}




