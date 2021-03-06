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

typedef calm_id calm_pid;
typedef int calm_cidx;

typedef enum { CALM_FAILED = -1, CALM_OK = 0 } CALM_STATUS;


typedef struct {
    calm_sid sid;
    calm_pid nexts[256];
} calm_prefix_node;

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
    calm_tree_node *memory;
    size_t capacity;
    size_t size;
} calm_tree_store;


typedef struct {
    unsigned long signature;
    calm_char_store* strings;
    calm_prefix_store* prefixes;
    calm_tree_store* terms;
} calm_table;

/* memory */

calm_memory* calm_memory_create(size_t capacity, size_t unitsize);
CALM_STATUS calm_memory_ensure(calm_memory* ref, size_t capacity, size_t unitsize);
void calm_memory_delete(calm_memory** refref);

/* (string) store */

calm_char_store* calm_char_store_create(size_t capacity);
CALM_STATUS calm_char_store_ensure(calm_char_store* store_ref, size_t capacity);
void calm_char_store_delete(calm_char_store** store_ref);
calm_sid calm_char_store_append(calm_char_store* store_ref, const char* const cstring);
const char* const calm_char_store_retrieve(calm_char_store* store_ref, const calm_sid sid);

/* trie */

calm_prefix_store* calm_prefix_store_create(size_t capacity);
CALM_STATUS calm_prefix_store_ensure(calm_prefix_store* trie_ref, size_t capacity);
void calm_prefix_store_delete(calm_prefix_store** trie_ref);

calm_pid calm_prefix_store_append(calm_prefix_store * trie_ref, calm_sid);
calm_prefix_node* calm_prefix_store_retrieve(calm_prefix_store* trie_ref, calm_pid tid);

calm_pid calm_prefix_build_step(calm_prefix_store* trie_ref, calm_pid tid, calm_cidx cidx);
calm_pid calm_prefix_build_path(calm_prefix_store* trie_ref, const char* const cstring);

/* (term) vertices */

calm_tree_store* calm_tree_store_create(size_t);
CALM_STATUS calm_tree_store_ensure(calm_tree_store*, size_t);
void calm_tree_store_delete(calm_tree_store**);

calm_tid calm_tree_store_append(calm_tree_store*,calm_sid,calm_tid,calm_tid,CALM_TREE_NODE_TYPE);
calm_tree_node* calm_tree_store_retrieve(calm_tree_store*, calm_tid);



/* -------------------------------------------------------------------------- */

calm_table* calm_table_create(const size_t);
void calm_table_delete(calm_table**);
calm_sid calm_table_store(const calm_table*, const char * const);
const char * const calm_table_retrieve(const calm_table* const, const calm_sid);
calm_sid calm_table_next(const calm_table* const, const calm_sid);

#pragma mark - auxiliary functions

calm_cidx calm_cidx_get(const char* const cstring, size_t pos) {
    calm_cidx cidx = cstring[pos];
    while (cidx < 0) {
        // printf("%s %zu %d %d\n", cstring,pos,cidx,cidx+256);
        cidx += 256;
    }
    return cidx;
}


calm_table* calm_table_check(void* parsingTableRef) {
    assert(parsingTableRef != NULL);
    calm_table* ref = (calm_table*)parsingTableRef;
    assert(ref->signature == CALM_PARSING_TABLE_SIGNATURE);
    return ref;
}

calm_id calm_label(char *cstring) { printf("%s\n",cstring); return 0; }


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

calm_sid calm_char_store_append(calm_char_store* store_ref, const char* const cstring) {
    assert(store_ref->memory != NULL);
    assert(store_ref->capacity >= 1);
    assert(store_ref->capacity >= store_ref->size);
    assert(store_ref->size >= 1);
    assert(*(store_ref->memory) == '\0');
    
    size_t sid = store_ref->size;
    size_t len = strlen(cstring);
    
    if (len == 0) return (calm_sid)0;   // empty string's sid is always zero.
    
    if (calm_char_store_ensure(store_ref, store_ref->size + len + 1) != CALM_OK) {
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

const char* const calm_char_store_retrieve(calm_char_store* store_ref, const calm_sid sid) {
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

calm_tree_store* calm_tree_store_create(size_t capacity) {
    
    assert(sizeof(calm_memory) == sizeof(calm_tree_store));
    assert(offsetof(calm_memory, memory) == offsetof(calm_tree_store, memory));
    assert(offsetof(calm_memory, capacity) == offsetof(calm_tree_store, capacity));
    assert(offsetof(calm_memory, size) == offsetof(calm_tree_store, size));
    
    calm_tree_store* term_store_ref = (calm_tree_store*)calm_memory_create(capacity, sizeof(calm_tree_node));
    
    if (term_store_ref == NULL) return NULL;
    
    calm_tid vid = calm_tree_store_append(term_store_ref, 0,0,0,CALM_TPTP_FILE);
    
    assert(vid == 0);
    assert((term_store_ref->memory)->sid == 0);
    
    return term_store_ref;
    
}

CALM_STATUS calm_tree_store_ensure(calm_tree_store* term_store_ref, size_t capacity) {
    return calm_memory_ensure((calm_memory*)term_store_ref, capacity, sizeof(calm_tree_node));
}

void calm_tree_store_delete(calm_tree_store** term_store_ref_ref) {
    calm_memory_delete((calm_memory**)term_store_ref_ref);
}

calm_tid calm_tree_store_append(calm_tree_store* term_store_ref, calm_sid sid, calm_tid sibling, calm_tid child, CALM_TREE_NODE_TYPE type) {
    calm_tid vid = term_store_ref->size;
    
    if ( calm_tree_store_ensure(term_store_ref, (term_store_ref->size)+1) != CALM_OK) {
        return (calm_tid)0;
    }
    
    term_store_ref->size += 1;
    
    calm_tree_node *vertex = (term_store_ref->memory + vid);
    
    vertex->sid = sid;          // no name
    vertex->sibling = sibling;      // no sibling
    vertex->lastSibling = 0;
    vertex->child = child;        // no child
    vertex->type = type;   // no type
    
    return vid;
}

calm_tree_node* calm_tree_store_retrieve(calm_tree_store* term_store_ref, calm_tid vid) {
    if (term_store_ref == NULL || vid > term_store_ref->size) return NULL;
    
    return term_store_ref->memory + vid;
}

#pragma mark - symbol table

#define PREDEFINED_SYMBOLS_COUNT 15

void calm_table_store_predefined_symbols(calm_table* table_ref) {
    
    char* symbols[PREDEFINED_SYMBOLS_COUNT];
    size_t index = 0;
    
    symbols[index++] = "~";
    symbols[index++] = "|";
    symbols[index++] = "&";
    
    symbols[index++] = "-->";
    symbols[index++] = ",";
    
    symbols[index++] = "<=>";
    symbols[index++] = "=>";
    symbols[index++] = "<=";
    
    symbols[index++] = "<~>";
    symbols[index++] = "~|";
    symbols[index++] = "~&";
    
    
    symbols[index++] = "!";
    symbols[index++] = "?";
    
    symbols[index++] = "=";
    symbols[index++] = "!=";
    
    size_t sids[PREDEFINED_SYMBOLS_COUNT] = {
        1, 3, 5,
        7, 11,
        13, 17, 20,
        23, 27, 30,
        33, 35,
        37, 39
    };

    /* 14 roles
    symbols[index++] = "unknown";
    symbols[index++] = "type";
    symbols[index++] = "fi_predicates";
    symbols[index++] = "fi_functors";
    symbols[index++] = "fi_domain";
    symbols[index++] = "plain";
    symbols[index++] = "negated_conjecture";
    symbols[index++] = "conjecture";
    symbols[index++] = "theorem";
    symbols[index++] = "lemma";
    symbols[index++] = "assumption";
    symbols[index++] = "definition";
    symbols[index++] = "hypothesis";
    symbols[index++] = "axiom";
     */
    
    assert(PREDEFINED_SYMBOLS_COUNT == index);
    
    
    size_t expected = 1;
    
    for (index = 0; index < PREDEFINED_SYMBOLS_COUNT; index++) {
        char *symbol = symbols[index];
        calm_sid sid = calmStoreSymbol(table_ref, symbol);
        
#ifdef DEBUG_VERBOSE
        printf("%zu %s #%zu\n",sid, symbol, index);
#endif
        assert(sid == expected);
        assert(sids[index] == sid);
        expected += strlen(symbols[index])+1;
    }
    
    
    
}

calm_table* calm_table_create(const size_t capacity) {
    calm_table *table_ref = calloc(1,sizeof(calm_table));
    table_ref->signature = CALM_PARSING_TABLE_SIGNATURE;
    table_ref->strings = calm_char_store_create(capacity); //
    table_ref->prefixes = calm_prefix_store_create(capacity);
    table_ref->terms = calm_tree_store_create(capacity/4); // 4 chars per node
    
    calm_table_store_predefined_symbols(table_ref);
    
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
        
        calm_tree_store_delete(&(ref->terms));
        assert(ref->terms == NULL);
        
        free(ref);
        *refref = NULL;
    }
    
    assert(*refref == NULL);
}

calm_sid calm_table_store(const calm_table* const table_ref, const char * const cstring) {
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

calm_sid calm_table_next(const calm_table* const table_ref, const calm_sid sid) {
    const char* const cstring = calm_table_retrieve(table_ref,sid);
    
    if (cstring == NULL) return (calm_sid)0;
    
    size_t len = strlen(cstring);
    
    calm_sid next_sid = sid + len + 1;
    
    if (next_sid >= table_ref->strings->size) return (calm_sid)0;
    
    return next_sid;
}

const char * const calm_table_retrieve(const calm_table* const table_ref, const calm_sid sid) {
    assert(table_ref != NULL);
    assert(table_ref->strings != NULL);
    
    return calm_char_store_retrieve(table_ref->strings, sid);
}


/* ************************************************************************** */


#pragma mark - 'public' functions definitions

CalmParsingTableRef calmMakeParsingTable(size_t capacity) {
    return calm_table_create(capacity);
}

void calmDeleteParsingTable(CalmParsingTableRef* parsingTableRefRef) {
    calm_table_delete((calm_table**)parsingTableRefRef);
}

calm_sid calmStoreSymbol(CalmParsingTableRef parsingTableRef, const char * const cstring) {
    return calm_table_store(calm_table_check(parsingTableRef), cstring);
}

calm_sid calmNextSymbol(CalmParsingTableRef parsingTableRef, calm_sid sid) {
    return calm_table_next(calm_table_check(parsingTableRef), sid);
}

const char* const calmGetSymbol(CalmParsingTableRef parsingTableRef, calm_sid sid) {
    return calm_table_retrieve(calm_table_check(parsingTableRef), sid);
}

size_t calmGetTreeNodeStoreSize(CalmParsingTableRef parsingTableRef) {
    calm_tree_store* tree_store = calm_table_check(parsingTableRef)->terms;
    assert(tree_store->size <= tree_store->capacity);
    return tree_store->size;
}

size_t calmGetSymbolStoreSize(CalmParsingTableRef parsingTableRef) {
    calm_char_store * symbol_store = calm_table_check(parsingTableRef)->strings;
    assert(symbol_store->size <= symbol_store->capacity);
    return symbol_store->size;
    
}

const calm_tree_node* calmGetTreeNode(CalmParsingTableRef parsingTableRef, calm_tid tid) {
    assert(tid < calmGetTreeNodeStoreSize(parsingTableRef));
    
    return calm_table_check(parsingTableRef)->terms->memory + tid;
}

calm_tree_node calmCopyTreeNodeData(CalmParsingTableRef parsingTableRef, calm_tid tid) {
    const calm_tree_node* node = calmGetTreeNode(parsingTableRef, tid);
    return *node;
}

//const char* const calmGetTreeNodeSymbol(CalmParsingTableRef parsingTableRef, calm_tid tid) {
//    const calm_tree_node* node = calmGetTreeNode(parsingTableRef, tid);
//    
//    return calmGetSymbol(parsingTableRef, node->sid);
//}
//
//calm_tid calmGetTreeNodeSibling(CalmParsingTableRef parsingTableRef, calm_tid tid) {
//    const calm_tree_node* node = calmGetTreeNode(parsingTableRef, tid);
//    return node->sibling;
//    
//}
//calm_tid calmGetTreeNodeChild(CalmParsingTableRef parsingTableRef, calm_tid tid) {
//    const calm_tree_node* node = calmGetTreeNode(parsingTableRef, tid);
//    return node->child;
//    
//}
//CALM_TREE_NODE_TYPE calmGetTreeNodeType(CalmParsingTableRef parsingTableRef, calm_tid tid) {
//    const calm_tree_node* node = calmGetTreeNode(parsingTableRef, tid);
//    return node->type;
//    
//}



/* */

calm_tid calmStoreAnnotated(CalmParsingTableRef parsingTableRef, calm_sid nameSID, calm_sid role, calm_tid root, calm_tid annotations,CALM_TREE_NODE_TYPE type) {
    
    assert(nameSID != 0);
    
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, nameSID, 0,
                                  calmNodeListCreate(parsingTableRef, role, calmNodeListCreate(parsingTableRef,root,annotations))
                                  , type);
}

calm_tid calmStoreInclude(CalmParsingTableRef parsingTableRef, calm_sid sid, calm_tid tid) {
    assert(sid != 0);
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, tid, CALM_TPTP_INCLUDE);
    
}


calm_tid calmStoreAnnotatedCnf(CalmParsingTableRef parsingTableRef, calm_sid nameSID, calm_tid role, calm_tid root, calm_tid annotations) {
    return calmStoreAnnotated(parsingTableRef, nameSID, role, root, annotations, CALM_TPTP_CNF_ANNOTATED);
}


calm_tid calmStoreRole(CalmParsingTableRef parsingTableRef, const char* const role) {
    calm_sid sid = calm_table_store(parsingTableRef, role);
    assert(sid != 0);
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, 0, CALM_TPTP_ROLE);
}

calm_tid calmStoreConnective(CalmParsingTableRef parsingTableRef, calm_sid sid, calm_tid firstchild) {
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, firstchild, CALM_CONNECTIVE);
}



calm_tid calmStoreEquational(CalmParsingTableRef parsingTableRef,calm_sid sid, calm_tid firstchild) {
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, firstchild, CALM_EQUATIONAL);
}

calm_tid calmSetPredicate(CalmParsingTableRef parsingTableRef, calm_tid tid) {
    calm_tree_node* node = calm_tree_store_retrieve(calm_table_check(parsingTableRef)->terms, tid);
    assert(node != NULL);
    assert(node->sid != 0);
    assert(node->type == CALM_FUNCTIONAL || node->type == CALM_PREDICATE);

    node->type = CALM_PREDICATE;
    return tid;
}

calm_tid calmStoreFunctional(CalmParsingTableRef parsingTableRef,calm_sid sid, calm_tid firstchild) {
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, firstchild, CALM_FUNCTIONAL);
}

calm_tid calmStoreConstant(CalmParsingTableRef parsingTableRef, calm_sid sid) {
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, 0, CALM_FUNCTIONAL);
}

calm_tid calmStoreVariable(CalmParsingTableRef parsingTableRef, calm_sid sid) {
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, 0, CALM_VARIABLE);
    
}

/****/

calm_tid calmNodeListCreate(CalmParsingTableRef parsingTableRef,calm_tid first,calm_tid second) {
    assert(first != second || second == 0);
    
    calm_tree_node *node = calm_tree_store_retrieve(calm_table_check(parsingTableRef)->terms, first);
    
    assert(node != NULL);
    assert(node->sibling == 0);
    
    node->sibling = second;
    node->lastSibling = second;
    
    return first;
    
}

void calmNodeListAppend(CalmParsingTableRef parsingTableRef, calm_tid first, calm_tid last) {
    assert(first == 0 || first != last);
    
    calm_tree_node *firstNode = calm_tree_store_retrieve(calm_table_check(parsingTableRef)->terms, first);

    assert(firstNode != NULL);

    
    if (firstNode->lastSibling != 0) {
        calmNodeListAppend(parsingTableRef, firstNode->lastSibling, last);
        firstNode->lastSibling = last;
    }
    else if (firstNode->sibling == 0) {
        firstNode->sibling = last;
        firstNode->lastSibling = last;
    }
    else {
        printf("calmNodeListAppend(ref, %zu %zu) %zu %zu\n",first,last,firstNode->sibling, firstNode->lastSibling);
        assert(false);

        calmNodeListAppend(parsingTableRef, firstNode->sibling, last);
    }
    
    
}


void calmNodeSetChild(CalmParsingTableRef parsingTableRef, calm_tid parent, calm_tid child) {
    assert(parent == 0 || parent != child);
    
    calm_tree_node *node = calm_tree_store_retrieve(calm_table_check(parsingTableRef)->terms, parent);
    
    assert(node != NULL);
    assert(node->type != CALM_TYPE_UNKNOWN);
    assert(node->child == 0);
    
    node->child = child;
}

void calmNodeSetSymbol(CalmParsingTableRef parsingTableRef, calm_tid tid, const char* const name) {
    assert(strlen(name)>0);
    
    calm_tree_node *node = calm_tree_store_retrieve(calm_table_check(parsingTableRef)->terms, tid);
    assert(node != NULL);
    assert(node->type != CALM_TYPE_UNKNOWN);
    assert(node->sid == 0);
    
    calm_sid sid = calmStoreSymbol(parsingTableRef, name);
    assert(sid != 0);
    
    node->sid = sid;
}

calm_tid calmStoreNameNode(CalmParsingTableRef parsingTableRef, calm_sid sid) {
    printf("calmStoreNameNode: %zu\n",sid);
    assert(sid != 0);
    return calm_tree_store_append(calm_table_check(parsingTableRef)->terms, sid, 0, 0, CALM_NAME);
}

