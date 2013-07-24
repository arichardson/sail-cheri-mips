(* generated by Ott 0.22 from: l2_parse.ott *)


type text = string

type l =
  | Unknown
  | Trans of string * l option
  | Range of Lexing.position * Lexing.position

type 'a annot = l * 'a

exception Parse_error_locn of l * string

type ml_comment = 
  | Chars of string
  | Comment of ml_comment list

type lex_skip =
  | Com of ml_comment
  | Ws of string
  | Nl

type lex_skips = lex_skip list option

let pp_lex_skips ppf sk = 
  match sk with
    | None -> ()
    | Some(sks) ->
        List.iter
          (fun sk ->
             match sk with
               | Com(ml_comment) ->
                   (* TODO: fix? *)
                   Format.fprintf ppf "(**)"
               | Ws(r) ->
                   Format.fprintf ppf "%s" r (*(Ulib.Text.to_string r)*)
               | Nl -> Format.fprintf ppf "\\n")
          sks

let combine_lex_skips s1 s2 =
  match (s1,s2) with
    | (None,_) -> s2
    | (_,None) -> s1
    | (Some(s1),Some(s2)) -> Some(s2@s1)

type terminal = lex_skips


type x = terminal * text (* identifier *)
type ix = terminal * text (* infix identifier *)

type 
base_kind_aux =  (* base kind *)
   BK_type of terminal (* kind of types *)
 | BK_nat of terminal (* kind of natural number size expressions *)
 | BK_order of terminal (* kind of vector order specifications *)
 | BK_effects of terminal (* kind of effect sets *)


type 
efct_aux =  (* effect *)
   Effect_rreg of terminal (* read register *)
 | Effect_wreg of terminal (* write register *)
 | Effect_rmem of terminal (* read memory *)
 | Effect_wmem of terminal (* write memory *)
 | Effect_undef of terminal (* undefined-instruction exception *)
 | Effect_unspec of terminal (* unspecified values *)
 | Effect_nondet of terminal (* nondeterminism from intra-instruction parallelism *)


type 
id_aux =  (* Identifier *)
   Id of x
 | DeIid of terminal * x * terminal (* remove infix status *)


type 
base_kind = 
   BK_aux of base_kind_aux * l


type 
efct = 
   Effect_aux of efct_aux * l


type 
id = 
   Id_aux of id_aux * l


type 
kind_aux =  (* kinds *)
   K_kind of (base_kind * terminal) list


type 
atyp_aux =  (* expression of all kinds *)
   ATyp_id of id (* identifier *)
 | ATyp_constant of (terminal * int) (* constant *)
 | ATyp_times of atyp * terminal * atyp (* product *)
 | ATyp_sum of atyp * terminal * atyp (* sum *)
 | ATyp_exp of terminal * terminal * atyp (* exponential *)
 | ATyp_inc of terminal (* increasing (little-endian) *)
 | ATyp_dec of terminal (* decreasing (big-endian) *)
 | ATyp_efid of terminal * id
 | ATyp_set of terminal * terminal * (efct * terminal) list * terminal (* effect set *)
 | ATyp_wild of terminal (* Unspecified type *)
 | ATyp_fn of atyp * terminal * atyp * atyp (* Function type (first-order only in user code) *)
 | ATyp_tup of (atyp * terminal) list (* Tuple type *)
 | ATyp_app of id * (atyp) list (* type constructor application *)

and atyp = 
   ATyp_aux of atyp_aux * l


type 
kind = 
   K_aux of kind_aux * l


type 
nexp_constraint_aux =  (* constraint over kind $_$ *)
   NC_fixed of atyp * terminal * atyp
 | NC_bounded_ge of atyp * terminal * atyp
 | NC_bounded_le of atyp * terminal * atyp
 | NC_nat_set_bounded of id * terminal * terminal * ((terminal * int) * terminal) list * terminal


type 
kinded_id_aux =  (* optionally kind-annotated identifier *)
   KOpt_none of id (* identifier *)
 | KOpt_kind of kind * id (* kind-annotated variable *)


type 
nexp_constraint = 
   NC_aux of nexp_constraint_aux * l


type 
kinded_id = 
   KOpt_aux of kinded_id_aux * l


type 
typquant_aux =  (* type quantifiers and constraints *)
   TypQ_tq of terminal * (kinded_id) list * terminal * (nexp_constraint * terminal) list * terminal
 | TypQ_no_constraint of terminal * (kinded_id) list * terminal (* sugar, omitting constraints *)
 | TypQ_no_forall (* sugar, omitting quantifier and constraints *)


type 
lit_aux =  (* Literal constant *)
   L_unit of terminal * terminal (* $() : _$ *)
 | L_zero of terminal (* $_ : _$ *)
 | L_one of terminal (* $_ : _$ *)
 | L_true of terminal (* $_ : _$ *)
 | L_false of terminal (* $_ : _$ *)
 | L_num of (terminal * int) (* natural number constant *)
 | L_hex of terminal * string (* bit vector constant, C-style *)
 | L_bin of terminal * string (* bit vector constant, C-style *)
 | L_string of terminal * string (* string constant *)


type 
typquant = 
   TypQ_aux of typquant_aux * l


type 
lit = 
   L_aux of lit_aux * l


type 
typschm_aux =  (* type scheme *)
   TypSchm_ts of typquant * atyp


type 
pat_aux =  (* Pattern *)
   P_lit of lit (* literal constant pattern *)
 | P_wild of terminal (* wildcard *)
 | P_as of terminal * pat * terminal * id * terminal (* named pattern *)
 | P_typ of terminal * atyp * pat * terminal (* typed pattern *)
 | P_id of id (* identifier *)
 | P_app of id * (pat) list (* union constructor pattern *)
 | P_record of terminal * (fpat * terminal) list * terminal * bool * terminal (* struct pattern *)
 | P_vector of terminal * (pat * terminal) list * terminal (* vector pattern *)
 | P_vector_indexed of terminal * (((terminal * int) * terminal * pat) * terminal) list * terminal (* vector pattern (with explicit indices) *)
 | P_vector_concat of (pat * terminal) list (* concatenated vector pattern *)
 | P_tup of terminal * (pat * terminal) list * terminal (* tuple pattern *)
 | P_list of terminal * (pat * terminal) list * terminal (* list pattern *)

and pat = 
   P_aux of pat_aux * l

and fpat_aux =  (* Field pattern *)
   FP_Fpat of id * terminal * pat

and fpat = 
   FP_aux of fpat_aux * l


type 
typschm = 
   TypSchm_aux of typschm_aux * l


type 
exp_aux =  (* Expression *)
   E_block of terminal * (exp * terminal) list * terminal (* block (parsing conflict with structs?) *)
 | E_id of id (* identifier *)
 | E_lit of lit (* literal constant *)
 | E_cast of terminal * atyp * terminal * exp (* cast *)
 | E_app of exp * (exp) list (* function application *)
 | E_app_infix of exp * id * exp (* infix function application *)
 | E_tuple of terminal * (exp * terminal) list * terminal (* tuple *)
 | E_if of terminal * exp * terminal * exp * terminal * exp (* conditional *)
 | E_vector of terminal * (exp * terminal) list * terminal (* vector (indexed from 0) *)
 | E_vector_indexed of terminal * (((terminal * int) * terminal * exp) * terminal) list * terminal (* vector (indexed consecutively) *)
 | E_vector_access of exp * terminal * exp * terminal (* vector access *)
 | E_vector_subrange of exp * terminal * exp * terminal * exp * terminal (* subvector extraction *)
 | E_vector_update of terminal * exp * terminal * exp * terminal * exp * terminal (* vector functional update *)
 | E_vector_update_subrange of terminal * exp * terminal * exp * terminal * exp * terminal * exp * terminal (* vector subrange update (with vector) *)
 | E_list of terminal * (exp * terminal) list * terminal (* list *)
 | E_cons of exp * terminal * exp (* cons *)
 | E_record of terminal * fexps * terminal (* struct *)
 | E_record_update of terminal * exp * terminal * fexps * terminal (* functional update of struct *)
 | E_field of exp * terminal * id (* field projection from struct *)
 | E_case of terminal * exp * terminal * ((terminal * pexp)) list * terminal (* pattern matching *)
 | E_let of letbind * terminal * exp (* let expression *)
 | E_assign of exp * terminal * exp (* imperative assignment *)

and exp = 
   E_aux of exp_aux * l

and fexp_aux =  (* Field-expression *)
   FE_Fexp of id * terminal * exp

and fexp = 
   FE_aux of fexp_aux * l

and fexps_aux =  (* Field-expression list *)
   FES_Fexps of (fexp * terminal) list * terminal * bool

and fexps = 
   FES_aux of fexps_aux * l

and pexp_aux =  (* Pattern match *)
   Pat_exp of pat * terminal * exp

and pexp = 
   Pat_aux of pexp_aux * l

and letbind_aux =  (* Let binding *)
   LB_val_explicit of typschm * pat * terminal * exp (* value binding, explicit type (pat must be total) *)
 | LB_val_implicit of terminal * pat * terminal * exp (* value binding, implicit type (pat must be total) *)

and letbind = 
   LB_aux of letbind_aux * l


type 
naming_scheme_opt_aux =  (* Optional variable-naming-scheme specification for variables of defined type *)
   Name_sect_none
 | Name_sect_some of terminal * terminal * terminal * terminal * string * terminal


type 
rec_opt_aux =  (* Optional recursive annotation for functions *)
   Rec_nonrec (* non-recursive *)
 | Rec_rec of terminal (* recursive *)


type 
tannot_opt_aux =  (* Optional type annotation for functions *)
   Typ_annot_opt_none
 | Typ_annot_opt_some of typquant * atyp


type 
funcl_aux =  (* Function clause *)
   FCL_Funcl of id * pat * terminal * exp


type 
effects_opt_aux =  (* Optional effect annotation for functions *)
   Effects_opt_pure (* sugar for empty effect set *)
 | Effects_opt_effects of atyp


type 
index_range_aux =  (* index specification, for bitfields in register types *)
   BF_single of (terminal * int) (* single index *)
 | BF_range of (terminal * int) * terminal * (terminal * int) (* index range *)
 | BF_concat of index_range * terminal * index_range (* concatenation of index ranges *)

and index_range = 
   BF_aux of index_range_aux * l


type 
naming_scheme_opt = 
   Name_sect_aux of naming_scheme_opt_aux * l


type 
rec_opt = 
   Rec_aux of rec_opt_aux * l


type 
tannot_opt = 
   Typ_annot_opt_aux of tannot_opt_aux * l


type 
funcl = 
   FCL_aux of funcl_aux * l


type 
effects_opt = 
   Effects_opt_aux of effects_opt_aux * l


type 
default_typing_spec_aux =  (* Default kinding or typing assumption *)
   DT_kind of terminal * base_kind * id
 | DT_typ of terminal * typschm * id


type 
type_def_aux =  (* Type definition body *)
   TD_abbrev of terminal * id * naming_scheme_opt * terminal * typschm (* type abbreviation *)
 | TD_record of terminal * id * naming_scheme_opt * terminal * terminal * terminal * typquant * terminal * ((atyp * id) * terminal) list * terminal * bool * terminal (* struct type definition *)
 | TD_variant of terminal * id * naming_scheme_opt * terminal * terminal * terminal * typquant * terminal * ((atyp * id) * terminal) list * terminal * bool * terminal (* union type definition *)
 | TD_enum of terminal * id * naming_scheme_opt * terminal * terminal * terminal * (id * terminal) list * terminal * bool * terminal (* enumeration type definition *)
 | TD_register of terminal * id * terminal * terminal * terminal * terminal * atyp * terminal * atyp * terminal * terminal * ((index_range * terminal * id) * terminal) list * terminal (* register mutable bitfield type definition *)


type 
val_spec_aux =  (* Value type specification *)
   VS_val_spec of terminal * typschm * id


type 
fundef_aux =  (* Function definition *)
   FD_function of terminal * rec_opt * tannot_opt * effects_opt * (funcl * terminal) list


type 
default_typing_spec = 
   DT_aux of default_typing_spec_aux * l


type 
type_def = 
   TD_aux of type_def_aux * l


type 
val_spec = 
   VS_aux of val_spec_aux * l


type 
fundef = 
   FD_aux of fundef_aux * l


type 
def_aux =  (* Top-level definition *)
   DEF_type of type_def (* type definition *)
 | DEF_fundef of fundef (* function definition *)
 | DEF_val of letbind (* value definition *)
 | DEF_spec of val_spec (* top-level type constraint *)
 | DEF_default of default_typing_spec (* default kind and type assumptions *)
 | DEF_reg_dec of terminal * atyp * id (* register declaration *)
 | DEF_scattered_function of terminal * terminal * rec_opt * tannot_opt * effects_opt * id (* scattered function definition header *)
 | DEF_scattered_funcl of terminal * terminal * funcl (* scattered function definition clause *)
 | DEF_scattered_variant of terminal * terminal * id * naming_scheme_opt * terminal * terminal * terminal * typquant (* scattered union definition header *)
 | DEF_scattered_unioncl of terminal * id * terminal * atyp * id (* scattered union definition member *)
 | DEF_scattered_end of terminal * id (* scattered definition end *)


type 
def = 
   DEF_aux of def_aux * l


type 
typ_lib_aux =  (* library types and syntactic sugar for them *)
   Typ_lib_unit of terminal (* unit type with value $()$ *)
 | Typ_lib_bool of terminal (* booleans $_$ and $_$ *)
 | Typ_lib_bit of terminal (* pure bit values (not mutable bits) *)
 | Typ_lib_nat of terminal (* natural numbers 0,1,2,... *)
 | Typ_lib_string of terminal * string (* UTF8 strings *)
 | Typ_lib_enum of terminal * terminal * terminal * terminal (* natural numbers _ .. _+_-1, ordered by order *)
 | Typ_lib_enum1 of terminal * terminal * terminal (* sugar for \texttt{enum nexp 0 inc} *)
 | Typ_lib_enum2 of terminal * terminal * terminal * terminal * terminal (* sugar for \texttt{enum (nexp'-nexp+1) nexp inc} or \texttt{enum (nexp-nexp'+1) nexp' dec} *)
 | Typ_lib_vector of terminal * terminal * terminal * terminal * atyp (* vector of atyp, indexed by natural range *)
 | Typ_lib_vector2 of atyp * terminal * terminal * terminal (* sugar for vector indexed by [ atyp ] *)
 | Typ_lib_vector3 of atyp * terminal * terminal * terminal * terminal * terminal (* sugar for vector indexed by [ atyp.._ ] *)
 | Typ_lib_list of terminal * atyp (* list of atyp *)
 | Typ_lib_set of terminal * atyp (* finite set of atyp *)
 | Typ_lib_reg of terminal * atyp (* mutable register components holding atyp *)


type 
ctor_def_aux =  (* Datatype constructor definition clause *)
   CT_ct of id * terminal * typschm


type 
lexp_aux =  (* lvalue expression *)
   LEXP_id of id (* identifier *)
 | LEXP_vector of lexp * terminal * exp * terminal (* vector element *)
 | LEXP_vector_range of lexp * terminal * exp * terminal * exp * terminal (* subvector *)
 | LEXP_field of lexp * terminal * id (* struct field *)

and lexp = 
   LEXP_aux of lexp_aux * l


type 
defs =  (* Definition sequence *)
   Defs of (def) list


type 
typ_lib = 
   Typ_lib_aux of typ_lib_aux * l


type 
ctor_def = 
   CT_aux of ctor_def_aux * l



