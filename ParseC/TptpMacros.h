//  Created by Alexander Maringele .
//  Copyright © 2015 Alexander Maringele. All rights reserved.

#ifndef Nyaya_TptpMacros_h
#define Nyaya_TptpMacros_h

#define NULLREF                     nil

#define DID_PARSE_FORMULA(a)        return 0
#define DID_PARSE_INCLUDE(a)        return 0

#define CREATE_ANNOTATED(a,b,c,d,e) create_formula(a,b,c,d,e)
#define CREATE_INCLUDE(a,b)         create_include(a,b)


#define CREATE_Quantified(b,c,d)    create_quantified(b,c,d)    // quantified
#define CREATE_Functional(b,c)      create_functional(b,c)      // function, predicate
#define CREATE_Equational(b,c)      create_equational(b,c)      // equation, inequation
#define CREATE_Connective(b,c)      create_connective(b,c)      // connective
#define CREATE_Constant(b)          create_constant(b)          // constant
#define CREATE_Variable(b)          create_variable(b)          // variable

#define CREATE_NODES0()             create_nodes0()         // empty list
#define CREATE_NODES1(a)            create_nodes1(a)        // unary list
#define CREATE_NODES2(a,b)          create_nodes2(a,b)      // binary list

#define PREDICATE(a)       a; /* register_predicate(a) */

#define APPEND(a,b)             append(a,b)
#define INSERT(a,b)             insert(a,b)

#define CREATE_STRING(a)            create_string(a)
#define CREATE_STRINGS1(a)          create_strings1(a)

#define CREATE_DISTINCT(a)          create_distinct_object(a)

#define MAKE_ROLE(a)                make_role(a);

#define NODES_APPEND(a,b)           nodes_append(a,b)
#define STRINGS_APPEND(a,b)         strings_append(a,b)
#define SET_PARENTHESES(a)

#define _NOT_       @"~"
#define _OR_        @"|"
#define _AND_       @"&"
#define _GENTZEN_   @"-->"
#define _COMMA_     @","
#define _IFF_       @"<=>"
#define _IMPLY_     @"=>"
#define _YLPMI_     @"<="
#define _NIFF_      @"<~>"
#define _NOR_       @"~|"
#define _NAND_      @"~&"
#define _FORALL_    @"!"
#define _EXISTS_    @"?"
#define _EQUAL_     @"="
#define _NEQ_       @"!="



#endif
