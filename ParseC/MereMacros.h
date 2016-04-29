//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef MereMacros_h
#define MereMacros_h

#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e) NULLREF
#define CREATE_INCLUDE(a,b)         NULLREF


#define CREATE_Quantified(b,c,d)    NULLREF // quantified
#define CREATE_Functional(b,c)      NULLREF // function, predicate
#define CREATE_Equational(b,c)      NULLREF // equation, inequation
#define CREATE_Connective(sid,child)    calmStoreConnective(symbolTable, sid, child) // connective
#define CREATE_Constant(sid)    calmStoreConstant(symbolTable, sid) // constant
#define CREATE_Variable(sid)    calmStoreVariable(symbolTable, sid) // variable

#define CREATE_NODES0()             (CalmSID)0  // empty list
#define CREATE_NODES1(a)            a           // unary list
#define CREATE_NODES2(a,b)          calmLinkTerms(symbolTable, a, b) // binary list

#define PREDICATE(a)                a;  /* register_predicate(a) */

#define APPEND(a,b)                 NULLREF
#define INSERT(a,b)                 NULLREF

#define CREATE_STRING(a)            calmStoreSymbol(symbolTable, a)
#define CREATE_STRINGS1(a)          NULLREF

#define CREATE_DISTINCT(a)          NULLREF

#define MAKE_ROLE(a)                1

#define NODES_APPEND(a,b)           NULLREF
#define STRINGS_APPEND(a,b)         NULLREF
#define SET_PARENTHESES(a)

#define _NOT_       calmStoreSymbol(symbolTable,"~")
#define _OR_        calmStoreSymbol(symbolTable,"|")
#define _AND_       calmStoreSymbol(symbolTable,"&")
#define _GENTZEN_   calmStoreSymbol(symbolTable,"-->")
#define _COMMA_     calmStoreSymbol(symbolTable,",")
#define _IFF_       calmStoreSymbol(symbolTable,"<=>")
#define _IMPLY_     calmStoreSymbol(symbolTable,"=>")
#define _YLPMI_     calmStoreSymbol(symbolTable,"<=")
#define _NIFF_      calmStoreSymbol(symbolTable,"<~>")
#define _NOR_       calmStoreSymbol(symbolTable,"~|")
#define _NAND_      calmStoreSymbol(symbolTable,"~&")
#define _FORALL_    calmStoreSymbol(symbolTable,"!")
#define _EXISTS_    calmStoreSymbol(symbolTable,"?")
#define _EQUAL_     calmStoreSymbol(symbolTable,"=")
#define _NEQ_       calmStoreSymbol(symbolTable,"!=")



#endif
