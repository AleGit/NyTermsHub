//
//  cdata.c
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "calm.h"

typedef calm_id calm_sid;   // string identifier
typedef calm_id calm_tid;   // trie node identifier

typedef int calm_cidx;

typedef enum { CALM_FAILED = -1, CALM_OK = 0 } CALM_STATUS;

typedef struct {
    calm_sid sid;
    calm_tid nexts[256];
} calm_trie_node;

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
    calm_store* store;
    calm_trie* trie;
} calm_table;

#pragma mark - declarations

calm_memory* calm_memory_create(size_t capacity, size_t unitsize);
CALM_STATUS calm_memory_ensure(calm_memory* ref, size_t capacity, size_t unitsize);
void calm_memory_delete(calm_memory** refref);

calm_store* calm_store_create(size_t capacity);
CALM_STATUS calm_store_ensure(calm_store* store_ref, size_t capacity);
void calm_store_delete(calm_store** store_ref);
calm_sid calm_store_save(calm_store* store_ref, const char* const cstring);
const char* const calm_store_retrieve(calm_store* store_ref, const calm_sid sid);

calm_trie* calm_trie_create(size_t capacity);
CALM_STATUS calm_trie_ensure(calm_trie* trie_ref, size_t capacity);
void calm_trie_delete(calm_trie** trie_ref);

calm_tid calm_trie_node_append(calm_trie * trie_ref);
calm_trie_node* calm_trie_retrieve(calm_trie* trie_ref, calm_tid tid);

calm_tid calm_trie_node_next(calm_trie* trie_ref, calm_tid tid, calm_cidx cidx);
calm_tid calm_trie_build_prefix(calm_trie* trie_ref, const char* const cstring);

calm_table* calm_table_create(size_t capacity);
void calm_table_delete(calm_table**);


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

#pragma mark - symbol table

calm_table* calm_table_create(size_t capacity) {
    calm_table *table_ref = calloc(1,sizeof(calm_table));
    table_ref->store = calm_store_create(capacity);
    table_ref->trie = calm_trie_create(capacity);
    return table_ref;
    
}
void calm_table_delete(calm_table** refref) {
    assert(refref != NULL);
    
    calm_table* ref = *refref;
    
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

calm_table* internal_calm_table;

void calm_table_init() {
    assert(internal_calm_table == NULL);
    
    internal_calm_table = calm_table_create(1);
}

void calm_table_exit() {
    assert(internal_calm_table != NULL);
    
    calm_table_delete(&internal_calm_table);
}

calm_id calm_table_store(const char * const cstring) {
    assert(internal_calm_table != NULL);
    assert(internal_calm_table->trie != NULL);
    assert(internal_calm_table->store != NULL);
    
    if (strlen(cstring) == 0) return 0;
    
    calm_tid tid = calm_trie_build_prefix(internal_calm_table->trie, cstring);
    assert(0 < tid);
    
    calm_trie_node* node_ref = calm_trie_retrieve(internal_calm_table->trie, tid);
    if (node_ref->sid == 0) {
        node_ref->sid = calm_store_save(internal_calm_table->store, cstring);
    }
    
    return node_ref->sid;
    
    
}

calm_sid calm_table_next(calm_sid sid) {
    const char* const cstring = calm_table_retrieve(sid);
    
    if (cstring == NULL) return (calm_sid)0;
    
    size_t len = strlen(cstring);
    
    calm_sid next_sid = sid + len + 1;
    
    if (next_sid >= internal_calm_table->store->size) return (calm_sid)0;
    
    return next_sid;
}

const char * const calm_table_retrieve(const calm_id sid) {
    assert(internal_calm_table != NULL);
    assert(internal_calm_table->store != NULL);
    
    return calm_store_retrieve(internal_calm_table->store, sid);
}


/* ************************************************************************** */
#pragma mark - demo

#define X(id) calm_store_retrieve(store_ref,id)
void calm_store_demo() {
    calm_store * store_ref = calm_store_create(1);
    
    for (int i = 0; i <500; i++) {
        calm_sid a = calm_store_save(store_ref, "Hello");
        calm_sid b = calm_store_save(store_ref, ", ");
        calm_sid c = calm_store_save(store_ref, "World");
        calm_sid d = calm_store_save(store_ref, "!");
        calm_sid e = calm_store_save(store_ref, "");
        calm_sid f = calm_store_save(store_ref, "Hello");
        
        printf("%zu %zu %zu %zu %zu - %zu /**/ %s%s%s%s%s - %s\n",
               a,b,c,d,e,f, /**/ X(a),X(b),X(c),X(d),X(e),X(f));
        
    }
    calm_store_delete(&store_ref);
    assert(store_ref == NULL);
    calm_store_delete(&store_ref);
    
    

    
}

void calm_trie_demo() {
    calm_trie * trie_ref = calm_trie_create(5);
    assert(trie_ref != NULL);
    assert(trie_ref->size = 1);
    
    calm_trie_node *node_ref = calm_trie_retrieve(trie_ref, 0);
    
    assert(node_ref == trie_ref -> memory);
    
    node_ref = calm_trie_retrieve(trie_ref, 1);
    
    assert(node_ref == NULL);
    
    calm_tid tid0 = calm_trie_build_prefix(trie_ref, "Hello, World!");
    calm_tid tid1 = calm_trie_build_prefix(trie_ref, "How are you?");
    calm_tid tid2 = calm_trie_build_prefix(trie_ref, "Hello, World!");
    
    printf("%zu %zu %zu\n",tid0,tid1,tid2);
    assert(tid0 != tid1);
    assert(tid0 == tid2);
    
    assert(tid0 == 13);
    
    
    calm_trie_delete(&trie_ref);
    assert(trie_ref == NULL);
    
}




