%{
  open Backend;;
%}

(* Token declarations *)
%token <string> VAR NVAR          (* Capital letter ya underscore se start hone wale variables aur small letter se start hone wale constants ke liye *)
%token <int> NUM                  (* Integer numbers ke liye *)
%token <string> STRING            (* "..." string literals ke liye *)
%token LPAREN RPAREN LB RB       (* Brackets: (), [] ke liye *)
%token AND ENDL COND EOF OR OFC SLICE IMPLIES
                                (** Logical aur structural symbols jaise ",", ".", ":-", etc. ke liye *)

(* Operator precedence definitions *)
%left AND OR                     (** Left-associative operators AND "," aur OR ";" *)
%nonassoc ENDL OFC SLICE         (** Non-associative tokens *)

(* Entry points *)
%start program goal
%type <Backend.program> program
%type <Backend.goal> goal

%%

(* Program structure *)
program:
    EOF                                 { [] }                           (** Agar file empty ho to program khali list return karta hai *)
  | clause_list EOF                     { $1 }                           (** Agar clauses hain to unka list return hota hai *)
;

(* List of clauses *)
clause_list:
    clause                              { [$1] }                         (** Ek hi clause ho to list mein wrap karo *)
  | clause clause_list                  { ($1)::$2 }                     (** Pehla clause list ke aage lagao *)
;

(* Clause definition: fact ya rule *)
clause:
    atom ENDL                           { Fact(H($1)) }                  (** Simple fact, e.g., parent(john, doe). *)
  | atom COND atom_list ENDL            { Rule(H($1), B($3)) }           (** Rule, e.g., grandparent(X, Y) :- parent(X, Z), parent(Z, Y). *)
  | atom IMPLIES atom_list ENDL         { Rule(H($1), B($3)) }           (** Syntactic sugar: implication style, e.g., a => b. *)
;

(* Goal/query *)
goal:
    atom_list ENDL                      { G($1) }                         (** Query end hota hai "." se *)
;

(* List of atoms joined with "," *)
atom_list:
    atom                                { [$1] }                         (** Ek hi atom ho *)
  | atom AND atom_list                  { ($1)::$3 }                     (** Multiple atoms comma separated *)
;

(* Atom definition *)
atom:
    NVAR                                { A($1, []) }                    (** Simple constant, e.g., john *)
  | NVAR LPAREN term_list RPAREN        { A($1, $3) }                    (** Function atom, e.g., parent(john, X) *)
  | OFC                                 { A("cut", []) }                (** Cut operator (!) *)
;

(* List of arguments inside functions *)
term_list:
    term                                { [$1] }
  | term AND term_list                  { ($1)::$3 }
;

(* Term ka definition: variable, atom, number, string, list etc. *)
term:
    LPAREN term RPAREN                  { $2 }                           (** Brackets mein term ko wrap karne ke liye *)
  | VAR                                 { V($1) }                        (** Variable jaise X, Y *)
  | NVAR                                { ATOM($1, []) }                (** Constant atom *)
  | NUM                                 { CInt($1) }                     (** Integer number *)
  | STRING                              { CString($1) }                  (** String literal *)
  | NVAR LPAREN term_list RPAREN        { ATOM($1, $3) }                 (** Function style atom *)
  | list                                { $1 }                           (** Agar term ek list ho *)
;

(* List definitions *)
list:
    LB RB                               { ATOM("empty_list", []) }      (** Empty list "[]" *)
  | LB list_body RB                     { $2 }                           (** Non-empty list "[a, b]" etc. *)
;

list_body:
    term                                { ATOM("list", [$1; ATOM("empty_list", [])]) }  (** Ek hi item list mein *)
  | term AND list_body                  { ATOM("list", [$1; $3]) }                     (** Multiple items comma separated *)
  | term SLICE term                     { ATOM("list", [$1; $3]) }                     (** Head|Tail style list, e.g., [H|T] *)
;
