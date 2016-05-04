//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef PrlcMacros_h
#define PrlcMacros_h

#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e)                 prlcLabel("annotated")

#define CREATE_CNF(name,role,root,annotations)      NULL // xStoreAnnotatedCnf(mereParsingTable,name,role,root,annotations)
#define CREATE_INCLUDE(fileName,nameList)           NULL // xStoreInclude(mereParsingTable,fileName,nameList)

#define TPTP_INPUT(input)                           input; NULL // xNodeSetChild(mereParsingTable,0,input)
#define TPTP_INPUT_APPEND(sequence,input)           sequence; NULL // xNodeListAppend(mereParsingTable,sequence,input)

#define CREATE_Quantified(b,c,d)                    prlcLabel("CREATE_Quantified") // quantified
#define CREATE_Functional(sid,first)                NULL // xStoreFunctional(mereParsingTable, sid, first) // function, predicate
#define CREATE_Equational(sid,first)                NULL // xStoreEquational(mereParsingTable, sid, first) // equation, inequation
#define CREATE_Connective(sid,first)                NULL // xStoreConnective(mereParsingTable, sid, first) // connective
#define CREATE_Constant(sid)                        NULL // xStoreConstant(mereParsingTable, sid) // constant
#define CREATE_Variable(sid)                        NULL // xStoreVariable(mereParsingTable, sid) // variable

#define CREATE_NODES0()                             (NULL // x_sid)0  // empty list
#define CREATE_NODES1(a)                            a           // unary list
#define CREATE_NODES2(first,next)                   NULL // xNodeListCreate(mereParsingTable, first, next) // binary list

#define PREDICATE(tid)                              NULL // xSetPredicate(mereParsingTable,tid); /* register_predicate(tid) */

#define APPEND(a,b)                                 prlcLabel("APPEND")
#define INSERT(a,b)                                 prlcLabel("INSERT")

#define CREATE_STRING(a)                            NULL // xStoreSymbol(mereParsingTable, a)
#define CREATE_STRINGS1(a)                          NULL // xStoreNameNode(mereParsingTable, a)

#define CREATE_DISTINCT(a)                          NULL // xStoreConstant(mereParsingTable, NULL // xStoreSymbol(mereParsingTable,a))
/*prlcLabel("CREATE_DISTINCT") */

#define MAKE_ROLE(a)                                NULL // xStoreRole(mereParsingTable, a)

#define NODES_APPEND(member,last)                   NULL // xNodeListAppend(mereParsingTable,member,last)
#define STRINGS_APPEND(a,b)                         NULL // xNodeListAppend(mereParsingTable,a,b)
#define SET_PARENTHESES(a)

/* predefined symbols */
#define DIRTY(a)  (( (char*) (prlcParsingStore->symbols.memory) )  + a)

#define _NOT_       DIRTY(1) // NULL // xStoreSymbol(mereParsingTable,"~")
#define _OR_        DIRTY(3) // NULL // xStoreSymbol(mereParsingTable,"|")
#define _AND_       DIRTY(5) // NULL // xStoreSymbol(mereParsingTable,"&")
#define _GENTZEN_   DIRTY(7) // NULL // xStoreSymbol(mereParsingTable,"-->")
#define _COMMA_     DIRTY(11) // NULL // xStoreSymbol(mereParsingTable,",")
#define _IFF_       DIRTY(13) // NULL // xStoreSymbol(mereParsingTable,"<=>")
#define _IMPLY_     DIRTY(17) // NULL // xStoreSymbol(mereParsingTable,"=>")
#define _YLPMI_     DIRTY(20) // NULL // xStoreSymbol(mereParsingTable,"<=")
#define _NIFF_      DIRTY(23) // NULL // xStoreSymbol(mereParsingTable,"<~>")
#define _NOR_       DIRTY(27) // NULL // xStoreSymbol(mereParsingTable,"~|")
#define _NAND_      DIRTY(30) // NULL // xStoreSymbol(mereParsingTable,"~&")
#define _FORALL_    DIRTY(33) // NULL // xStoreSymbol(mereParsingTable,"!")
#define _EXISTS_    DIRTY(35) // NULL // xStoreSymbol(mereParsingTable,"?")
#define _EQUAL_     DIRTY(37) // NULL // xStoreSymbol(mereParsingTable,"=")
#define _NEQ_       DIRTY(39) // NULL // xStoreSymbol(mereParsingTable,"!=")



#endif
