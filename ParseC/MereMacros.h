//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef MereMacros_h
#define MereMacros_h



#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e) 0 /* calm_label("annotated") */
#define CREATE_INCLUDE(a,b)         calm_label("include")


#define CREATE_Quantified(b,c,d)    calm_label("CREATE_Quantified") // quantified
#define CREATE_Functional(sid,first)      calmStoreFunctional(symbolTable, sid, first) // function, predicate
#define CREATE_Equational(sid,first)      calmStoreEquational(symbolTable, sid, first) // equation, inequation
#define CREATE_Connective(sid,first)    calmStoreConnective(symbolTable, sid, first) // connective
#define CREATE_Constant(sid)            calmStoreConstant(symbolTable, sid) // constant
#define CREATE_Variable(sid)            calmStoreVariable(symbolTable, sid) // variable

#define CREATE_NODES0()             (CalmSID)0  // empty list
#define CREATE_NODES1(a)            a           // unary list
#define CREATE_NODES2(first,next)   calmLinkTerms(symbolTable, first, next) // binary list

#define PREDICATE(a)                a;  /* register_predicate(a) */

#define APPEND(a,b)                 calm_label("APPEND")
#define INSERT(a,b)                 calm_label("INSERT")

#define CREATE_STRING(a)            calmStoreSymbol(symbolTable, a)
#define CREATE_STRINGS1(a)          calm_label("CREATE_STRINGS1")

#define CREATE_DISTINCT(a)          calm_label("CREATE_DISTINCT")

#define MAKE_ROLE(a)                1

#define NODES_APPEND(first,last)    calmTermsAppend(symbolTable,first,last)
#define STRINGS_APPEND(a,b)         calm_label("STRINGS_APPEND")
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
