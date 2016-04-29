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
typedef CalmId CalmTID;     /* term (node) identifier */
typedef void* CalmParsingTableRef;

#pragma mark - symbol table

CalmParsingTableRef calmMakeParsingTable(size_t);
void calmDeleteParsingTable(CalmParsingTableRef*);

CalmSID calmStoreSymbol(CalmParsingTableRef, const char * const);
CalmSID calmNextSymbol(CalmParsingTableRef, CalmSID);
const char* const calmGetSymbol(CalmParsingTableRef, CalmSID);

CalmTID calmStoreConnective(CalmParsingTableRef,CalmSID,CalmTID);
CalmTID calmStoreVariable(CalmParsingTableRef,CalmSID);
CalmTID calmStoreConstant(CalmParsingTableRef,CalmSID);
CalmTID calmLinkTerms(CalmParsingTableRef,CalmTID,CalmTID);

#endif /* calm_h */
