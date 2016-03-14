/*  Created by Alexander Maringele.
    Copyright (c) 2015 Alexander Maringele. All rights reserved.
 
    Parser for input files in TPTP/CNF or TPTP/FOF format.
 
    http://www.cs.miami.edu/~tptp/TPTP/SyntaxBNF.html
 
*/

%{
    /* *** C DECLARATIONS *************************************************************************** */
    
    #import "MereParser.h"
    
%}
/*** YACC/BISON DECLARATIONS ***/

%union
{
    char* cstring;
    char* obj;
    char* node;
    char* string;
}


%token<cstring> NOT_A_TOKEN

%token<cstring> COMMENT

%token  DOLLAR_FOF
%token  DOLLAR_FOT
%token  DOLLAR_CNF
%token  FOF
%token  FOT
%token  CNF
%token  INCLUDE
%token  DESCRIPTION
%token  IQUOTE
%token  INFIX_INEQUALITY
%token  INFIX_EQUALITY
%token  IFF IMPLY YLPMI NIFF NOR NAND
%token  GENTZEN_ARROW

%token <cstring> SINGLE_QUOTED
%token <cstring> DISTINCT_OBJECT
%token <cstring> DOLLAR_WORD
%token <cstring> DOLLAR_DOLLAR_WORD
%token <cstring> LOWER_WORD
%token <cstring> UPPER_WORD

%token <cstring> INTEGER
%token <cstring> RATIONAL
%token <cstring> REAL

%type <obj>  TPTP_file
%type <obj>  TPTP_sequence
%type <obj>  TPTP_input

%type <tptpformula>  annotated_formula
%type <tptpformula>  fof_annotated
%type <tptpformula>  cnf_annotated
%type <annotations>  annotations
%type <role> formula_role
/* thf ...*/
/* tff ...*/
/* %----FOF formulae.*/
%type <node> fof_formula fof_logic_formula fof_binary_formula fof_binary_nonassoc
%type <node> fof_binary_assoc fof_or_formula fof_and_formula
%type <node> fof_unitary_formula fof_quantified_formula
%type <strings> fof_variable_list
%type <node> fof_unary_formula
/* */
%type <node> fof_sequent fof_tuple
%type <nodes> fof_tuple_list
/* %----CNF formulae (variables implicitly universally quantified) */
%type <node> cnf_formula
%type <nodes> disjunction
%type <node> literal
/* %----Special formulae */
%type <node> fol_infix_unary
/* %----Connectives - FOF */
%type <type> fol_quantifier binary_connective /* assoc_connective */ unary_connective
/* %type <nodetype> gentzen_arrow, see GENTZEN_ARROW */
/* defined_type */
/* %----First order atoms */
%type <node> atomic_formula plain_atomic_formula
%type <node> defined_atomic_formula defined_plain_formula
%type <node> defined_infix_formula
%type <type> defined_infix_pred

%type <node> system_atomic_formula

%type <node> term function_term plain_term
%type <string> constant functor

%type <node> defined_term defined_atom defined_atomic_term defined_plain_term
%type <string> defined_constant defined_functor

%type <node> system_term
%type <string> system_constant system_functor

%type <string> variable
%type <nodes> arguments


/* 
 %----Formula sources */
%type <node> source /* sources /* */
/* 
 %----Useful info fields */
%type <nodes> optional_info useful_info
/* 
 %----Non-logical data */
%type <node> general_term general_data general_function
/* 
 %----A <general_data> bind() term is used to record a variable binding in an
 %----inference, as an element of the <parent_details> list. */
 %type <node> formula_data
 %type <nodes> general_list general_terms


%type <tptpinclude> include
%type <strings> formula_selection name_list


%type <string> name
%type <string> atomic_word atomic_defined_word atomic_system_word
%type <string> number
%type <string> file_name

%start TPTP_file

%left 	'+'
%left 	'*'

%%
/*** YACC/BISON GRAMMER RULES ***/

/*
 %----Files. Empty file is OK.
 <TPTP_file>          ::= <TPTP_input>*
 <TPTP_input>         ::= <annotated_formula> | <include>
 */

TPTP_file       :   /* epsilon */ 
                |   TPTP_sequence // 

TPTP_sequence   :   TPTP_input // 
                |   TPTP_sequence TPTP_input // 

TPTP_input      :   annotated_formula 
|   include 


/*
 %----Formula records
 */
annotated_formula   :   fof_annotated
                    |   cnf_annotated

/*
 %----Future languages may include ... english | efof | tfof | mathml | ...
 */

/*
tpi_annotated       :   TPI '(' name ',' formula_role ',' tpi_formula annotations ')' '.'
tpi_formula         :   fof_formula
thf_annotated       :   THF '(' name ',' formula_role ',' thf_formula annotations ')' '.'
tff_annotated       :   TFF '(' name ',' formula_role ',' tff_formula annotations ')' '.'
*/
fof_annotated       :   FOF '(' name ',' formula_role ',' fof_formula annotations ')' '.' 

cnf_annotated       :   CNF '(' name ',' formula_role ',' cnf_formula annotations ')' '.' 

annotations         :   /* epsilon */   
                    |   ',' source optional_info 

/*
 %----Types for problems.
 */
formula_role        :   LOWER_WORD 
/* 
 some files use these keywords as names, so they can not be tokens
 -----------------------------------------------------------------
 formula_role   :==   axiom|hypothesis|definition|assumption|lemma|theorem|conjecture|negated_conjecture|plain|fi_domain|fi_functors|fi_predicates|type|unknown
 */

/*
 %----THF formulae.
 */

/*
 %----TFF formulae.
 */

/*
 %----FOF formulae.
 */
fof_formula             :   fof_logic_formula 
                        |   fof_sequent 

fof_logic_formula       :   fof_binary_formula 
                        |   fof_unitary_formula 

fof_binary_formula      :   fof_binary_nonassoc 
                        |   fof_binary_assoc 

fof_binary_nonassoc     :   fof_unitary_formula binary_connective fof_unitary_formula 

fof_binary_assoc        :   fof_or_formula 
                        |   fof_and_formula 

fof_or_formula          :   fof_unitary_formula '|' fof_unitary_formula 
                        |   fof_or_formula '|' fof_unitary_formula 

fof_and_formula         :   fof_unitary_formula '&' fof_unitary_formula  
                        |   fof_and_formula '&' fof_unitary_formula  

fof_unitary_formula     :   fof_quantified_formula 
                        |   fof_unary_formula 
                        |   atomic_formula 
                        |   '(' fof_logic_formula ')'  

fof_quantified_formula  :   fol_quantifier '[' fof_variable_list ']' ':' fof_unitary_formula  

fof_variable_list       :   variable 
                        |   fof_variable_list ',' variable 

fof_unary_formula       :   unary_connective fof_unitary_formula  
                        |   fol_infix_unary 

/*
 %----This section is the FOFX syntax. Not yet in use.
 */
/*
 fof_let                    :   '[' fof_let_list '] ':' fof_unitary_formula
 fof_let_list               :   fof_definded_var
                            |   fof_defined_var ',' fof_let_list
 fof_defined_var            :   variable ':=' fof_logic_formula
                            |   variable ':-' term
                            |   '(' fof_defined_var ')'
 fof_conditional            :   $ite_f '(' fof_logic_formula ',' fof_logic_formula ',' fof_logic_formula ')'
 fof_conditional_term       :   $ite_t '(' fof_logic_formula ',' term ',' term ')' */

fof_sequent                 :   fof_tuple GENTZEN_ARROW fof_tuple 
                            |   '(' fof_sequent ')' 
fof_tuple                   :   '[' ']' 
                            |   '[' fof_tuple_list ']' 
fof_tuple_list              :   fof_logic_formula 
                            |   fof_tuple_list ',' fof_logic_formula 


/*
 %----CNF formulae (variables implicitly universally quantified
 */
cnf_formula         :   '(' disjunction ')'   
                    |   disjunction 
disjunction         :   literal 
                    |   disjunction '|' literal   
literal             :   atomic_formula 
                    |   '~' atomic_formula 
                    |   fol_infix_unary 

/* 
 literal ->  atomic_formula     ->  term = term
         ->  ~ atomic_formula   ->  ~ term = term
         ->  fol_infix_unary    ->  term != term
 
 NOT AN ATOMIC FORMULA :::::::::::  ~ term = term
 NOT A LITERAL :::::::::::::::::::  ~ ~ term = term
 NOT AN ATOMIC FORMULA :::::::::::  term != term
 NOT A LITERAL :::::::::::::::::::  ~ term != term
 */

/*
 %----Special formulae
 */
/* thf_conn_term    :   thf_pair_connective | assoc_connective | thf_unary_connective */
fol_infix_unary     :   term INFIX_INEQUALITY term      
/*                    |   term '=' term           */
/* Is the rule "term '=' term" missing?

/*%----Connectives - THF */
/*%----Connectives - THF and TFF */
/*
 %----Connectives - FOF
 */
fol_quantifier      :   '!'  
|   '?'  

binary_connective   :   IFF       
|   IMPLY               
|   YLPMI               
|   NIFF                
|   NOR                 
|   NAND                
/* assoc_connective    :   '|' | '&' */
unary_connective    :   '~'  


/*%----Types for TFH and TFF */
/*
 defined_type   :   atomic_defined_word
 defined_type   :== $...
 system_type    :== atomic_system_word
 */

/*
 %---- First order atoms 
 */
atomic_formula          :   plain_atomic_formula 
                        |   defined_atomic_formula 
                        |   system_atomic_formula 

plain_atomic_formula    :   plain_term               /* plain_atomic_formula is never equational */
defined_atomic_formula  :   defined_plain_formula 
                        |   defined_infix_formula 
defined_plain_formula   :   defined_plain_term       /* defined_plain_formula is never equational */
defined_infix_formula   :   term defined_infix_pred term 
defined_infix_pred      :   '='  

system_atomic_formula   :   system_term  

/*---- First order terms */
term                :   function_term 
                    |   variable   
                    /* |   conditional_term
                    |   let_term */
function_term       :   plain_term 
                    |   defined_term 
                    /*| system_term */
plain_term          :   constant   
                    |   functor '(' arguments ')' 
constant            :   functor 
functor             :   atomic_word 

defined_term        :   defined_atom  
                    |   defined_atomic_term  
defined_atom        :   number  
                    |   DISTINCT_OBJECT  
defined_atomic_term :   defined_plain_term  

defined_plain_term  :   defined_constant  
                    |   defined_functor '(' arguments ')' 
defined_constant    :   defined_functor    
defined_functor     :   atomic_defined_word 

/*
 %----System term have system specific interpretations
 */
system_term         :   system_constant 
                    |   system_functor '(' arguments ')' 
system_constant     :   system_functor 
system_functor      :   atomic_system_word 

/*
 %----Variables, and only variables, start with uppercase 
 */
variable            :   UPPER_WORD    
arguments           :   term   
                    |   arguments ',' term  


/*--- Fromual sources */
source                  :   general_term
// source               :== dag_source | internal_source | external_source | 'unknown' | '[' sources ']'
// sources              :== source | source ',' sources
// dag_source           :== name | inferences_record
// inference_record     :== 'inference' '(' inference_rule ',' useful_info ',' inference_parents ')
// inference_rule       :== atomic_word
// inference_parents    :== '[' ']' | '[' parent_list ']'
// parent_list          :== parent_info | parent_list ',' parent_info
// parent_info          :== source parent_details
// parent_details       :== null | ':' general_list
// internal_source      :== 'introduced' '(' intro_type optional_info ')'
// external_source      :== file_source | theory | creator_source
// file_source          :== 'file' '(' file_name file_info ')'
// file_inof            :== ',' name | null
// theory               :== 'theory' '(' theory_name optional_info ')'
// creator_source       :== 'creator' '(' creator_name optional_info ')'
// creator_name         :== atomic_word
/* sources                 | source
                        | sources ',' source 
/* */


/*---- Useful info fields */
optional_info       :   /* epsilon */
                    |   ',' useful_info

useful_info         :   general_list
// useful_info      :== '[' ']' | '[' info_items ']'
// info_items       :==   info_item | info_item ',' info_items
// info_item        :==   formula_item | inference_item | general_function
// formula_item     :==   description_item | iquote_item
// description_item :==   DESCRIPTION '(' atomic_word ')'
// iquote_item      :==   IQUOTE '(' atomic_word ')'
// inference_item   :==
// inference_status :==

// status_value     :==
// inference_info   :==
// assumptions_record :==
// refutation       :==
// new_symbol_record :==
// new_symbol_list  :==


/*-- include directives --*/
include             :   INCLUDE '(' file_name formula_selection ')' '.'  
formula_selection   :   /* null */       
                    |   ',' '[' name_list ']' 
name_list           :   name 
                    |   name_list ',' name 

/*---- Non-logical data */
general_term        :   general_data                                        
                    |   general_data  ':' general_term
                    |   general_list                                        
general_data        :   atomic_word                                         
                    |   general_function                                    
                    |   variable 
                    |   number 
                    |   DISTINCT_OBJECT
                    |   formula_data                                        
general_function    :   atomic_word '(' general_terms ')'                   
formula_data        :   DOLLAR_FOF '(' fof_formula ')'
                    |   DOLLAR_CNF '(' cnf_formula ')'
                    |   DOLLAR_FOT '(' term ')'
general_list        :   '[' ']' 
                    |   '[' general_terms ']' 
general_terms       :   general_term
                    |   general_terms ',' general_term

/*-- general purpose --*/
name                :   atomic_word      /*  */
                    |   INTEGER

atomic_word         :   LOWER_WORD
|                       SINGLE_QUOTED


atomic_defined_word     :   DOLLAR_WORD
atomic_system_word      :   DOLLAR_DOLLAR_WORD
number                  :   INTEGER
                        |   RATIONAL
                        |   REAL


file_name           :   SINGLE_QUOTED
null                :   /* <null> */

/*
 %----Rules from her on down are for defining tokens (terminal symbols) of the
 %----grammar, assuming they will be recognized by a lexical scanner.
 %----A ::- rule defines a token, a ::: rule defines a macro that is not a 
 %----token. Usual regexp notation is used. ...
 */

%%

/* *** ADDITIONAL C CODE ************************************************************************ */

int yyerror (const char *s)
{
    static const char *format = "\n<%5d> s='%s' yytext='%s' yychar='%d' (tptp)\n";
    printf(format, mere_lineno, s, mere_text, yychar);
    //snprintf(globalStringBuffer, MAX_GLOBAL_STRING_BUFFER_SIZE, format, yylineno, s, yytext, yychar);
    return 0;
}




