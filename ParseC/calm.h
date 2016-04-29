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
typedef CalmId CalmSID;     /* Symbol Identifier */
typedef void* CalmParsingTableRef;

#pragma mark - symbol table

CalmParsingTableRef calmMakeParsingTable(size_t);
void calmDeleteParsingTable(CalmParsingTableRef*);

CalmSID calmStoreSymbol(CalmParsingTableRef, const char * const);
CalmSID calmNextSymbol(CalmParsingTableRef, CalmSID);
const char* const calmGetSymbol(CalmParsingTableRef, CalmSID);



#endif /* calm_h */
