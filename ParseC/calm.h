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

typedef size_t CalmId;
typedef void* CalmSymbolTableRef;

CalmSymbolTableRef calmMakeSymbolTable(size_t);
void calmDeleteSymbolTable(CalmSymbolTableRef*);
CalmId calmStoreSymbol(CalmSymbolTableRef, const char * const);
CalmId calmNextSymbol(CalmSymbolTableRef, CalmId);
const char* const calmGetSybmol(CalmSymbolTableRef, CalmId);

#endif /* calm_h */
