# 1 "lexer.mll"
 
  open Parser
  open Lexing

  exception Error of string

  (* lève l'exception avec des informations de positions *)
  let error lexbuf =
    raise (Error ("Unexpected char: " ^ lexeme lexbuf ^ " at "
                  ^ string_of_int (lexeme_start lexbuf) ^ "-"
                  ^ string_of_int (lexeme_end lexbuf)))

  (* on utilise une table pour les mots-clefs de façon à éviter l'ajout *)
  (*  d'états à l'automate résultant *)
  let ident =
    let kws = Hashtbl.create 16 in
    List.iter (fun (kw, token) -> Hashtbl.add kws kw token)
      [
        "const",   CONST;
        "print",   PRINT;
        "if",      IF;
        "else",    ELSE;
        "while",   WHILE;
        "bool",    BOOL;
        "int",     INT;
        "rat",     RAT;
        "call",    CALL;
        "num",     NUM;
        "denom",   DENOM;
        "true",    TRUE;
        "false",   FALSE;        
        "return",  RETURN;
        "new",     NEW;
        "null",    NULL
      ];
    fun id ->
      match Hashtbl.find_opt kws id with
      | Some kw -> kw
      | None -> ID id

# 43 "lexer.ml"
let __ocaml_lex_tables = {
  Lexing.lex_base =
   "\000\000\234\255\235\255\079\000\016\000\026\000\238\255\239\255\
    \240\255\241\255\242\255\243\255\245\255\246\255\247\255\248\255\
    \249\255\250\255\251\255\252\255\015\000\254\255\255\255\001\000\
    ";
  Lexing.lex_backtrk =
   "\255\255\255\255\255\255\019\000\018\000\021\000\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\011\000\255\255\255\255\002\000\
    ";
  Lexing.lex_default =
   "\001\000\000\000\000\000\255\255\255\255\255\255\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\255\255\000\000\000\000\023\000\
    ";
  Lexing.lex_trans =
   "\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\021\000\022\000\255\255\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \021\000\000\000\000\000\000\000\000\000\000\000\006\000\000\000\
    \016\000\015\000\010\000\011\000\000\000\005\000\000\000\020\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\008\000\019\000\009\000\014\000\023\000\007\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\004\000\004\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\013\000\000\000\012\000\000\000\000\000\
    \000\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\018\000\003\000\017\000\000\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\000\000\000\000\000\000\000\000\003\000\000\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \002\000\255\255\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    ";
  Lexing.lex_check =
   "\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\000\000\000\000\023\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\255\255\255\255\255\255\255\255\255\255\000\000\255\255\
    \000\000\000\000\000\000\000\000\255\255\000\000\255\255\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\020\000\000\000\
    \004\000\004\000\004\000\004\000\004\000\004\000\004\000\004\000\
    \004\000\004\000\005\000\005\000\005\000\005\000\005\000\005\000\
    \005\000\005\000\005\000\005\000\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\000\000\255\255\000\000\255\255\255\255\
    \255\255\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\000\
    \000\000\000\000\000\000\000\000\003\000\000\000\255\255\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\255\255\255\255\255\255\255\255\003\000\255\255\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\003\000\003\000\003\000\003\000\003\000\003\000\
    \003\000\003\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \000\000\023\000\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    \255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\255\
    ";
  Lexing.lex_base_code =
   "";
  Lexing.lex_backtrk_code =
   "";
  Lexing.lex_default_code =
   "";
  Lexing.lex_trans_code =
   "";
  Lexing.lex_check_code =
   "";
  Lexing.lex_code =
   "";
}

let rec token lexbuf =
   __ocaml_lex_token_rec lexbuf 0
and __ocaml_lex_token_rec lexbuf __ocaml_lex_state =
  match Lexing.engine __ocaml_lex_tables __ocaml_lex_state lexbuf with
      | 0 ->
# 44 "lexer.mll"
               ( new_line lexbuf; token lexbuf )
# 169 "lexer.ml"

  | 1 ->
# 46 "lexer.mll"
               ( token lexbuf )
# 174 "lexer.ml"

  | 2 ->
# 48 "lexer.mll"
               ( token lexbuf )
# 179 "lexer.ml"

  | 3 ->
# 51 "lexer.mll"
               ( PV )
# 184 "lexer.ml"

  | 4 ->
# 52 "lexer.mll"
               ( AO )
# 189 "lexer.ml"

  | 5 ->
# 53 "lexer.mll"
               ( AF )
# 194 "lexer.ml"

  | 6 ->
# 54 "lexer.mll"
               ( PO )
# 199 "lexer.ml"

  | 7 ->
# 55 "lexer.mll"
               ( PF )
# 204 "lexer.ml"

  | 8 ->
# 56 "lexer.mll"
               ( EQUAL )
# 209 "lexer.ml"

  | 9 ->
# 57 "lexer.mll"
               ( CO )
# 214 "lexer.ml"

  | 10 ->
# 58 "lexer.mll"
               ( CF )
# 219 "lexer.ml"

  | 11 ->
# 59 "lexer.mll"
               ( SLASH )
# 224 "lexer.ml"

  | 12 ->
# 60 "lexer.mll"
               ( PLUS )
# 229 "lexer.ml"

  | 13 ->
# 61 "lexer.mll"
               ( MULT )
# 234 "lexer.ml"

  | 14 ->
# 62 "lexer.mll"
               ( INF )
# 239 "lexer.ml"

  | 15 ->
# 63 "lexer.mll"
               ( DP )
# 244 "lexer.ml"

  | 16 ->
# 64 "lexer.mll"
               ( PI )
# 249 "lexer.ml"

  | 17 ->
# 65 "lexer.mll"
               ( ADRESSE )
# 254 "lexer.ml"

  | 18 ->
let
# 68 "lexer.mll"
                      i
# 260 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 69 "lexer.mll"
               ( ENTIER (int_of_string i) )
# 264 "lexer.ml"

  | 19 ->
let
# 71 "lexer.mll"
                                                 n
# 270 "lexer.ml"
= Lexing.sub_lexeme lexbuf lexbuf.Lexing.lex_start_pos lexbuf.Lexing.lex_curr_pos in
# 72 "lexer.mll"
               ( ident n )
# 274 "lexer.ml"

  | 20 ->
# 75 "lexer.mll"
               ( EOF )
# 279 "lexer.ml"

  | 21 ->
# 77 "lexer.mll"
               ( error lexbuf )
# 284 "lexer.ml"

  | __ocaml_lex_state -> lexbuf.Lexing.refill_buff lexbuf;
      __ocaml_lex_token_rec lexbuf __ocaml_lex_state

;;

