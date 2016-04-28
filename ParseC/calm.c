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
    char *memory;
    size_t capacity;
    size_t size;
} calm_string_store;

#pragma mark - declarations

calm_string_store * calm_string_store_create(size_t capacity);
CALM_STATUS calm_string_store_ensure(calm_string_store* store_ref, size_t capacity);
void calm_string_store_release(calm_string_store* store_ref);

calm_sid calm_string_store_save(calm_string_store* store_ref, const char* const cstring);
const char* const calm_string_store_retrieve(calm_string_store* store_ref, const calm_sid sid);

#pragma mark - definitions
calm_string_store* calm_string_store_create(size_t capacity) {
    
    calm_string_store* store_ref = calloc(1, sizeof(calm_string_store));
    
    if (store_ref == NULL) return NULL;
    
    store_ref->capacity = 0;
    store_ref->size = 0;
    
    if (calm_string_store_ensure(store_ref, capacity > 0 ? capacity : 1) == CALM_FAILED) {
        free(store_ref);
        return NULL;
    }
    
    *(store_ref->memory) = '\0';  // 0-terminator of empty string
    store_ref->size = 1;
    
    return store_ref;
}

CALM_STATUS calm_string_store_ensure(calm_string_store* store_ref, size_t capacity) {
    assert(store_ref->size <= store_ref->capacity);
    
    if (capacity <= store_ref->capacity) return CALM_OK;
    
    size_t old_capacity = store_ref->capacity;
    size_t new_capacity = old_capacity > 0 ? old_capacity : 1;
    while (new_capacity < capacity) new_capacity *= 2;
    
    void* new_memory = realloc(store_ref->memory, new_capacity * sizeof(char));
    
    if (new_memory == NULL)  return CALM_FAILED;
    
    store_ref->memory = new_memory;
    store_ref->capacity = new_capacity;
    
    printf("string store capacity: %zu ≤ %zu ≤ %zu\n", old_capacity, capacity, new_capacity);
    
    return CALM_OK;
}

void calm_string_store_delete(calm_string_store** store_ref_ref) {
    
    if (*store_ref_ref == NULL) return;
    
    if ((*store_ref_ref)->memory != NULL) {
        free((*store_ref_ref)->memory);
    }
    
    free(*store_ref_ref);
    *store_ref_ref = NULL;
}

calm_sid calm_string_store_save(calm_string_store* store_ref, const char* const cstring) {
    assert(store_ref->memory != NULL);
    assert(store_ref->capacity >= 1);
    assert(store_ref->capacity >= store_ref->size);
    assert(store_ref->size >= 1);
    assert(*(store_ref->memory) == '\0');
    
    size_t sid = store_ref->size;
    size_t len = strlen(cstring);
    
    if (len == 0) return (calm_sid)0;   // empty string's sid is always zero.
    
    if (calm_string_store_ensure(store_ref, store_ref->size + len + 1) != CALM_OK) {
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


const char* const calm_string_store_retrieve(calm_string_store* store_ref, const calm_sid sid) {
    assert(sid < store_ref->size);
    
    return store_ref->memory + sid;
}


/* ************************************************************************** */
#pragma mark - demo

#define X(id) calm_string_store_retrieve(store_ref,id)
void calm_string_store_demo() {
    calm_string_store * store_ref = calm_string_store_create(1);
    
    for (int i = 0; i <500; i++) {
        calm_sid a = calm_string_store_save(store_ref, "Hello");
        calm_sid b = calm_string_store_save(store_ref, ", ");
        calm_sid c = calm_string_store_save(store_ref, "World");
        calm_sid d = calm_string_store_save(store_ref, "!");
        calm_sid e = calm_string_store_save(store_ref, "");
        calm_sid f = calm_string_store_save(store_ref, "Hello");
        
        printf("%zu %zu %zu %zu %zu - %zu /**/ %s%s%s%s%s - %s\n",
               a,b,c,d,e,f, /**/ X(a),X(b),X(c),X(d),X(e),X(f));
        
    }
    calm_string_store_delete(&store_ref);
    assert(store_ref == NULL);
    calm_string_store_delete(&store_ref);
}


