//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef PrlcMacros_h
#define PrlcMacros_h

#define ps prlcParsingStore

#define NULLREF                     0

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e)                 prlcLabel("annotated")

#define CREATE_CNF(name,role,root,annotations)      prlcStoreNodeCnf(ps,name,role,root,annotations) // xStoreAnnotatedCnf(mereParsingTable,name,role,root,annotations)
#define CREATE_INCLUDE(fileName,nameList)           prlcStoreNodeInclude(ps,fileName,nameList) // xStoreInclude(mereParsingTable,fileName,nameList)

#define TPTP_INPUT(input)                           input; // xNodeSetChild(mereParsingTable,0,input)
#define TPTP_INPUT_APPEND(sequence,input)           prlcNodeAppendNode(sequence,input)

#define CREATE_Quantified(b,c,d)                    prlcLabel("CREATE_Quantified") // quantified
#define CREATE_Functional(c,first)              prlcStoreNodeFunctional(ps, c, first)
#define CREATE_Equational(c,first)              prlcStoreNodeEquational(ps, c, first)
#define CREATE_Connective(c,first)              prlcStoreNodeConnective(ps, c, first)
#define CREATE_Constant(c)                      prlcStoreNodeConstant(ps, c)
#define CREATE_Variable(v)                      prlcStoreNodeVariable(ps, v)

#define CREATE_NODES0()                         NULL   // empty list
#define CREATE_NODES1(a)                        a           // unary list
#define CREATE_NODES2(first,next)               prlcNodeAppendNode(first,next)

#define PREDICATE(p)                              prlcSetPredicate(p) // xSetPredicate(mereParsingTable,tid); /* register_predicate(tid) */

#define APPEND(a,b)                                 prlcLabel("APPEND")
#define INSERT(a,b)                                 prlcLabel("INSERT")

#define CREATE_STRING(a)                            prlcStoreSymbol(ps,a) // xStoreSymbol(mereParsingTable, a)
#define CREATE_STRINGS1(a)                          prlcStoreNodeName(ps,a) // xStoreNameNode(mereParsingTable, a)

#define CREATE_DISTINCT(a)                          prlcStoreNodeConstant(ps, prlcStoreSymbol(ps,a))
/*prlcLabel("CREATE_DISTINCT") */

#define MAKE_ROLE(a)                                prlcStoreNodeRole(ps,a) // xStoreRole(mereParsingTable, a)

#define NODES_APPEND(member,last)                   prlcNodeAppendNode(member,last) // xNodeListAppend(mereParsingTable,member,last)
#define STRINGS_APPEND(a,b)                         prlcNodeAppendNode(a,b) // xNodeListAppend(mereParsingTable,a,b)
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
