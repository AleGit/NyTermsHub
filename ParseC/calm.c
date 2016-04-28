//
//  cdata.c
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "calm.h"

typedef size_t calm_sid;   // string identifier
typedef size_t calm_tid;   // trie node identifier

typedef enum { CALM_FAILED = -1, CALM_OK = 0 } CALM_STATUS;

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
    calm_sid sid;
    calm_tid nexts[256];
} calm_trie_node;

typedef struct {
    calm_trie_node *memory;
    size_t capacity;
    size_t size;
} calm_trie;

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
calm_tid calm_trie_append_one(calm_trie * trie_ref);
calm_tid calm_trie_save(calm_trie* trie_ref, const char* const cstring);
calm_trie_node* calm_trie_retrieve(calm_trie* trie_ref, calm_tid tid);


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
    assert(sid < store_ref->size);
    
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
    
    calm_tid tid = calm_trie_append_one(trie_ref);
    
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

calm_tid calm_trie_append_one(calm_trie * trie_ref) {
    calm_tid tid = trie_ref->size;
    
    if ( calm_trie_ensure(trie_ref, (trie_ref->size)+1) != CALM_OK) {
        return (calm_tid)0;
    }
    
    trie_ref->size += 1;
    
    calm_trie_node *node = (trie_ref->memory + tid);
    
    node->sid = (calm_sid)0;
    for (int i=0; i<256; i++) {
        node->nexts[i] = (calm_tid)0;
    }
    
    return tid;
    
}

calm_tid calm_trie_save(calm_trie* trie_ref, const char* const cstring) {
    
    return (calm_tid)0;
}
calm_trie_node* calm_trie_retrieve(calm_trie* trie_ref, calm_tid tid) {
    assert(tid < trie_ref->size);
    
    return trie_ref->memory + tid;
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
    calm_trie_delete(&trie_ref);
    assert(trie_ref == NULL);
    
}


