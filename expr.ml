(* 
                         CS 51 Final Project
                        MiniML -- Expressions
*)

(*......................................................................
  Abstract syntax of MiniML expressions 
 *)

type unop =
  | Negate
;;
    
type binop =
  | Plus
  | Minus
  | Times
  | Equals
  | LessThan
;;

type varid = string ;;
  
type expr =
  | Var of varid                         (* variables *)
  | Num of int                           (* integers *)
  | Bool of bool                         (* booleans *)
  | Unop of unop * expr                  (* unary operators *)
  | Binop of binop * expr * expr         (* binary operators *)
  | Conditional of expr * expr * expr    (* if then else *)
  | Fun of varid * expr                  (* function definitions *)
  | Let of varid * expr * expr           (* local naming *)
  | Letrec of varid * expr * expr        (* recursive local naming *)
  | Raise                                (* exceptions *)
  | Unassigned                           (* (temporarily) unassigned *)
  | App of expr * expr                   (* function applications *)
;;
  
(*......................................................................
  Manipulation of variable names (varids)
 *)

(* varidset -- Sets of varids *)
module SS = Set.Make (struct
                       type t = varid
                       let compare = String.compare
                     end ) ;;

type varidset = SS.t ;;

(* same_vars :  varidset -> varidset -> bool
   Test to see if two sets of variables have the same elements (for
   testing purposes) *)
let same_vars : varidset -> varidset -> bool =
  SS.equal;;

(* vars_of_list : string list -> varidset
   Generate a set of variable names from a list of strings (for
   testing purposes) *)
let vars_of_list : string list -> varidset =
  SS.of_list ;;
  
(* free_vars : expr -> varidset
   Return a set of the variable names that are free in expression
   exp *)
let free_vars (exp : expr) : varidset =
  failwith "free_vars not implemented" ;;
  
(* new_varname : unit -> varid
   Return a fresh variable, constructed with a running counter a la
   gensym. Assumes no variable names use the prefix "var". (Otherwise,
   they might accidentally be the same as a generated variable name.) *)
let new_varname () : varid =
  failwith "new_varname not implemented" ;;

(*......................................................................
  Substitution 

  Substitution of expressions for free occurrences of variables is the
  cornerstone of the substitution model for functional programming
  semantics.
 *)

(* subst : varid -> expr -> expr -> expr
   Substitute repl for free occurrences of var_name in exp *)
let subst (var_name : varid) (repl : expr) (exp : expr) : expr =
  failwith "subst not implemented" ;;

(*......................................................................
  String representations of expressions
 *)
   
    
(* exp_to_concrete_string : expr -> string
   Returns a concrete syntax string representation of the expr *)
let binop_to_concrete_str (bin : binop) : string =
  match bin with
  | Plus -> " + " | Minus -> " - " | Times -> " * " | Equals -> " = " 
  | LessThan -> " < " ;;

let rec exp_to_concrete_string exp =
  match exp with
  | Num (itgr) -> (string_of_int itgr)
  | Var (varbl) -> varbl
  | Bool (b) -> (string_of_bool b)
  | Unop (Negate,e) -> 
                  (match e with
                  | Bool (tf) -> "not " ^ (string_of_bool tf) 
                  | _ -> " ~- (" ^ (exp_to_concrete_string e) ^ ")")
  | Binop (b,e1,e2) -> (exp_to_concrete_string e1) ^ (binop_to_concrete_str b) ^
                        (exp_to_concrete_string e2)   
            
  | Conditional (c,t,e) -> "if " ^ (exp_to_concrete_string c) ^ 
                          "\nthen " ^ (exp_to_concrete_string t) ^
                          "\nelse " ^ (exp_to_concrete_string e) 
  | Fun (v,e) -> "fun " ^ v ^ " -> " ^
                (exp_to_concrete_string e) 
  | Let (v,eq,ex) -> "let " ^ v ^ " = " ^  
                    (exp_to_concrete_string eq) ^ " in " ^ 
                    (exp_to_concrete_string ex) 
  | Letrec (v,eq,ex) -> "let rec " ^ v ^ " = " ^ 
                       (exp_to_concrete_string eq) ^ " in " ^ 
                       (exp_to_concrete_string ex) 
  | App (f,arg) -> (exp_to_concrete_string f) ^ " " ^
                     (exp_to_concrete_string arg) 
  | Raise -> "Raise" 
  | Unassigned -> "Unassigned" ;;

let rec exp_to_concrete_string exp =
  match exp with
  | Num (itgr) -> (string_of_int itgr)
  | Var (varbl) -> varbl
  | Bool (b) -> (string_of_bool b)
  | Unop (Negate,e) -> 
                  (match e with
                  | Bool (tf) -> "not " ^ (string_of_bool tf) 
                  | _ -> " ~- (" ^ (exp_to_concrete_string e) ^ ")")
  | Binop (b,e1,e2) -> (exp_to_concrete_string e1) ^ (binop_to_str b) ^
                        (exp_to_concrete_string e2)   
            
  | Conditional (c,t,e) -> "if " ^ (exp_to_concrete_string c) ^ 
                          "\nthen " ^ (exp_to_concrete_string t) ^
                          "\nelse " ^ (exp_to_concrete_string e) 
  | Fun (v,e) -> "fun " ^ v ^ " -> " ^
                (exp_to_concrete_string e) 
  | Let (v,eq,ex) -> "let " ^ v ^ " = " ^  
                    (exp_to_concrete_string eq) ^ " in " ^ 
                    (exp_to_concrete_string ex) 
  | Letrec (v,eq,ex) -> "let rec " ^ v ^ " = " ^ 
                       (exp_to_concrete_string eq) ^ " in " ^ 
                       (exp_to_concrete_string ex) 
  | App (f,arg) -> (exp_to_concrete_string f) ^ " " ^
                     (exp_to_concrete_string arg) 
  | Raise -> "Raise" 
  | Unassigned -> "Unassigned" ;;


(* exp_to_abstract_string : expr -> string
   Returns a string representation of the abstract syntax of the expr *)
let exp_to_abstract_string (exp : expr) : string =
   ;;
