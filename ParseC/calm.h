//
//  cdata.h
//  NyTerms
//
//  Created by Alexander Maringele on 28.04.16.
//  Copyright © 2016 Alexander Maringele. All rights reserved.
//

#ifndef calm_h
#define calm_h

#import <CoreFoundation/CoreFoundation.h>

typedef size_t calm_id;

void calm_store_demo();
void calm_trie_demo();

void calm_table_init();
void calm_table_exit();
calm_id calm_table_store(const char * const cstring);
const char * const calm_table_retrieve(const calm_id sid);

#endif /* calm_h */
