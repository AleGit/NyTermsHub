//
//  MereData.c
//  NyTerms
//
//  Created by Alexander Maringele on 27.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#include "MereData.h"

/* ============================================================== */
#pragma mark makros

#define MERE_MIN_SIZE 100

#define ALLOC_SIZE(base,count,capacity,need,single) \
    capacity = need >= MERE_MIN_SIZE ? need : MERE_MIN_SIZE; \
    base = malloc(capacity * single); \
    if (mere_parser_exit_if_null(base)) return false; \
    count = 0;

#define STRUCTURE_INIT(p, capacity, single) \
    p->count = 0; \
    p->capacity = capacity >= MERE_MIN_SIZE ? capacity : MERE_MIN_SIZE; \
    p->base = malloc(p->capacity * single);

#define ENSURE_SIZE(base,count,capacity,need,single) \
    while ( (count+need) > capacity) { \
        printf("%lu %lu %lu\n", count, need, capacity); \
        capacity *= 2; \
        base = realloc(base, capacity * single); \
    } \
    count += need;

#define FREE_BASE(base) \
    if (base != NULL) free(base); \
    base == NULL;

/* ============================================================- */
#pragma mark data structures

typedef struct {
    char * base;
    size_t count;
    size_t capacity;
} mere_strings_type;

typedef ptrdiff_t TID;

typedef struct {
    SID sid;
    TID nexts[256];
} mere_trie_node;

typedef struct {
    mere_trie_node * base;
    size_t count;
    size_t capacity;
} mere_trie_type;

//typedef struct {
//    SID sid;
//    EID next;   /* 0 => no next entry */
//} mere_entry;


/* ============================================================- */
#pragma mark data

mere_strings_type mere_strings;
mere_trie_type mere_trie;

//size_t mere_data_entries_capacity;
//mere_entry* mere_data_entries_base;
//mere_entry* mere_data_entries_next;
//
//size_t mere_data_nodes_capacity;
//mere_node* mere_data_nodes_base;
//mere_node* mere_data_nodes_next;

/* ============================================================== */
#pragma mark local functions declarations
bool mere_parser_exit_if_null(void *ptr);

TID mere_trie_node_create();

/* ============================================================== */
#pragma mark local functions definitions

bool mere_parser_exit_if_null(void *ptr) {
    if (ptr == NULL) {
        mere_parser_exit();
        return true;
    }
    return false;
}


/* ============================================================== */
#pragma mark - global functions definitions

bool mere_parser_init(size_t size) {
    ALLOC_SIZE(mere_trie.base, mere_trie.count, mere_trie.capacity, size, sizeof(mere_trie_node))
    
    for (int i=0; i<256; i++) {
        mere_trie.base->nexts[i] = -1;
    }
    
    ALLOC_SIZE(mere_strings.base, mere_strings.count, mere_strings.capacity, size, sizeof(char))
    
    *mere_strings.base = (char)0; /* sid==0 => empty string */
    mere_strings.count += 1;
    
    // ALLOC_SIZE(mere_data_entries_base, mere_data_entries_next, mere_data_entries_capacity, size, sizeof(mere_entry))
    // ALLOC_SIZE(mere_data_nodes_base, mere_data_nodes_next, mere_data_nodes_capacity, size, sizeof(mere_node))
    
    return true;
}

void mere_parser_exit() {
    FREE_BASE(mere_trie.base)
    FREE_BASE(mere_strings.base)
    
    // FREE_BASE(mere_data_entries_base)
    // FREE_BASE(mere_data_nodes_base)
}

/* ------------------------------------------------------------- */
#pragma mark global trie functions definitions
TID mere_trie_node_create() {
    size_t need = 1;
    TID position = mere_trie.count;
    
    ENSURE_SIZE(mere_trie.base, mere_trie.count, mere_trie.capacity, need, sizeof(mere_trie_node));
    
    mere_trie_node * pnode = mere_trie.base + position;
    for (int i=0; i<256; i++) {
        pnode->nexts[i] = -1;
    }
    return position;
}

/* ------------------------------------------------------------- */
#pragma mark global string functions definitions

SID mere_string_create(char const * _Nonnull cstring) {
    size_t need = strlen(cstring) + 1;
    
    SID position = mere_strings.count;
    
    ENSURE_SIZE(mere_strings.base, mere_strings.count, mere_strings.capacity, need, sizeof(char));
    
    char* dest = mere_strings.base + position;
    strncpy(dest, cstring, need); // include terminating zero-byte
    
    assert('\0' == *(dest+(need-1))); // check termnating zero-byte
    assert(strlen(dest) == (need-1));
    
    return position;
}

SID mere_insert_string(TID tid, char const * _Nonnull cstring, size_t len, size_t pos) {
    assert(pos <= len);
    
    if (len == 0) return 0; // the empty string
    
    if (pos == len) {
        if ((mere_trie.base + tid)->sid <= 0) {
            SID sid = mere_string_create(cstring);
            (mere_trie.base + tid)->sid = sid;
        }
        return (mere_trie.base + tid)->sid;
    }
    
    // len < pos
    
    char c = cstring[pos];
    TID next = (mere_trie.base + tid)->nexts[c];
    
    if (next < 0) {
        next = mere_trie_node_create();
        (mere_trie.base + tid)->nexts[c] = next;
    }
    
    // printf("%c %zd : ", c, next);
    
    return mere_insert_string(next, cstring, len, pos+1);
}

SID mere_string_store(char const * _Nonnull cstring) {
    SID sid = mere_insert_string(0, cstring, strlen(cstring), 0);
    return sid;
}

char * mere_string_retrieve(SID sid) {
    assert( sid < mere_strings.capacity);
    assert( sid == 0 || '\0' == *(mere_strings.base + (sid-1)));
    
    return mere_strings.base + sid;
}

/* ------------------------------------------------------------- */
#pragma mark global entry functions definitions

//EID mere_entry_create(SID sid) {
//    ENSURE_SIZE(mere_data_entries_base, mere_data_entries_next, mere_data_entries_capacity, (size_t)1, sizeof(mere_entry))
//    
//    mere_entry * dest = mere_data_entries_next;
//    mere_data_entries_next += 1;
//    
//    dest->sid = sid;
//    dest->next = -1; // no next entry.
//    
//    return position;
//}
//
//void mere_entry_append(EID eid, SID sid) {
//    EID eidsid = mere_entry_create(sid);
//    mere_entry *peid = mere_data_entries_base + eid;
//    while (peid->next >= 0) {
//        peid = mere_data_entries_base + peid->next;
//    }
//    peid->next = eidsid;
//}
//
//int mere_entry_count(EID eid) {
//    int count = 1;
//    mere_entry *peid = mere_data_entries_base + eid;
//    while (peid->next >= 0) {
//        peid = mere_data_entries_base + peid->next;
//        count += 1;
//    }
//    return count;
//}
//
//SID mere_entry_string(EID eid, int index) {
//    int count = 0;
//    mere_entry *peid = mere_data_entries_base + eid;
//    while (count < index) {
//        assert(peid->next >= 0);
//        peid = mere_data_entries_base + peid->next;
//        count += 1;
//    }
//    return peid->sid;
//}