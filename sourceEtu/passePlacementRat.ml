(* Module de la passe de gestion des types *)
(* doit être conforme à l'interface Passe *)
open Tds
open Type
open Exceptions
open Ast

type t1 = Ast.AstType.programme
type t2 = Ast.AstPlacement.programme
(*
(* analyse_type_expression : AstType.expression -> AstPlacement.expression *)
(* Paramètre e : l'expression à analyser *)
(* Vérifie la bonne utilisation des types et tranforme l'expression
en une expression de type AstPlacement.expression *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_type_expression e = 
  match e with
   | AstType.Ident info ->
        begin
          match info_ast_to_info info with
          | InfoFun _ -> failwith "Internal Error"
          | InfoConst ( _, valeur ) -> (Int,AstPlacement.Entier(valeur))
          | InfoVar (_, t, _, _) -> (t,AstPlacement.Ident(info))
        end
      
     
  | AstType.Booleen b -> 
      (Bool,AstPlacement.Booleen (b))
  | AstType.Entier e ->
      (Int,AstPlacement.Entier(e))
  | AstType.Unaire (unaire,e) -> 
    begin    
    let (te, ne) = analyse_type_expression e in
    match te with
    | Rat -> 
      begin
      match unaire with
      | Numerateur -> (Int,AstPlacement.Unaire (Numerateur,ne))
      | Denominateur -> (Int,AstPlacement.Unaire (Denominateur,ne))
    end
    | _ -> raise(TypeInattendu (te,Rat))
    end    
  | AstType.Binaire (binaire, e1, e2) ->  
    begin  
      let (te2,ne2) = analyse_type_expression e2 in
      let (te1,ne1) = analyse_type_expression e1 in
      if (est_compatible te1 te2) then
        begin
        match (te1,binaire) with        
        | Int, Fraction -> (Rat,AstPlacement.Binaire(Fraction,ne1,ne2))
        | Int, Plus -> (Int,AstPlacement.Binaire(PlusInt,ne1,ne2))
        | Rat, Plus -> (Rat,AstPlacement.Binaire(PlusRat,ne1,ne2))
        | Int, Mult -> (Int,AstPlacement.Binaire(MultInt,ne1,ne2))
        | Rat, Mult -> (Rat,AstPlacement.Binaire(MultRat,ne1,ne2))
        | Int, Equ -> (Bool,AstPlacement.Binaire(EquInt,ne1,ne2))
        | Bool, Equ -> (Bool,AstPlacement.Binaire(EquBool,ne1,ne2))
        | Int, Inf -> (Bool,AstPlacement.Binaire(Inf,ne1,ne2))
        | _ -> raise (TypeBinaireInattendu (binaire, te1, te2))
        end
      else raise(TypeBinaireInattendu (binaire,te1,te2))
  
    end
    
  
  | AstType.AppelFonction _ -> failwith "pas traiter"
    (*begin
      match chercherGlobalement tds n  with
      | Some info -> 
        begin
          match info_ast_to_info info with
          | InfoFun _ -> let listne = List.map (analyse_tds_expression tds) liste in
                            AstPlacement.AppelFonction(info,listne)
          | _ -> raise(MauvaiseUtilisationIdentifiant n)
        end
      | None -> raise(IdentifiantNonDeclare n)
    end*)

*)

(* analyse_type_instruction : AstType.instruction -> AstPlacement.instruction *)
(* Paramètre i : l'instruction à analyser *)
(* Vérifie la bonne utilisation des types et tranforme l'instruction
en une instruction de type AstPlacement.instruction *)
(* Erreur si mauvaise utilisation des identifiants *)
let rec analyse_placement_instruction i dep reg =
  match i with
  | AstType.Declaration (info,e) ->
    begin
      match info_ast_to_info info with
      | InfoVar(_,t,_,_) -> 
        begin
        modifier_adresse_variable dep reg info;
        (AstPlacement.Declaration(info,e),getTaille(t))
        end
      | _ -> failwith "Internal error"
    end
    
  | AstType.Affectation (info,e) ->
      (AstPlacement.Affectation(info,e),0)
    
  | AstType.Empty ->
      (AstPlacement.Empty,0)
       
  | AstType.AffichageInt e ->
    (AstPlacement.AffichageInt(e),0)
  | AstType.AffichageBool e ->
    (AstPlacement.AffichageBool(e),0)
  | AstType.AffichageRat e ->
    (AstPlacement.AffichageRat(e),0)
  | AstType.Conditionnelle (ec,b1,b2) ->
    begin
      let nb1 = analyse_placement_bloc b1 dep reg in
      let nb2 = analyse_placement_bloc b2 dep reg in
      (AstPlacement.Conditionnelle(ec,nb1,nb2),0)
    end
| AstType.TantQue (ec,b) ->
  begin
    let nb = analyse_placement_bloc b dep reg in
    (AstPlacement.TantQue(ec,nb),0)
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
  AstPlacement.Fonction(info,nlp,nb)
            
             



        


(* analyser : AstType.programme -> AstPlacement.programme *)
(* Paramètre : le programme à analyser *)
(* Vérifie la bonne utilisation des identifiants et tranforme le programme
en un programme de type AstPlacement.programme *)
(* Erreur si mauvaise utilisation des identifiants *)
let analyser (AstType.Programme (fonctions,prog)) =
  
  let nf = List.map (analyse_placement_fonction "LB") fonctions in
  let nb = analyse_placement_bloc prog 0 "SB" in
  AstPlacement.Programme (nf,nb)
