//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef MereMacros_h
#define MereMacros_h

#define NULLREF                     NULL

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e) NULL
#define CREATE_INCLUDE(a,b)         NULL


#define CREATE_Quantified(b,c,d)    NULL    // quantified
#define CREATE_Functional(b,c)      NULL      // function, predicate
#define CREATE_Equational(b,c)      NULL      // equation, inequation
#define CREATE_Connective(b,c)      NULL      // connective
#define CREATE_Constant(b)          NULL          // constant
#define CREATE_Variable(b)          NULL          // variable

#define CREATE_NODES0()             NULL         // empty list
#define CREATE_NODES1(a)            NULL        // unary list
#define CREATE_NODES2(a,b)          NULL      // binary list

#define PREDICATE(a)       a; /* register_predicate(a) */

#define APPEND(a,b)                 NULL
#define INSERT(a,b)                 NULL

#define CREATE_STRING(a)            NULL
#define CREATE_STRINGS1(a)          NULL

#define CREATE_DISTINCT(a)          NULL

#define MAKE_ROLE(a)                1

#define NODES_APPEND(a,b)           NULL
#define STRINGS_APPEND(a,b)         NULL
#define SET_PARENTHESES(a)

#define _NOT_       "~"
#define _OR_        "|"
#define _AND_       "&"
#define _GENTZEN_   "-->"
#define _COMMA_     ","
#define _IFF_       "<=>"
#define _IMPLY_     "=>"
#define _YLPMI_     "<="
#define _NIFF_      "<~>"
#define _NOR_       "~|"
#define _NAND_      "~&"
#define _FORALL_    "!"
#define _EXISTS_    "?"
#define _EQUAL_     "="
#define _NEQ_       "!="



#endif
