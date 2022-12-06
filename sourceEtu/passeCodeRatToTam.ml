(* Module de la passe de gestion des types *)
(* doit être conforme à l'interface Passe *)
open Tds
open Type
open Exceptions
open Ast
open Tam
open Ast.AstType
open Ast.AstPlacement

type t1 = Ast.AstPlacement.programme
type t2 = String

(* analyse_code_expression : AstPlacement.expression -> String *)
(* Paramètre e : l'expression à analyser *)
(* Transforme l'expression en code TAM *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_code_expression e = 
  match e with 
  | AppelFonction (info,eliste) -> 
    begin
    let code = String.concat " " (List.map analyse_code_expression eliste) in
    match info_ast_to_info info with
    | InfoFun (n,_,_) -> c^(call "ST" n)
    | _ -> failwith "Internal error"
    end
  | Ident info -> 
    begin
    match info_ast_to_info info with
      | InfoVar (n,t,d,r) -> load (getTaille t) d r
      | InfoConst (n,i) -> loadl_int i
      | InfoFun _ -> failtwith "Internal error"
    end
  | Bool b ->
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
    | MultRat -> code1^code2^(call "ST" "RMult")
    | EquInt -> code1^code2^(subr "IEq")
    | EquBool -> code1^code2^(subr "IEq")
    | Inf -> code1^code2^(subr "ILss")
    end


(* analyse_placement_instruction : AstType.instruction -> AstPlacement.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des types et tranforme l'instruction
en une instruction de type AstPlacement.instruction *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_code_instruction i dep reg =
  match i with
  | Declaration (info,e) ->
    begin
      match info_ast_to_info info with
      | InfoVar(n,t,d,r) -> 
        begin
        let code = analyse_code_expression e in
        (push (getTaille t))^code^(store (getTaille t) d r)
        end
      | _ -> failwith "Internal error"
    end
    
  | Affectation (info,e) ->
      begin
        match info_ast_to_info info with
        | InfoVar (n,t,d,r) ->
          let code = analyse_code_expression e in
          code^(store (getTaille t) d r)
        | _ -> failwith "Internal error"
    
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
      let codeb2 = analyse_code_expression b2 in
      let codeb1 = analyse_code_expression b1 in
      let codee = analyse_code_expression ec in
      let etqElse = label getEtiquette in
      let etqEnd = label getEtiquette in
      codee^(jumpi 0 eqtElse)^codeb1^(jump etqElse)^etqElse^codeb2^etqEnd
      end
| TantQue (ec,b) ->
  begin
    let codeb = analyse_code_expression b in
    let codee = analyse_code_expression ec in
    let etqWhile = label getEtiquette in
    let etqEnd = label getEtiquette in
    etqWhile^codee^(jumpi 0 eqtEnd)^codeb^(jump etqWhile)^etqEnd
  end


  
  | AstType.Retour (e,info) ->
    begin
      match info_ast_to_info info with
      |InfoFun(_,t,lp) -> 
        let tailleType = getTaille t in
        let tailleList = List.fold_left (fun init tl -> init + (getTaille tl)) 0 lp in
        (AstPlacement.Retour(e,tailleType,tailleList),0)
      | _ -> failwith "Internal error"
      end


(* analyse_placement_bloc :  AstType.bloc -> AstPlacement.bloc *)
(* Paramètre li : liste d'instructions à analyser *)
(* Vérifie la bonne utilisation des types et tranforme le bloc en un bloc de type AstPlacement.bloc *)
(* Erreur si mauvaise utilisation des identifiants *)
and analyse_placement_bloc li dep reg =
  match li with
  | [] -> ([],0)
  | hd::tl -> 
    begin
      let (nhd,thd) = analyse_placement_instruction hd dep reg in
      let (ntl,ttl) = analyse_placement_bloc tl (dep+thd) reg in
      (nhd::ntl,thd+ttl)
    end

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

(* analyse_placement_fonction : tds -> AstSyntax.fonction -> AstPlacement.fonction *)
(* Paramètre tds : la table des symboles courante *)
(* Paramètre : la fonction à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme la fonction
en une fonction de type AstPlacement.fonction *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyse_placement_fonction reg (AstType.Fonction(info,lp,b))  =
    
  let nb = analyse_placement_bloc b 3 reg in
  let nlp = placement_list_param_fun (List.rev lp) reg 0 in
  AstPlacement.Fonction(info,(List.rev nlp),nb)
            
             



        


(* analyser : AstType.programme -> AstPlacement.programme *)
(* Paramètre : le programme à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme le programme
en un programme de type AstPlacement.programme *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyser (AstPlacement.Programme (fonctions,prog)) =
  let entete = getEntete in
  let codeFonction = List.map analyse_code_fonction fonctions in
  let codeProgramme = analyse_code_bloc prog in
  entete ^ codeFonction ^ "main\n" ^ codeProgramme ^ halt
