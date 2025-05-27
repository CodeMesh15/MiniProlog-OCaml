{
  open Parser;;
}
(* Considering you guys are new to OCaml , we'll make a code follow through , cheers to my adhd brain for doing this*)
(* ocamllex, which is a tool for generating lexers , which are basically tokenizers , I hope you have a slight idea of that while studying initial NLP documentation smwh in your life , but anyways , too much of yap *)
(*This opens the Parser module so you can use token constructors like VAR, NVAR, NUM, etc. These are defined in parser.mly.*)
(* Switching to hindi , considering everyone viewing this would prolly be an indian , 
open parser wali line batati hai ki Parser module ke andar jo tokens define kiye gaye hain (VAR, NUM, COND, etc.), unko yahan use karna allow hai. Without this line, OCaml yeh tokens nahi pehchaanega. *)
rule token = parse
(*rule token = parse
 Yahan ek main rule banaya gaya hai jiska naam token hai. Jab bhi lexer kisi input file ko read karega, woh is rule se matching karei!!

*)
    eof                   {EOF}
    (*Agar input file end ho gayi hai (khaali ho gaya), toh EOF token return karega. Matlab input khatam ho gaya.*)
  | [' ' '\t' '\n']+      {token lexbuf}
  (* Ye line white spaces ko handle karti hai—jaise space, tab wgr. Unko ignore karta hai aur dobara token rule ko call karta hai next character ke liye. Yani, blank jagah skip kar raha hai.*)
  | '.'                   {ENDL}
  (* Prolog mein har fact ya rule ke end mein . lagta hai. Ye usi ko recognize karta hai aur ENDL token return karta hai.*)
  | ['A'-'Z' '_']['A'-'Z' 'a'-'z' '0'-'9' '_']*  as v {VAR(v)}
  (*Ye line Prolog ke variables ko detect karti hai. Variable hamesha capital letter ya underscore se start hota hai. Jaise X, Name, _temp. Isko VAR token ke form mein return karta hai.*)
  | ['a'-'z']['A'-'Z' 'a'-'z' '0'-'9' '_']* as c {NVAR(c)} 
  (*Ye hai atoms ya constants ke liye. Jaise john, male, likesPizza. Ye small letter se start hote hain. Isko NVAR token ke roop mein bhejta hai (although naam thoda misleading hai, ATOM better hota).*)
  | '0'|['1'-'9']['0'-'9']*     as n {NUM(int_of_string n)}
  (*Ye numbers ko match karta hai. Jaise 42, 0, 1234. Match hone par number ko string se integer mein convert karta hai aur NUM token ke form mein return karta hai.*)
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
 (*Ye sab Prolog ke special symbols hain:*)
(* Adding a rule in the token function for the new sequence: | "=>" {IMPLIES} *)
and line_comment = parse
    eof                   {EOF}
  | '\n'                  {token lexbuf}
  |   _                   {line_comment lexbuf}
  (* Ye line batati hai ki agar % dikhe, toh wo comment start hai. Tab tak ignore karega jab tak newline na aaye. Iske liye ek alag rule call hota hai line_comment*)
(*Jab % comment start ho jaye, tab ye har character ko ignore karega jab tak newline (\n) na mil jaye. Tab jaake dobara token rule pe wapas jaata hai.*)
and block_comment depth = parse
    eof                   {EOF}
  | "*/"                  {if depth = 0 then token lexbuf else block_comment (depth-1) lexbuf}
  | "/*"                  {block_comment (depth+1) lexbuf}
  |  _                    {block_comment depth lexbuf}
  (*Ye block comment ko handle karta hai—jo /* */ ke beech likha hota hai.*)
  (*nested block comments bhi handle karta hai. Har baar agar /* mile, toh depth badhata hai. Aur jab */ mile toh depth kam karta hai. Jab depth 0 ho jaye, tab comment close ho chuka hota hai.*)
