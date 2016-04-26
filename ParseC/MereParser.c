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

size_t mere_string_lists_size;
string_list_entry * mere_string_lists;
string_list_entry * next_string_list_entry;

bool isNull(void *ptr) {
    if (ptr == NULL) {
        mere_parser_exit();
        return true;
    }
    return false;
}

bool mere_parser_init(size_t size) {
    mere_cstrings_size = size;
    mere_cstrings = malloc(mere_cstrings_size * sizeof(char));
    if (isNull(mere_cstrings)) return false;
    next_cstring = mere_cstrings;
    
    mere_string_lists_size = size/2;
    mere_string_lists = malloc(mere_cstrings_size * sizeof(string_list_entry));
    if (isNull(mere_cstrings)) return false;
    next_string_list_entry = mere_string_lists;
    
    return true;
}

void mere_parser_exit() {
    
    if (mere_string_lists != NULL) free(mere_string_lists);
    if (mere_cstrings != NULL) free(mere_cstrings);
}

SID mere_store_string(char * _Nonnull cstring, size_t len) {
    assert(strlen(cstring) == len);
    
    size_t position = next_cstring - mere_cstrings;
    
    if ( (mere_cstrings_size - position) < len) {
        mere_cstrings_size *= 2;
        mere_cstrings = realloc(mere_cstrings, mere_cstrings_size * sizeof(char));
        next_cstring = mere_cstrings + position;
    }
    
    char * dest = next_cstring;
    next_cstring += len + 1;
    
    strncpy(dest, cstring, len+1); // include terminating zero-byte
    
    assert('\0' == *(dest+len)); // check termnating zero-byte
    
    return position;
}

char * mere_retrieve_string(SID sid) {
    assert( sid == 0 || '\0' == *(mere_cstrings + (sid-1)));
    
    return mere_cstrings + sid;
}