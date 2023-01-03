
(* The type of tokens. *)

type token = 
  | WHILE
  | TRUE
  | SLASH
  | RETURN
  | RAT
  | PV
  | PRINT
  | PO
  | PLUS
  | PI
  | PF
  | NUM
  | NULL
  | NEW
  | MULT
  | INT
  | INF
  | IF
  | ID of (string)
  | FALSE
  | EQUAL
  | EOF
  | ENTIER of (int)
  | ELSE
  | DP
  | DENOM
  | CONST
  | CO
  | CF
  | CALL
  | BOOL
  | AO
  | AF
  | ADRESSE

(* This exception is raised by the monolithic API functions. *)

exception Error

(* The monolithic API. *)

val main: (Lexing.lexbuf -> token) -> Lexing.lexbuf -> (Ast.AstSyntax.programme)
