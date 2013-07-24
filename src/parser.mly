/**************************************************************************/
/*                        Lem                                             */
/*                                                                        */
/*          Dominic Mulligan, University of Cambridge                     */
/*          Francesco Zappa Nardelli, INRIA Paris-Rocquencourt            */
/*          Gabriel Kerneis, University of Cambridge                      */
/*          Kathy Gray, University of Cambridge                           */
/*          Peter Boehm, University of Cambridge (while working on Lem)   */
/*          Peter Sewell, University of Cambridge                         */
/*          Scott Owens, University of Kent                               */
/*          Thomas Tuerk, University of Cambridge                         */
/*                                                                        */
/*  The Lem sources are copyright 2010-2013                               */
/*  by the UK authors above and Institut National de Recherche en         */
/*  Informatique et en Automatique (INRIA).                               */
/*                                                                        */
/*  All files except ocaml-lib/pmap.{ml,mli} and ocaml-libpset.{ml,mli}   */
/*  are distributed under the license below.  The former are distributed  */
/*  under the LGPLv2, as in the LICENSE file.                             */
/*                                                                        */
/*                                                                        */
/*  Redistribution and use in source and binary forms, with or without    */
/*  modification, are permitted provided that the following conditions    */
/*  are met:                                                              */
/*  1. Redistributions of source code must retain the above copyright     */
/*  notice, this list of conditions and the following disclaimer.         */
/*  2. Redistributions in binary form must reproduce the above copyright  */
/*  notice, this list of conditions and the following disclaimer in the   */
/*  documentation and/or other materials provided with the distribution.  */
/*  3. The names of the authors may not be used to endorse or promote     */
/*  products derived from this software without specific prior written    */
/*  permission.                                                           */
/*                                                                        */
/*  THIS SOFTWARE IS PROVIDED BY THE AUTHORS ``AS IS'' AND ANY EXPRESS    */
/*  OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED     */
/*  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE    */
/*  ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY       */
/*  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL    */
/*  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE     */
/*  GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS         */
/*  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER  */
/*  IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR       */
/*  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN   */
/*  IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                         */
/**************************************************************************/

%{

let r = fun x -> x (* Ulib.Text.of_latin1 *)

open Parse_ast

let loc () = Range(Parsing.symbol_start_pos(),Parsing.symbol_end_pos())
let locn m n = Range(Parsing.rhs_start_pos m,Parsing.rhs_end_pos n)

let ploc p = P_aux(p,loc ())
let eloc e = E_aux(e,loc ())
let peloc pe = Pat_aux(pe,loc ())
let lbloc lb = LB_aux(lb,loc ())

let bkloc k = BK_aux(k,loc ())
let kloc k = K_aux(k,loc ())
let kiloc ki = KOpt_aux(ki,loc ())
let tloc t = ATyp_aux(t,loc ())
let lloc l = L_aux(l,loc ())
let ploc p = P_aux(p,loc ())
let fploc p = FP_aux(p,loc ())

let funclloc f = FCL_aux(f,loc ())
let typql t = TypQ_aux(t, loc())
let irloc r = BF_aux(r, loc())
let defloc df = DT_aux(df, loc())

let tdloc td = TD_aux(td, loc())
let funloc fn = FD_aux(fn, loc())
let vloc v = VS_aux(v, loc ())
let dloc d = DEF_aux(d,loc ())

let mk_typschm tq t s e = TypSchm_aux((TypSchm_ts(tq,t)),(locn s e))
let mk_rec r i = (Rec_aux((Rec_rec (r)), locn i i))
let mk_recn _ = (Rec_aux((Rec_nonrec), Unknown))
let mk_typqn _ = (TypQ_aux(TypQ_no_forall,Unknown))
let mk_tannot tq t s e = Typ_annot_opt_aux(Typ_annot_opt_some(tq,t),(locn s e))
let mk_tannotn _ = Typ_annot_opt_aux(Typ_annot_opt_none,Unknown)
let mk_eannot e i = Effects_opt_aux((Effects_opt_effects(e)),(locn i i))
let mk_eannotn _ = Effects_opt_aux(Effects_opt_pure,Unknown)
let mk_namesectn _ = Name_sect_aux(Name_sect_none,Unknown)

(*let build_fexp (Expr_l(e,_)) l =
  match e with
    | Infix(Expr_l(Ident(i), l'),SymX_l((stx,op),l''),e2) when String.compare op (r"=") = 0 ->
        Fexp(i, stx, e2, l)
    | _ ->
        raise (Parse_error_locn(l,"Invalid record field assignment (should be id = exp)"))

let mod_cap n =
  if not (Name.starts_with_upper_letter (Name.strip_lskip (Name.from_x n))) then
    raise (Parse_error_locn(Ast.xl_to_l n, "Module name must begin with an upper-case letter"))
  else
    ()*)

let space = " "
let star = "*"

(*let mk_pre_x_l sk1 (sk2,id) sk3 l =
  if (sk2 = None || sk2 = Some []) && (sk3 = None || sk3 = Some []) then
    PreX_l(sk1,(None,id),None,l)
  else if (sk2 = Some [Ws space] && 
           sk3 = Some [Ws space] && 
           (Ulib.Text.left id 1 = star ||
            Ulib.Text.right id 1 = star)) then
    PreX_l(sk1,(None,id),None,l)
  else
    raise (Parse_error_locn(l, "illegal whitespace in parenthesised infix name"))*)


%}

/*Terminals with no content*/

%token <Parse_ast.terminal> And As Bits Case Clause Const Default Effect Effects End Enum Else False 
%token <Parse_ast.terminal> Forall Function_ If_ In IN Let_ Member Nat Order Pure Rec Register  
%token <Parse_ast.terminal> Scattered Struct Switch Then True Type TYPE Typedef Union With Val

%token <Parse_ast.terminal> AND Div_ EOR Mod OR Quot Rem 

%token <Parse_ast.terminal> Bar Colon Comma Dot Eof Minus Semi Under
%token <Parse_ast.terminal> Lcurly Rcurly Lparen Rparen Lsquare Rsquare
%token <Parse_ast.terminal> BarBar BarGt BarSquare DotDot MinusGt LtBar SquareBar 

/*Terminals with content*/

%token <Parse_ast.terminal * string> Id
%token <Parse_ast.terminal * int> Num
%token <Parse_ast.terminal * string> String Bin Hex

%token <Parse_ast.terminal * string> Amp At Carrot  Div Eq Excl Gt Lt Plus Star Tilde 
%token <Parse_ast.terminal * string> AmpAmp CarrotCarrot ColonColon ColonEq EqDivEq EqEq ExclEq ExclExcl  
%token <Parse_ast.terminal * string> GtEq GtEqPlus GtGt GtGtGt GtPlus HashGtGt HashLtLt   
%token <Parse_ast.terminal * string> LtEq LtEqPlus LtGt LtLt LtLtLt LtPlus StarStar TildeCarrot

%token <Parse_ast.terminal * string> GtEqUnderS GtEqUnderSi GtEqUnderU GtEqUnderUi GtGtUnderU GtUnderS 
%token <Parse_ast.terminal * string> GtUnderSi GtUnderU GtUnderUi LtEqUnderS LtEqUnderSi LtEqUnderU 
%token <Parse_ast.terminal * string> LtEqUnderUi LtUnderS LtUnderSi LtUnderU LtUnderUi StarStarUnderS StarStarUnderSi StarUnderS 
%token <Parse_ast.terminal * string> StarUnderSi StarUnderU StarUnderUi TwoCarrot

%token <Parse_ast.terminal * string> AmpI AtI CarrotI  DivI EqI ExclI GtI LtI PlusI StarI TildeI
%token <Parse_ast.terminal * string> AmpAmpI CarrotCarrotI ColonColonI ColonEqI EqDivEqI EqEqI ExclEqI ExclExclI  
%token <Parse_ast.terminal * string> GtEqI GtEqPlusI GtGtI GtGtGtI GtPlusI HashGtGtI HashLtLtI  
%token <Parse_ast.terminal * string> LtEqI LtEqPlusI LtGtI LtLtI LtLtLtI LtPlusI StarStarI TildeCarrotI

%token <Parse_ast.terminal * string> GtEqUnderSI GtEqUnderSiI GtEqUnderUI GtEqUnderUiI GtGtUnderUI GtUnderSI 
%token <Parse_ast.terminal * string> GtUnderSiI GtUnderUI GtUnderUiI LtEqUnderSI LtEqUnderSiI LtEqUnderUI 
%token <Parse_ast.terminal * string> LtEqUnderUiI LtUnderSI LtUnderSiI LtUnderUI LtUnderUiI StarStarUnderSI StarStarUnderSiI StarUnderSI 
%token <Parse_ast.terminal * string> StarUnderSiI StarUnderUI StarUnderUiI TwoCarrotI

%start file
%type <Parse_ast.defs> defs
%type <Parse_ast.atyp> typ
%type <Parse_ast.pat> pat
%type <Parse_ast.exp> exp
%type <Parse_ast.defs * Parse_ast.terminal> file


%%

id:
  | Id
    { Id_aux(Id($1), loc ()) }
  | Lparen Eq Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen IN Rparen
    { Id_aux(DeIid($1,($2,"In"),$3),loc ()) }
  | Lparen AmpAmp Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen BarBar Rparen
    { Id_aux(DeIid($1,($2,"||"),$3),loc ()) }
  | Lparen ColonColon Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen Star Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen Plus Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen GtEq Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }
  | Lparen At Rparen
    { Id_aux(DeIid($1,$2,$3),loc ()) }

atomic_kind:
  | TYPE
    { bkloc (BK_type($1)) }
  | Nat
    { bkloc (BK_nat($1)) }
  | Order
    { bkloc (BK_order($1)) }
  | Effects
    { bkloc (BK_effects($1)) }

kind_help:
  | atomic_kind
    { [ ($1,None) ] }
  | atomic_kind MinusGt kind_help
    { ($1,$2)::$3 }

kind:
  | kind_help
    { K_aux(K_kind($1), loc ()) }

effect:
  | id
    { (match $1 with
       | Id_aux(Id(t,s),l) ->
	 Effect_aux
	   ((match s with
	   | "rreg" -> (Effect_rreg t)
	   | "wreg" -> (Effect_wreg t)
	   | "rmem" -> (Effect_rmem t)
	   | "wmem" -> (Effect_wmem t)
	   | "undef" -> (Effect_undef t)
	   | "unspec" -> (Effect_unspec t)
	   | "nondet" -> (Effect_nondet t)
	   | _ -> raise (Parse_error_locn (l,"Invalid effect"))),l)
       | _ -> raise (Parse_error_locn ((loc ()),"Invalid effect"))) }

effect_list:
  | effect
    { [($1,None)] }
  | effect Comma effect_list
    { ($1,$2)::$3 }

effect_typ:
  | Effect id
    { tloc (ATyp_efid($1,$2)) }
  | Effect Lcurly effect_list Rcurly
    { tloc (ATyp_set($1,$2,$3,$4)) }
  | Pure
    { tloc (ATyp_set($1,None,[],None)) }

atomic_typ:
  | id
    { tloc (ATyp_id $1) }
  | Num
    { tloc (ATyp_constant(fst $1, snd $1)) }
  | Under
    { tloc (ATyp_wild($1)) }
  | effect_typ
    { $1 }
  | Lparen typ Rparen
    { $2 }
  | Lsquare nexp_typ Rsquare
      { assert false }
  | Lsquare nexp_typ Colon nexp_typ Rsquare
      { assert false }

atomic_typs:
  | atomic_typ
    { [$1] }
  | atomic_typ atomic_typs
    { $1::$2 } 

app_typ:
  | atomic_typ
    { $1 }
  | id atomic_typs
    { tloc (ATyp_app($1,$2)) } 

star_typ_list:
  | app_typ
    { [($1,None)] }
  | app_typ Star star_typ_list
    { ($1,fst $2)::$3 } 

star_typ:
  | star_typ_list
    { match $1 with
        | [] -> assert false
        | [(t,None)] -> t
        | [(t,Some _)] -> assert false
        | ts -> tloc (ATyp_tup(ts)) }

exp_typ:
   | star_typ
     { $1 }
   | Num StarStar typ
     { if (2 = (snd $1))
       then tloc (ATyp_exp((fst $1),(fst $2),$3))
       else raise (Parse_error_locn(loc (), "Only 2 is a valid exponent base in Nats")) } 

nexp_typ:
   | exp_typ
     { $1 }
   | atomic_typ Plus typ
     { tloc (ATyp_sum($1,fst $2,$3)) } 

vtyp_typ:
   | star_typ
       { $1 }
   | star_typ Lsquare nexp_typ Rsquare
     { assert false }
   | star_typ Lsquare nexp_typ Colon nexp_typ Rsquare
     { assert false }

typ:
  | nexp_typ
    { $1 }
  | vtyp_typ MinusGt atomic_typ effect_typ
    { tloc (ATyp_fn($1,$2,$3,$4)) } 

lit:
  | True
    { lloc (L_true($1)) }
  | False
    { lloc (L_false($1)) }
  | Num
    { lloc (L_num(fst $1, snd $1)) }
  | String
    { lloc (L_string(fst $1, snd $1)) }
  | Lparen Rparen
    { lloc (L_unit($1,$2)) }
  | Bin
    { lloc (L_bin(fst $1, snd $1)) }
  | Hex
    { lloc (L_hex(fst $1, snd $1)) }


atomic_pat:
  | lit
    { ploc (P_lit($1)) }
  | Under
    { ploc (P_wild($1)) }
  | Lparen pat As id Rparen
    { ploc (P_as($1,$2,$3,$4,$5)) }
/* Because of ( id id ) being either application or type casts, this is inherently ambiguous */
/*  | Lparen atomic_typ pat Rparen
    { ploc (P_typ($1,$2,$3,$4)) } */
  | id
    { ploc (P_app($1,[])) } 
  | Lcurly fpats Rcurly
    { ploc (P_record($1,fst $2,fst (snd $2),snd (snd $2),$3)) }
  | Lsquare pat Rsquare
    { ploc (P_vector($1,[($2,None)],$3)) }
  | Lsquare comma_pats Rsquare
    { ploc (P_vector($1,$2,$3)) }
  | Lsquare npats Rsquare
    { ploc (P_vector_indexed($1,$2,$3)) } 
  | Lparen comma_pats Rparen
    { ploc (P_tup($1,$2,$3)) } 
  | SquareBar comma_pats BarSquare
    { ploc (P_list($1,$2,$3)) } 
  | Lparen pat Rparen
    { $2 }

app_pat:
  | atomic_pat
    { $1 }
  | id pat
    { ploc (P_app($1,[$2])) }

pat_colons:
  | atomic_pat Colon atomic_pat
    { ([($1,$2);($3,None)]) }
  | atomic_pat Colon pat_colons
    { (($1,$2)::$3) }

pat:
  | app_pat
    { $1 }
  | pat_colons
    { ploc (P_vector_concat($1)) } 

comma_pats:
  | atomic_pat Comma atomic_pat
    { [($1,$2);($3,None)] }
  | atomic_pat Comma comma_pats
    { ($1,$2)::$3 }

fpat:
  | id Eq pat
    { fploc (FP_Fpat($1,fst $2,$3)) }

fpats:
  | fpat
    { ([($1,None)], (None,false)) }
  | fpat Semi
    { ([($1,None)], ($2,true)) }
  | fpat Semi fpats
    { (($1,$2)::fst $3, snd $3) }

npat: 
  | Num Eq pat
    { ($1,fst $2,$3) }

npats:
  | npat
    { ([($1,None)]) }
  | npat Comma npats
    { (($1,$2)::$3) }

atomic_exp:
  | Lcurly semi_exps Rcurly
    { eloc (E_block($1,$2,$3)) }
  | id 
    { eloc (E_id($1)) } 
  | lit
    { eloc (E_lit($1)) }
  | Lparen exp Rparen
    { $2 }
  | Lparen comma_exps Rparen
    { eloc (E_tuple($1,$2,$3)) }
  | Lsquare comma_exps Rsquare
    { eloc (E_vector($1,$2,$3)) }
  | Lsquare exp With exp Eq exp Rsquare
    { eloc (E_vector_update($1,$2,$3,$4,fst $5,$6,$7)) }
  | Lsquare exp With exp Colon exp Eq exp Rsquare
    { eloc (E_vector_update_subrange($1,$2,$3,$4,$5,$6,fst $7,$8,$9)) }
  | SquareBar comma_exps BarSquare
    { eloc (E_list($1,$2,$3)) }
  | Switch exp Lcurly case_exps Rcurly
    { eloc (E_case($1,$2,$3,$4,$5)) }

field_exp:
  | atomic_exp
    { $1 }
  | atomic_exp Dot id
    { eloc (E_field($1,$2,$3)) }

vaccess_exp:
  | field_exp
    { $1 }
  | atomic_exp Lsquare exp Rsquare
    { eloc (E_vector_access($1,$2,$3,$4)) }
  | atomic_exp Lsquare exp DotDot exp Rsquare
    { eloc (E_vector_subrange($1,$2,$3,$4,$5,$6)) }

app_exp:
  | vaccess_exp
    { $1 }
  | id Lparen exp Rparen
    { eloc (E_app((E_aux((E_id $1),locn 1 1)),[$3])) }
  | id Lparen comma_exps Rparen
    { eloc (E_app((E_aux((E_id $1),locn 1 1)),[(E_aux((E_tuple($2,$3,$4)),locn 2 4))])) }

right_atomic_exp:
  | If_ exp Then exp Else exp
    { eloc (E_if($1,$2,$3,$4,$5,$6)) }
  | letbind In exp
    { eloc (E_let($1,$2,$3)) } 

starstar_exp:
  | app_exp
    { $1 }
  | starstar_exp StarStar app_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

starstar_right_atomic_exp:
  | right_atomic_exp
    { $1 }
  | starstar_exp StarStar right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

star_exp:
  | starstar_exp
    { $1 }
  | star_exp Star starstar_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

star_right_atomic_exp:
  | starstar_right_atomic_exp
    { $1 }
  | star_exp Star starstar_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

plus_exp:
  | star_exp
    { $1 }
  | plus_exp Plus star_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

plus_right_atomic_exp:
  | star_right_atomic_exp
    { $1 }
  | plus_exp Plus star_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

cons_exp:
  | plus_exp
    { $1 }
  | plus_exp ColonColon cons_exp
    { eloc (E_cons($1,fst $2,$3)) }

cons_right_atomic_exp:
  | plus_right_atomic_exp
    { $1 }
  | plus_exp ColonColon cons_right_atomic_exp
    { eloc (E_cons($1,fst $2,$3)) }

at_exp:
  | cons_exp
    { $1 }
  | cons_exp At at_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

at_right_atomic_exp:
  | cons_right_atomic_exp
    { $1 }
  | cons_exp At at_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

eq_exp:
  | at_exp
    { $1 }
  /* Adds one shift/reduce conflict */
  | eq_exp Eq at_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }
  | eq_exp GtEq at_exp
    { eloc (E_app_infix ($1,Id_aux(Id($2), locn 2 2), $3)) }
  | eq_exp IN at_exp
    { eloc (E_app_infix($1,Id_aux(Id(($2,"In")), locn 2 2), $3)) }
  | eq_exp ColonEq at_exp
    { eloc (E_assign($1,fst $2,$3)) }

eq_right_atomic_exp:
  | at_right_atomic_exp
    { $1 }
  | eq_exp Eq at_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }
  | eq_exp ColonEq at_right_atomic_exp 
    { eloc (E_assign($1,fst $2,$3)) }

and_exp:
  | eq_exp
    { $1 }
  | eq_exp AmpAmp and_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

and_right_atomic_exp:
  | eq_right_atomic_exp
    { $1 }
  | eq_exp AmpAmp and_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id($2), locn 2 2), $3)) }

or_exp:
  | and_exp
    { $1 }
  | and_exp BarBar or_exp
    { eloc (E_app_infix($1,Id_aux(Id(($2,"||")), locn 2 2), $3)) }


or_right_atomic_exp:
  | and_right_atomic_exp
    { $1 }
  | and_exp BarBar or_right_atomic_exp
    { eloc (E_app_infix($1,Id_aux(Id(($2,"||")), locn 2 2), $3)) }

exp:
  | or_exp
    { $1 } 
  | or_right_atomic_exp
    { $1 }


comma_exps:
  | exp Comma exp
    { [($1,$2);($3,None)] }
  | exp Comma comma_exps
    { ($1,$2)::$3 }
 
semi_exps_help:
  | exp
    { [($1,None)] }
  | exp Semi
    { [($1,$2)] }
  | exp Semi semi_exps_help
    { ($1,$2)::$3 }

semi_exps:
  |
    { [] }
  | semi_exps_help
    { $1 }

case_exp:
  | Case patsexp
    { ($1,$2) }

case_exps:
  | case_exp
    { [$1] }
  | case_exp case_exps
    { $1::$2 }

patsexp:
  | atomic_pat MinusGt exp
    { peloc (Pat_exp($1,$2,$3)) }

letbind:
  | Let_ atomic_pat Eq exp
    { lbloc (LB_val_implicit($1,$2,fst $3,$4)) }
  | Let_ typquant atomic_typ atomic_pat Eq exp
    { lbloc (LB_val_explicit((mk_typschm $2 $3 2 3),$4,fst $5,$6)) }
  /* This is ambiguous causing 4 shift/reduce and 5 reduce/reduce conflicts because the parser can't tell until the end of typ whether it was parsing a type or a pattern, and this seem to be too late. Solutions are to have a different keyword for this and the above solution besides let (while still absolutely having a keyword here) 
  | Let_ atomic_typ atomic_pat Eq exp
    { } */

funcl: 
  | id atomic_pat Eq exp
    { funclloc (FCL_Funcl($1,$2,fst $3,$4)) }

funcl_ands:
  | funcl
    { [$1,None] }
  | funcl And funcl_ands
    { ($1,$2)::$3 }

fun_def:
  | Function_ Rec typquant atomic_typ effect_typ funcl_ands
    { funloc (FD_function($1,mk_rec $2 2, mk_tannot $3 $4 3 4, mk_eannot $5 5, $6)) }
  | Function_ Rec typquant atomic_typ funcl_ands
    { funloc (FD_function($1,mk_rec $2 2, mk_tannot $3 $4 3 4, mk_eannotn (), $5)) }  
  | Function_ Rec atomic_typ effect_typ funcl_ands
    { funloc (FD_function($1,mk_rec $2 2, mk_tannot (mk_typqn ()) $3 3 3, mk_eannot $4 4, $5)) }
  | Function_ Rec atomic_typ funcl_ands
    { match $3 with
      | ATyp_aux(ATyp_efid _, _) | ATyp_aux(ATyp_set _, _) -> 
        funloc (FD_function($1,mk_rec $2 2,mk_tannotn (), mk_eannot $3 3, $4))
      | _ -> 
        funloc (FD_function($1,mk_rec $2 2,mk_tannot (mk_typqn ()) $3 3 3, mk_eannotn (), $4)) }
  | Function_ Rec funcl_ands
    { funloc (FD_function($1,mk_rec $2 2, mk_tannotn (), mk_eannotn (), $3)) }
  | Function_ typquant atomic_typ effect_typ funcl_ands
    { funloc (FD_function($1,mk_recn (), mk_tannot $2 $3 2 3, mk_eannot $4 4, $5)) }
  | Function_ typquant atomic_typ funcl_ands
    { funloc (FD_function($1,mk_recn (), mk_tannot $2 $3 2 2, mk_eannotn (), $4)) }  
  | Function_ atomic_typ funcl_ands
    { match $2 with
      | ATyp_aux(ATyp_efid _, _) | ATyp_aux(ATyp_set _, _) -> 
        funloc (FD_function($1,mk_recn (),mk_tannotn (), mk_eannot $2 2, $3))
      | _ -> 
        funloc (FD_function($1,mk_recn (),mk_tannot (mk_typqn ()) $2 2 2, mk_eannotn (), $3)) }
  | Function_ funcl_ands
    { funloc (FD_function($1,mk_recn (), mk_tannotn (), mk_eannotn (), $2)) }


val_spec:
  | Val typquant atomic_typ id
    { vloc (VS_val_spec($1,mk_typschm $2 $3 2 3,$4)) }
  | Val atomic_typ id
    { vloc (VS_val_spec($1,mk_typschm (mk_typqn ()) $2 2 2,$3)) }

kinded_id:
  | id
    { kiloc (KOpt_none $1) }
  | kind id
    { kiloc (KOpt_kind($1,$2))}
  | Lparen kinded_id Rparen
    { $2 }

kinded_ids:
  | kinded_id
    { [$1] }
  | kinded_id kinded_ids
    { $1::$2 }

nums:
  | Num
    { [($1,None)] }
  | Num Comma nums
    { ($1,$2)::$3 }

nexp_constraint:
  | typ Eq typ
    { NC_aux(NC_fixed($1,(fst $2),$3), loc () ) }
  | typ GtEq typ
    { NC_aux(NC_bounded_ge($1,(fst $2),$3), loc () ) }
  | typ LtEq typ
    { NC_aux(NC_bounded_le($1,(fst $2),$3), loc () ) }
  | id IN Lcurly nums Rcurly
    { NC_aux(NC_nat_set_bounded($1,$2,$3,$4,$5), loc ()) } 
    
nexp_constraints:
  | nexp_constraint
    { [($1,None)] }
  | nexp_constraint Comma nexp_constraints 
    { ($1,$2)::$3 }

typquant:
  /* This is a syntactic change to avoid 6 significant shift/reduce conflicts in the Dot */
  | Forall kinded_ids Amp nexp_constraints Dot
    { typql(TypQ_tq($1,$2,fst $3,$4,$5)) }
  | Forall kinded_ids Dot
    { typql(TypQ_no_constraint($1,$2,$3)) }

name_sect:
  | Lsquare Id Eq String Rsquare
    { Name_sect_aux(Name_sect_some($1,(fst $2),fst $3,(fst $4),(snd $4),$5), loc ()) }

c_def_body:
  | typ id
    { [(($1,$2),None)],(None,false) }
  | typ id Semi
    { [(($1,$2),None)],($3,true) }
  | typ id Semi c_def_body
    { (($1,$2),$3)::(fst $4), snd $4 } 

index_range_atomic:
  | Num
    { irloc (BF_single($1)) }
  | Num DotDot Num
    { irloc (BF_range($1,$2,$3)) }
  | Lparen index_range Rparen
    { $2 }

index_range:
  | index_range_atomic
    { $1 }
  | index_range_atomic Comma index_range
    { irloc(BF_concat($1,$2,$3)) } 

r_id_def:
  | index_range Colon id
    { $1,$2,$3 }

r_def_body:
  | r_id_def
    { [($1,None)] }
  | r_id_def Semi
    { [$1,$2] }
  | r_id_def Semi r_def_body
    { ($1,$2)::$3 }

type_def:
  | Typedef id name_sect Eq typquant typ
    { tdloc (TD_abbrev($1,$2,$3,fst $4,mk_typschm $5 $6 5 6)) }
  | Typedef id name_sect Eq typ
    { tdloc (TD_abbrev($1,$2,$3,fst $4,mk_typschm (mk_typqn ()) $5 5 5)) }
  | Typedef id Eq typquant typ
    { tdloc (TD_abbrev($1,$2,mk_namesectn (),fst $3, mk_typschm $4 $5 4 5))}
  | Typedef id Eq typ
    { tdloc (TD_abbrev($1,$2,mk_namesectn (),fst $3,mk_typschm (mk_typqn ()) $4 4 4)) }
  /* The below adds 4 shift/reduce conflicts. Unclear why */
  | Typedef id name_sect Eq Const Struct typquant Lcurly c_def_body Rcurly
    { tdloc (TD_record($1,$2,$3,fst $4,$5,$6,$7,$8,fst $9, fst (snd $9), snd (snd $9), $10)) }
  | Typedef id name_sect Eq Const Struct Lcurly c_def_body Rcurly
    { tdloc (TD_record($1,$2,$3,fst $4,$5,$6,(mk_typqn ()), $7, fst $8, fst (snd $8), snd (snd $8), $9)) }
  | Typedef id Eq Const Struct typquant Lcurly c_def_body Rcurly
    { tdloc (TD_record($1,$2,mk_namesectn (), fst $3, $4, $5, $6, $7, fst $8, fst (snd $8), snd (snd $8), $9)) }
  | Typedef id Eq Const Struct Lcurly c_def_body Rcurly
    { tdloc (TD_record($1,$2, mk_namesectn (), fst $3, $4, $5, mk_typqn (), $6, fst $7, fst (snd $7), snd (snd $7), $8)) }
  | Typedef id name_sect Eq Const Union typquant Lcurly c_def_body Rcurly
    { tdloc (TD_variant($1,$2,$3,fst $4, $5, $6, $7, $8, fst $9, fst (snd $9), snd (snd $9), $10)) }
  | Typedef id Eq Const Union typquant Lcurly c_def_body Rcurly
    { tdloc (TD_variant($1,$2,mk_namesectn (), fst $3, $4, $5, $6, $7, fst $8, fst (snd $8), snd (snd $8), $9)) }
  | Typedef id name_sect Eq Const Union Lcurly c_def_body Rcurly
    { tdloc (TD_variant($1, $2, $3, fst $4, $5, $6, mk_typqn (), $7, fst $8, fst (snd $8), snd (snd $8), $9)) }
  | Typedef id Eq Const Union Lcurly c_def_body Rcurly
    { tdloc (TD_variant($1,$2, mk_namesectn (), fst $3, $4, $5, mk_typqn (), $6, fst $7, fst (snd $7), snd (snd $7), $8)) }
  | Typedef id Eq Register Bits Lsquare typ Colon typ Rsquare Lcurly r_def_body Rcurly
    { tdloc (TD_register($1,$2,fst $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)) }


default_typ:
  | Default atomic_kind id
    { defloc (DT_kind($1,$2,$3)) } 
  | Default typquant atomic_typ id
    { defloc (DT_typ($1,(mk_typschm $2 $3 2 3),$4)) }
  | Default atomic_typ id
    { defloc (DT_typ($1,(mk_typschm (mk_typqn ()) $2 2 2),$3)) }
 
scattered_def:
  | Function_ Rec typquant atomic_typ effect_typ id
    { (DEF_scattered_function(None,$1,mk_rec $2 2, mk_tannot $3 $4 3 4, mk_eannot $5 5, $6)) }
  | Function_ Rec atomic_typ effect_typ id
    { (DEF_scattered_function(None,$1,mk_rec $2 2, mk_tannot (mk_typqn ()) $3 3 3, mk_eannot $4 4, $5)) }
  | Function_ Rec typquant atomic_typ id
    { (DEF_scattered_function(None,$1,mk_rec $2 2, mk_tannot $3 $4 3 4, mk_eannotn (), $5)) }
  | Function_ Rec atomic_typ id
    { match $3 with
      | (ATyp_aux(ATyp_efid _, _)) | (ATyp_aux(ATyp_set _, _)) -> 
        (DEF_scattered_function(None,$1,mk_rec $2 2, mk_tannotn (), mk_eannot $3 3, $4))
      | _ ->
        (DEF_scattered_function(None,$1,mk_rec $2 2,mk_tannot (mk_typqn ()) $3 3 3, mk_eannotn (), $4)) }
  | Function_ Rec id
    { (DEF_scattered_function(None,$1,mk_rec $2 2,mk_tannotn (), mk_eannotn (),$3)) }
  | Function_ typquant atomic_typ effect_typ id
    { (DEF_scattered_function(None,$1,mk_recn (),mk_tannot $2 $3 2 3, mk_eannot $4 4, $5)) }
  | Function_ atomic_typ effect_typ id
    { (DEF_scattered_function(None,$1,mk_recn (), mk_tannot (mk_typqn ()) $2 2 2, mk_eannot $3 3, $4)) }
  | Function_ typquant atomic_typ id
    { (DEF_scattered_function(None,$1,mk_recn (), mk_tannot $2 $3 2 3, mk_eannotn (), $4)) }
  | Function_ atomic_typ id
    { match $2 with
      | (ATyp_aux(ATyp_efid _, _)) | (ATyp_aux(ATyp_set _, _)) -> 
        (DEF_scattered_function(None,$1,mk_recn (), mk_tannotn (), mk_eannot $2 2, $3))
      | _ ->
        (DEF_scattered_function(None,$1,mk_recn (), mk_tannot (mk_typqn ()) $2 2 2, mk_eannotn (), $3)) }
  | Function_ id
    { (DEF_scattered_function(None,$1,mk_recn (), mk_tannotn (), mk_eannotn (), $2)) }
  | Typedef id name_sect Eq Const Union typquant
    { (DEF_scattered_variant(None,$1,$2,$3,fst $4,$5,$6,$7)) }
  | Typedef id Eq Const Union typquant
    { (DEF_scattered_variant(None,$1,$2,(mk_namesectn ()),fst $3,$4,$5,$6)) }
  | Typedef id name_sect Eq Const Union
    { (DEF_scattered_variant(None,$1,$2,$3,fst $4,$5,$6,mk_typqn ())) }
  | Typedef id Eq Const Union
    { (DEF_scattered_variant(None,$1,$2,mk_namesectn (),fst $3,$4,$5,mk_typqn ())) }

def:
  | type_def
    { dloc (DEF_type($1)) }
  | fun_def
    { dloc (DEF_fundef($1)) }
  | letbind
    { dloc (DEF_val($1)) }
  | val_spec
    { dloc (DEF_spec($1)) }
  | default_typ 
    { dloc (DEF_default($1)) }
  | Register atomic_typ id
    { dloc (DEF_reg_dec($1,$2,$3)) }
  | Scattered scattered_def
    { dloc (match ($2) with
            | DEF_scattered_function(_,f,r,t,e,i) -> DEF_scattered_function($1,f,r,t,e,i)
            | DEF_scattered_variant(_,t,i,n,e,c,u,ty) -> DEF_scattered_variant($1,t,i,n,e,c,u,ty)
            | _ -> assert false) }
  | Function_ Clause funcl
    { dloc (DEF_scattered_funcl($1,$2,$3)) }
  | Union id Member atomic_typ id
    { dloc (DEF_scattered_unioncl($1,$2,$3,$4,$5)) }
  | End id 
    { dloc (DEF_scattered_end($1,$2)) }

defs_help:
  | def
    { [$1] }
  | def defs_help
    { $1::$2 }

defs:
  | defs_help
    { (Defs $1) }

file:
  | defs Eof
    { ($1,$2) }

