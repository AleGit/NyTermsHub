//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef MereMacros_h
#define MereMacros_h



#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e)     calm_label("annotated")

#define CREATE_CNF(name,role,root,annotations)    calmStoreAnnotatedCnf(parsingTable,name,role,root,annotations)
#define CREATE_INCLUDE(a,b)         calm_label("include")


#define CREATE_Quantified(b,c,d)        calm_label("CREATE_Quantified") // quantified
#define CREATE_Functional(sid,first)    calmStoreFunctional(parsingTable, sid, first) // function, predicate
#define CREATE_Equational(sid,first)    calmStoreEquational(parsingTable, sid, first) // equation, inequation
#define CREATE_Connective(sid,first)    calmStoreConnective(parsingTable, sid, first) // connective
#define CREATE_Constant(sid)            calmStoreConstant(parsingTable, sid) // constant
#define CREATE_Variable(sid)            calmStoreVariable(parsingTable, sid) // variable

#define CREATE_NODES0()             (CalmSID)0  // empty list
#define CREATE_NODES1(a)            a           // unary list
#define CREATE_NODES2(first,next)   calmLinkTerms(parsingTable, first, next) // binary list

#define PREDICATE(a)                a;  /* register_predicate(a) */

#define APPEND(a,b)                 calm_label("APPEND")
#define INSERT(a,b)                 calm_label("INSERT")

#define CREATE_STRING(a)            calmStoreSymbol(parsingTable, a)
#define CREATE_STRINGS1(a)          calm_label("CREATE_STRINGS1")

#define CREATE_DISTINCT(a)          calm_label("CREATE_DISTINCT")

#define MAKE_ROLE(a)                calmStoreRole(parsingTable, a)

#define NODES_APPEND(first,last)    calmTermsAppend(parsingTable,first,last)
#define STRINGS_APPEND(a,b)         calm_label("STRINGS_APPEND")
#define SET_PARENTHESES(a)

#define _NOT_       calmStoreSymbol(parsingTable,"~")
#define _OR_        calmStoreSymbol(parsingTable,"|")
#define _AND_       calmStoreSymbol(parsingTable,"&")
#define _GENTZEN_   calmStoreSymbol(parsingTable,"-->")
#define _COMMA_     calmStoreSymbol(parsingTable,",")
#define _IFF_       calmStoreSymbol(parsingTable,"<=>")
#define _IMPLY_     calmStoreSymbol(parsingTable,"=>")
#define _YLPMI_     calmStoreSymbol(parsingTable,"<=")
#define _NIFF_      calmStoreSymbol(parsingTable,"<~>")
#define _NOR_       calmStoreSymbol(parsingTable,"~|")
#define _NAND_      calmStoreSymbol(parsingTable,"~&")
#define _FORALL_    calmStoreSymbol(parsingTable,"!")
#define _EXISTS_    calmStoreSymbol(parsingTable,"?")
#define _EQUAL_     calmStoreSymbol(parsingTable,"=")
#define _NEQ_       calmStoreSymbol(parsingTable,"!=")



#endif
