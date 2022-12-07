(* Module de la passe de gestion des types *)
(* doit être conforme à l'interface Passe *)
open Tds
open Type
open Ast
open Tam
open Ast.AstType
open Ast.AstPlacement
open Code

type t1 = Ast.AstPlacement.programme
type t2 = string

(* analyse_code_expression : AstPlacement.expression -> String *)
(* Paramètre e : l'expression à analyser *)
(* Transforme l'expression en code TAM *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_code_expression e = 
  match e with 
  | AppelFonction (info,eliste) -> 
    begin
    let code = String.concat "" (List.map analyse_code_expression eliste) in
    match info_ast_to_info info with
    | InfoFun (n,_,_) -> code^(call "ST" n)
    | _ -> failwith "Internal error"
    end
  | Ident info -> 
    begin
    match info_ast_to_info info with
      | InfoVar (_,t,d,r) -> load (getTaille t) d r
      | InfoConst (_,i) -> loadl_int i
      | InfoFun _ -> failwith "Internal error"
    end
  | Booleen b ->
    begin
    if b then loadl_int 1
    else loadl_int 0
    end
  | Entier i -> 
    loadl_int i
  | Unaire (op,e) -> 
    begin
    let code = analyse_code_expression e in
    match op with
    | Numerateur -> code ^ (pop 0 1)
    | Denominateur -> code ^ (pop 1 1)
    end
  | Binaire (op,e1,e2) ->
    begin
    let code1 = analyse_code_expression e1 in
    let code2 = analyse_code_expression e2 in
    match op with
    | Fraction -> code1^code2^(call "ST" "norm")
    | PlusInt -> code1^code2^(subr "IAdd")
    | PlusRat -> code1^code2^(call "ST" "RAdd")
    | MultInt -> code1^code2^(subr "IMul")
    | MultRat -> code1^code2^(call "ST" "RMul")
    | EquInt -> code1^code2^(subr "IEq")
    | EquBool -> code1^code2^(subr "IEq")
    | Inf -> code1^code2^(subr "ILss")
    end


(* analyse_placement_instruction : AstType.instruction -> AstPlacement.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des types et tranforme l'instruction
en une instruction de type AstPlacement.instruction *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_code_instruction i =
  match i with
  | Declaration (info,e) ->
    begin
      match info_ast_to_info info with
      | InfoVar(_,t,d,r) -> 
        begin
        let code = analyse_code_expression e in
        (push (getTaille t))^code^(store (getTaille t) d r)
        end
      | _ -> failwith "Internal error"
    end
    
  | Affectation (info,e) ->
    begin
      match info_ast_to_info info with
      | InfoVar (_,t,d,r) ->
        let code = analyse_code_expression e in
        code^(store (getTaille t) d r)
      | _ -> failwith "Internal error"
    end
  | Empty -> ""
       
  | AffichageInt e ->
    let code = analyse_code_expression e in
    code^(subr "IOut")
  | AffichageBool e ->
    let code = analyse_code_expression e in
    code^(subr "BOut")
  | AffichageRat e ->
    let code = analyse_code_expression e in
    code^(call "ST" "ROut")
  | Conditionnelle (ec,b1,b2) ->
    begin
      let codeb2 = analyse_code_bloc b2 in
      let codeb1 = analyse_code_bloc b1 in
      let codee = analyse_code_expression ec in
      let etqElse = label (getEtiquette ()) in
      let etqEnd = label (getEtiquette ()) in
      codee^(jumpif 0 etqElse)^codeb1^(jump etqEnd)^etqElse^codeb2^etqEnd
      end
| TantQue (ec,b) ->
  begin
    let codeb = analyse_code_bloc b in
    let codee = analyse_code_expression ec in
    let etqWhile = label (getEtiquette ()) in
    let etqEnd = label (getEtiquette ()) in
    etqWhile^codee^(jumpif 0 etqEnd)^codeb^(jump etqWhile)^etqEnd
  end  
| Retour (e,tResult,tParam) ->
  begin
    let code = analyse_code_expression e in
    code^(return tResult tParam)
  end


(* analyse_placement_bloc :  AstPlacement.bloc -> String *)
(* Paramètre li : liste d'instructions à analyser *)
(* Vérifie la bonne utilisation des types et tranforme le bloc en un bloc de type AstPlacement.bloc *)
(* Erreur si mauvaise utilisation des identifiants *)
and analyse_code_bloc (li,t) =
  let codeBloc = String.concat "" (List.map analyse_code_instruction li) in (*List.fold_left (fun init i -> init^(analyse_code_instruction i)) "" li in*)
  codeBloc^(pop 0 t)
  
(*
let rec placement_list_param_fun liste reg dep =
  match liste with
  | [] -> []
  | hd::tl -> 
    begin 
      match info_ast_to_info hd with
      | InfoVar (_,t,_,_) ->
        let depVar = dep-getTaille(t) in
        modifier_adresse_variable depVar reg hd;
        hd::(placement_list_param_fun tl reg depVar)
      | _ -> failwith "Internal error"
    end
*)
(* analyse_placement_fonction : tds -> AstSyntax.fonction -> AstPlacement.fonction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre : la fonction à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme la fonction
en une fonction de type AstPlacement.fonction *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyse_code_fonction (AstPlacement.Fonction(info,_,b))  =
  (* 
  let nb = analyse_placement_bloc b 3 reg in
  let nlp = placement_list_param_fun (List.rev lp) reg 0 in
  AstPlacement.Fonction(info,(List.rev nlp),nb)
         *)
  match info_ast_to_info info with
  | InfoFun (n,_,_) -> 
    let etq = label n in
    let code = analyse_code_bloc b in
    etq^code^(halt)
  | _ -> failwith "Internal Error"
             



        


(* analyser : AstType.programme -> AstPlacement.programme *)
(* Paramètre : le programme à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme le programme
en un programme de type AstPlacement.programme *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyser (AstPlacement.Programme (fonctions,prog)) =
  let entete = getEntete () in
  let codeFonction = List.fold_left (fun init f -> init^(analyse_code_fonction f)) "" fonctions in
  let codeProgramme = analyse_code_bloc prog in
  entete ^ codeFonction ^ "main\n" ^ codeProgramme ^ halt
