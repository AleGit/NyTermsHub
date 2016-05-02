//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef MereMacros_h
#define MereMacros_h



#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e)                 calm_label("annotated")

#define CREATE_CNF(name,role,root,annotations)      calmStoreAnnotatedCnf(mereParsingTable,name,role,root,annotations)
#define CREATE_INCLUDE(fileName,nameList)           calmStoreInclude(mereParsingTable,fileName,nameList)

#define TPTP_INPUT(input)                           input; calmNodeSetChild(mereParsingTable,0,input)
#define TPTP_INPUT_APPEND(sequence,input)           sequence; calmNodeListAppend(mereParsingTable,sequence,input)

#define CREATE_Quantified(b,c,d)                    calm_label("CREATE_Quantified") // quantified
#define CREATE_Functional(sid,first)                calmStoreFunctional(mereParsingTable, sid, first) // function, predicate
#define CREATE_Equational(sid,first)                calmStoreEquational(mereParsingTable, sid, first) // equation, inequation
#define CREATE_Connective(sid,first)                calmStoreConnective(mereParsingTable, sid, first) // connective
#define CREATE_Constant(sid)                        calmStoreConstant(mereParsingTable, sid) // constant
#define CREATE_Variable(sid)                        calmStoreVariable(mereParsingTable, sid) // variable

#define CREATE_NODES0()                             (calm_sid)0  // empty list
#define CREATE_NODES1(a)                            a           // unary list
#define CREATE_NODES2(first,next)                   calmNodeListCreate(mereParsingTable, first, next) // binary list

#define PREDICATE(tid)                              calmSetPredicate(mereParsingTable,tid); /* register_predicate(tid) */

#define APPEND(a,b)                                 calm_label("APPEND")
#define INSERT(a,b)                                 calm_label("INSERT")

#define CREATE_STRING(a)                            calmStoreSymbol(mereParsingTable, a)
#define CREATE_STRINGS1(a)                          calmStoreNameNode(mereParsingTable, a)

#define CREATE_DISTINCT(a)                          calmStoreConstant(mereParsingTable, calmStoreSymbol(mereParsingTable,a))
/*calm_label("CREATE_DISTINCT") */

#define MAKE_ROLE(a)                                calmStoreRole(mereParsingTable, a)

#define NODES_APPEND(member,last)                   calmNodeListAppend(mereParsingTable,member,last)
#define STRINGS_APPEND(a,b)                         calmNodeListAppend(mereParsingTable,a,b)
#define SET_PARENTHESES(a)

/* predefined symbols */
#define _NOT_       1 // calmStoreSymbol(mereParsingTable,"~")
#define _OR_        3 // calmStoreSymbol(mereParsingTable,"|")
#define _AND_       5 // calmStoreSymbol(mereParsingTable,"&")
#define _GENTZEN_   7 // calmStoreSymbol(mereParsingTable,"-->")
#define _COMMA_     11 // calmStoreSymbol(mereParsingTable,",")
#define _IFF_       13 // calmStoreSymbol(mereParsingTable,"<=>")
#define _IMPLY_     17 // calmStoreSymbol(mereParsingTable,"=>")
#define _YLPMI_     20 // calmStoreSymbol(mereParsingTable,"<=")
#define _NIFF_      23 // calmStoreSymbol(mereParsingTable,"<~>")
#define _NOR_       27 // calmStoreSymbol(mereParsingTable,"~|")
#define _NAND_      30 // calmStoreSymbol(mereParsingTable,"~&")
#define _FORALL_    33 // calmStoreSymbol(mereParsingTable,"!")
#define _EXISTS_    35 // calmStoreSymbol(mereParsingTable,"?")
#define _EQUAL_     37 // calmStoreSymbol(mereParsingTable,"=")
#define _NEQ_       39 // calmStoreSymbol(mereParsingTable,"!=")



#endif
