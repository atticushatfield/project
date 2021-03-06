(* 
                         CS 51 Final Project
                         MiniML -- Evaluation
*)

(* This module implements a small untyped ML-like language under
   various operational semantics.
 *)
    
open Expr ;;
  
(* Exception for evaluator runtime, generated by a runtime error *)
exception EvalError of string ;;
(* Exception for evaluator runtime, generated by an explicit "raise" 
construct *)
exception EvalException ;;


(*......................................................................
  Environments and values 
 *)

module type Env_type = sig
    type env
    type value =
      | Val of expr
      | Closure of (expr * env)
    val create : unit -> env
    val close : expr -> env -> value
    val lookup : env -> varid -> value
    val extend : env -> varid -> value ref -> env
    val env_to_string : env -> string
    val value_to_string : ?printenvp:bool -> value -> string
  end

module Env : Env_type =
  struct
    type env = (varid * value ref) list
     and value =
       | Val of expr
       | Closure of (expr * env)

    (* Creates an empty environment *)
    let create () : env = [] ;;

    (* Creates a closure from an expression and the environment it's
       defined in *)
    let close (exp : expr) (env : env) : value =
      Closure (exp, env) ;;

    (* Looks up the value of a variable in the environment *)
    let lookup (env : env) (varname : varid) : value =
      let dissect (elt : varid * value ref) : bool =
        match elt with
        | v_id, _ -> if String.equal varname v_id then true else false 
      in let env_val_elt = List.find (fun elt -> dissect elt) env
      in match env_val_elt with
         | _, value_ref -> !value_ref ;;

    (* Returns a new environment just like env except that it maps the
       variable varid to loc *)
    let extend (env : env) (varname : varid) (loc : value ref) : env =
      (varname, loc) :: env ;;

    (* Returns a printable string representation of a value; the flag
       printenvp determines whether to include the environment in the
       string representation when called on a closure *)
    let value_to_string ?(printenvp : bool = true) (v : value) : string =
      match v with
      | Val (expr) -> exp_to_abstract_string expr
      | Closure (expr, envi) -> exp_to_abstract_string expr ;;

    (* Returns a printable string representation of an environment *)
    let env_to_string (env : env) : string =
      let env_elt_to_string : (varid * value ref) -> string = 
      fun elt ->
        match elt with
        | var_id, val_ref -> var_id ^ " -> " ^
                            (value_to_string (!val_ref))
      in
      String.concat " | " (List.map env_elt_to_string env) ;;
    
  end ;;


(*......................................................................
  Evaluation functions

  Each of the evaluation functions below, evaluates an expression exp
  in an enviornment env returning a result of type value. We've
  provided an initial implementation for a trivial evaluator, which
  just converts the expression unchanged to a value and returns it,
  along with "stub code" for three more evaluators: a substitution
  model evaluator and dynamic and lexical environment model versions.

  Each evaluator is of type expr -> Env.env -> Env.value for
  consistency, though some of the evaluators don't need an
  environment, and some will only return values that are "bare
  values" (that is, not closures). 

  DO NOT CHANGE THE TYPE SIGNATURES OF THESE FUNCTIONS. Compilation
  against our unit tests relies on their having these signatures. If
  you want to implement an extension whose evaluator has a different
  signature, implement it as eval_e below.  *)

(* The TRIVIAL EVALUATOR, which leaves the expression to be evaluated
   essentially unchanged, just converted to a value for consistency
   with the signature of the evaluators. *)
   
let eval_t (exp : expr) (_env : Env.env) : Env.value =
  (* coerce the expr, unchanged, into a value *)
  Env.Val exp ;;

(* The SUBSTITUTION MODEL evaluator -- to be completed *)

(* helpers for evaluating binops and unops *)

let binopeval (op : binop) (v1 : expr) (v2 : expr) : expr =
  match op, v1, v2 with
  | Plus, Num x1, Num x2 -> Num (x1 + x2)
  | Plus, _, _ -> raise EvalException
  | Minus, Num x1, Num x2 -> Num (x1 - x2)
  | Minus, _, _ -> raise EvalException
  | Times, Num x1, Num x2 -> Num (x1 * x2)
  | Times, _, _ -> raise EvalException
  | Equals, Num x1, Num x2 -> Bool (x1 = x2)
  | Equals, Bool b1, Bool b2 -> Bool (b1 = b2)
  | Equals, _, _ -> raise EvalException
  | LessThan, Num x1, Num x2 -> Bool (x1 < x2)
  | LessThan, _, _ -> raise EvalException ;;
  
let unopeval (op : unop) (e : expr) : expr = 
  match op, e with 
  | Negate, Num x -> Num (~- x)
  | Negate, Bool b -> Bool (not b)
  | Negate, _ -> raise EvalException ;;

let rec eval (xpr : expr) : expr = 
    match xpr with
    | Num _ | Bool _ | Raise | Unassigned | Var _ -> xpr
    | Unop (op, e1) -> unopeval op (eval e1)
    | Binop (op, e1, e2) -> binopeval op (eval e1) (eval e2)
    | Let (x, def, body) -> eval (subst x (eval def) body)
    | Letrec (x, def, body) -> eval (subst x (eval def) body)
    | Fun (_f_arg, _f_body) -> xpr
    | App (arg1, arg2) -> 
      (match arg1 with
       | Fun (f_arg, f_body) -> eval (Let ((f_arg), (eval arg2), f_body))
       | _ -> eval (App ((eval arg1), eval arg2)))
    | Conditional (c, t, e) -> 
      if eval c = Bool (true) then eval t else eval e ;;

let eval_s (exp : expr) (_env : Env.env) : Env.value =
  Env.Val (eval exp) ;;

     
(* The DYNAMICALLY-SCOPED ENVIRONMENT MODEL evaluator -- to be
   completed *)
   
let rec eval_d (_exp : expr) (_env : Env.env) : Env.value =
  match _exp with
    | Num (_) | Bool (_) | Raise -> Env.Val _exp 
    | Var x -> Env.lookup _env x 
    | Unop (op, e1) -> Env.Val (unopeval op e1)
    | Binop (op, e1, e2) -> Env.Val (binopeval op (eval e1) (eval e2))
    | Let (x, defi, body) -> 
        let newenv = Env.extend _env x (ref (eval_d defi _env))
        in eval_d body newenv
    | Letrec (x, defi, body) -> 
        let uns_env = Env.extend _env x (ref (Env.Val Unassigned))               
        in let x_val = eval_d defi uns_env
        in eval_d body (Env.extend uns_env x (ref (x_val)))
    | Fun (_f_arg, _f_body) -> Env.Val _exp
      (*eval_d _f_body (Env.extend _env _f_arg (ref (Env.lookup _env _f_arg)))*)
    | App (arg1, arg2) -> 
      (match eval_d arg1 _env with
       | Env.Val Fun (f_arg, f_body) ->  
         eval_d f_body (Env.extend _env f_arg (ref (eval_d arg2 _env)))
       | _ -> raise EvalException)
    | Conditional (c, t, e) -> 
      if eval_d c _env = Env.Val (Bool (true)) 
      then eval_d t _env 
      else eval_d e _env
    | Unassigned -> raise EvalException ;;
       
(* The LEXICALLY-SCOPED ENVIRONMENT MODEL evaluator -- optionally
   completed as (part of) your extension *)
   
let eval_l (_exp : expr) (_env : Env.env) : Env.value =
  failwith "eval_l not implemented" ;;

(* The EXTENDED evaluator -- if you want, you can provide your
   extension as a separate evaluator, or if it is type- and
   correctness-compatible with one of the above, you can incorporate
   your extensions within eval_s, eval_d, or eval_l. *)

let eval_e _ =
  failwith "eval_e not implemented" ;;
  
(* Connecting the evaluators to the external world. The REPL in
   miniml.ml uses a call to the single function evaluate defined
   here. Initially, evaluate is the trivial evaluator eval_t. But you
   can define it to use any of the other evaluators as you proceed to
   implement them. (We will directly unit test the four evaluators
   above, not the evaluate function, so it doesn't matter how it's set
   when you submit your solution.) *)
   
let evaluate = eval_d ;;
