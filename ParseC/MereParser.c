//
//  MereParser.c
//  NyTerms
//
//  Created by Alexander Maringele on 14.03.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

// #include <stdio.h>
#import "MereParser.h"

size_t mere_cstrings_size;

char* mere_cstrings;
char* next_cstring;

size_t mere_entries_size;
mere_entry * mere_entries;
mere_entry * next_entry;

bool isNull(void *ptr) {
    if (ptr == NULL) {
        mere_parser_exit();
        return true;
    }
    return false;
}

#define ALLOC_SIZE(base,next,size,need,single) \
    size = need > 0 ? need : 1; \
    base = malloc(need * single); \
    if (isNull(base)) return false; \
    next = base;

#define ENSURE_SIZE(base,next,size,need,single) \
    size_t position = next - base; \
    if ((size - position) <= need) { \
        printf("%lu %lu %lu\n", size, size-position, need); \
        size *= 2; \
        base = realloc(base, size * single); \
        next = base + position; \
    }

#define FREE_BASE(base) \
    if (base != NULL) free(base);



bool mere_parser_init(size_t size) {
    ALLOC_SIZE(mere_cstrings,next_cstring, mere_cstrings_size, size, sizeof(char))
    ALLOC_SIZE(mere_entries, next_entry, mere_entries_size, size, sizeof(mere_entry))

    return true;
}

void mere_parser_exit() {
    FREE_BASE(mere_entries)
    FREE_BASE(mere_cstrings)
}



SID mere_store_string(char const * _Nonnull cstring, size_t len) {
    assert(strlen(cstring) == len);
    
    ENSURE_SIZE(mere_cstrings, next_cstring, mere_cstrings_size, len, sizeof(char));
    
    char * dest = next_cstring;
    next_cstring += len + 1;
    
    strncpy(dest, cstring, len+1); // include terminating zero-byte
    
    assert('\0' == *(dest+len)); // check termnating zero-byte
    
    return position;
}

char * mere_retrieve_string(SID sid) {
    assert( sid < mere_cstrings_size);
    assert( sid == 0 || '\0' == *(mere_cstrings + (sid-1)));
    
    return mere_cstrings + sid;
}

EID mere_entry_create(SID sid) {
    ENSURE_SIZE(mere_entries, next_entry, mere_entries_size, (size_t)1, sizeof(mere_entry))
    
    mere_entry * dest = next_entry;
    next_entry += 1;
    
    dest->sid = sid;
    dest->next = 0; // no next entry.
    
    return position;
}

void mere_entry_append(EID eid, SID sid) {
    EID lasteid = mere_entry_create(sid);
    mere_entry *peid = mere_entries + eid;
    while (peid->next) {
        peid = mere_entries + peid->next;
    }
    peid->next = lasteid;
}

int mere_entry_count(EID eid) {
    int count = 1;
    mere_entry *peid = mere_entries + eid;
    while (peid->next) {
        peid = mere_entries + peid->next;
        count += 1;
    }
    return count;
}

SID mere_entry_string(EID eid, int index) {
    int count = 0;
    mere_entry *peid = mere_entries + eid;
    while (count < index) {
        assert(peid->next > 0);
        peid = mere_entries + peid->next;
        count += 1;
    }
    return peid->sid;
}