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
typedef CalmId CalmSID;     /* symbol identifier (filename, name, role) */
typedef CalmId CalmTID;     /* tree node identifier */
typedef void* CalmParsingTableRef;

#pragma mark - symbol table

CalmParsingTableRef calmMakeParsingTable(size_t);
void calmDeleteParsingTable(CalmParsingTableRef*);

CalmSID calmStoreSymbol(CalmParsingTableRef, const char * const);
CalmSID calmNextSymbol(CalmParsingTableRef, CalmSID);
const char* const calmGetSymbol(CalmParsingTableRef, CalmSID);


CalmTID calmStoreAnnotatedCnf(CalmParsingTableRef,CalmSID,CalmSID,CalmTID,CalmTID);
CalmTID calmStoreConnective(CalmParsingTableRef,CalmSID,CalmTID);
CalmTID calmStoreRole(CalmParsingTableRef,const char* const);

CalmTID calmStoreFunctional(CalmParsingTableRef,CalmSID,CalmTID);
CalmTID calmStoreEquational(CalmParsingTableRef,CalmSID,CalmTID);
CalmTID calmStoreConstant(CalmParsingTableRef,CalmSID);
CalmTID calmStoreVariable(CalmParsingTableRef,CalmSID);


CalmTID calmLinkTerms(CalmParsingTableRef, CalmTID, CalmTID);
void calmTermsAppend(CalmParsingTableRef, CalmTID, CalmTID);

CalmId calm_label(char*);

#endif /* calm_h */
