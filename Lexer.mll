{
  open Parser;;
}
(* Considering you guys are new to OCaml , we'll make a code follow through , cheers to my adhd brain for doing this*)
(* ocamllex, which is a tool for generating lexers , which are basically tokenizers , I hope you have a slight idea of that while studying initial NLP documentation smwh in your life , but anyways , too much of yap *)
(*This opens the Parser module so you can use token constructors like VAR, NVAR, NUM, etc. These are defined in parser.mly.*)
rule token = parse
    eof                   {EOF}
  | [' ' '\t' '\n']+      {token lexbuf}
  | '.'                   {ENDL}
  | ['A'-'Z' '_']['A'-'Z' 'a'-'z' '0'-'9' '_']*  as v {VAR(v)}
  | ['a'-'z']['A'-'Z' 'a'-'z' '0'-'9' '_']* as c {NVAR(c)} 
  | '0'|['1'-'9']['0'-'9']*     as n {NUM(int_of_string n)}
  | '('                   {LPAREN}
  | ')'                   {RPAREN}
  | '['                   {LB}
  | ']'                   {RB}
  | ','                   {AND}
  | ';'                   {OR}
  | ":-"                  {COND}
  | '|'                   {SLICE}
  | '!'                   {OFC}
  | '%'                   {line_comment lexbuf}
  | "/*"                  {block_comment 0 lexbuf}

(* Adding a rule in the token function for the new sequence: | "=>"                  {IMPLIES} *)
and line_comment = parse
    eof                   {EOF}
  | '\n'                  {token lexbuf}
  |   _                   {line_comment lexbuf}

and block_comment depth = parse
    eof                   {EOF}
  | "*/"                  {if depth = 0 then token lexbuf else block_comment (depth-1) lexbuf}
  | "/*"                  {block_comment (depth+1) lexbuf}
  |  _                    {block_comment depth lexbuf}
