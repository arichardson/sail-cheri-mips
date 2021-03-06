open Sail_lib
module BI = Nat_big_num

let bits_of_string n s =
  Sail_lib.to_bits (Z.of_int n, Z.of_string s)

let gen_sailbits n =
  QCheck.Gen.(list_repeat n (map Sail_lib.bit_of_bool bool))

(* Generate bitvectors of n bits biased towards smaller values *)
let gen_sailbits_geom n s =
  let zeros = Random.State.int s (n-1) in
  let lowerBits = gen_sailbits (n - zeros) s in
  Sail_lib.zeros (BI.of_int zeros) @ lowerBits

(* Generate bitvectors of n bits biased towards smaller signed values *)
let gen_sailbits_geom_signed n s =
  let leadingBit = if Random.State.bool s then B0 else B1 in
  let nLeading = Random.State.int s (n-1) in
  let leadingBits =  replicate_bits ([leadingBit], BI.of_int nLeading) in
  let lowerBits = gen_sailbits (n - nLeading) s in
  leadingBits @ lowerBits
  
let arbitrary_cap_bits = QCheck.make ~print:Sail_lib.string_of_bits (gen_sailbits 128)

let test_cap_decode_encode capbits =
  Sail_lib.eq_list (Cheri_cc.zcapToBits (Cheri_cc.zcapBitsToCapability (true, capbits)), capbits)

(* Test whether an arbitrary bit pattern results in top >= base when 
   decoded. This isn't really a requirement but is interesting as an
   inidcation of encoding efficiency. We known that large E can result
   in base > top but this isn't an issue in practice. *)
let test_get_length capbits =
  let c = Cheri_cc.zcapBitsToCapability (true, capbits) in
  let (base, top) = Cheri_cc.zgetCapBounds(c) in
  let e = Nat_big_num.to_int (Sail_lib.uint (c.zE)) in
  let passed = (e >= 51) || Nat_big_num.less_equal base top in
  begin
  if not passed then
    begin
      print_endline "Failure:";
      print_endline (Cheri_cc.string_of_zCapability(c));
      print_endline ("base " ^ (Z.format "x" base) ^ " top " ^ (Z.format "x" top));
    end;
  passed
  end

(* XXX this never generates 2^64 for tops... *) 
let gen_bounds =
  QCheck.Gen.(list_repeat 4 (gen_sailbits_geom 64))

(* Examples that triggered bugs during development of setBounds. They contain some edge
   cases like requiring rounding up e by one (at least for MW=23). *)
let bounds_regressions = List.map (List.map (fun x -> Sail_lib.to_bits' (64, Z.of_string x))) [
["0xFFFFFFFFFFFFFFFF"; "0xFFFFFFFFFFFFFFFF"; "0xFFFFFFFFFFFFFFFF"; "0x10000000000000000"];
["0x000000000000012F"; "0x247BCD4E1DF154E6"; "0x0000000000000087"; "0x000000000000000E"];
["0x00000000000000C7"; "0x8402D27397759FE2"; "0xEA65A156E6403E7A"; "0xF648C25D993C2D01"];
["0x000000000086D6A0"; "0x000000000000004B"; "0x000000007CF18F9B"; "0x000000000006D6A8"];
["0x00000712B609C5B0"; "0x00000000032DC20F"; "0x00000008032D1C77"; "0x0000000000000007"];
["0x0B87DF010D7254BB"; "0x00000800085F0270"; "0x000000000900A7CA"; "0x00000000000049FE"];
["0x0080018A6ACD2D6C"; "0x0000BEDAF8F73C0F"; "0x000001991A6FD045"; "0x004D37033A19B295"];
["0x0000003FFFF8EDC8"; "0x0000000000032796"; "0x000000902DCEEE9C"; "0x0000000000003D0E"];
["0x000000000006cdf7"; "0x0000000000214459"; "0x0000000000086940"; "0x1fffff5b88378ec7"];
["0x0010D700C6318A88"; "0x383264C38950ADB7"; "0x00000D5EBA967A84"; "0x0000000002FFFFCE"];
  ]

let print_bounds = QCheck.Print.list Sail_lib.string_of_bits
let arbitrary_bounds = QCheck.make ~print:print_bounds (QCheck.Gen.graft_corners gen_bounds bounds_regressions ())

(* Round trip Capability through bits. This is an important step in some
   tests because the expanded Capability can represent some things that
   bits can't and we probably want to ensure that we are only generating 
   values in normal form (that can be represented as bits).
   XXX maybe we could eliminate the non-normal values from type *)
let cap_encode_decode  (c : Cheri_cc.zCapability)  =
  let cbits = Cheri_cc.zcapToBits c in
  let c2 = Cheri_cc.zcapBitsToCapability (c.ztag, cbits) in
  begin
    if c <> c2 then
      begin
        print_endline "Cap changed by bits round trip:";
        print_endline (Cheri_cc.string_of_zCapability c);
        print_endline (Cheri_cc.string_of_zCapability c2);
        assert false;
      end
    else
      c2
  end

let test_setBounds bounds =
  (* pair each bit list with Big_int for easy comparison etc. *)
  let zippedBounds = List.combine bounds (List.map Sail_lib.uint bounds) in
  let sortedBounds = List.sort (fun (_, a) (_, b) -> BI.compare a b) zippedBounds in
  (* Now we have two nested pairs of bounds, first ones looser then second: *)
  let [base1; base2; top2; top1] = sortedBounds in
  (* Now try setCapBounds on the two bounds in turn *)
  let (exact1, cap1) = Cheri_cc.zsetCapBounds(Cheri_cc.zdefault_cap, fst(base1), B0::(fst(top1))) in
  let (exact2, cap2) = Cheri_cc.zsetCapBounds(cap1, fst(base2), B0::(fst(top2))) in
  (* Get bounds on the results *)
  let (newBase1, newTop1) = Cheri_cc.zgetCapBounds(cap_encode_decode cap1) in
  let (newBase2, newTop2) = Cheri_cc.zgetCapBounds(cap_encode_decode cap2) in
  (* Check whether exact flags are correct *)
  let exact1correct = exact1 = ((BI.equal newBase1 (snd base1)) && (BI.equal newTop1 (snd top1))) in
  let exact2correct = exact2 = ((BI.equal newBase2 (snd base2)) && (BI.equal newTop2 (snd top2))) in
  (* check cap1 includes the bounds requested - 
     it's probably safe to assume that cap1 is within default_cap... *)
  let cap1includesRequested = BI.less_equal newBase1 (snd base1) && BI.less_equal (snd top1) newTop1 in
  (* check cap2 includes requested bounds *)
  let cap2includesRequested = BI.less_equal newBase2 (snd base2) && BI.less_equal (snd top2) newTop2 in
  (* check cap2 is within cap1 i.e. setCapBounds does not violate monotinicity *)
  let cap2inCap1 = BI.less_equal newBase1 newBase2 && BI.less_equal newTop2 newTop1 in
  (* XXX would be nice to have upper bound of length of caps that is less than 
     length of original cap *)
  let passed = exact1correct && exact2correct
               && cap1includesRequested && cap2includesRequested
               && cap2inCap1 in
  begin
    if not passed then begin
        print_endline "Failure:";
        print_endline (print_bounds (List.map fst sortedBounds));
        print_endline (Cheri_cc.string_of_zCapability cap1);
        print_endline (Cheri_cc.string_of_zCapability cap2);
        if not exact1correct then
          print_endline "exact1 incorrect";
        if not exact2correct then
          print_endline "exact2_incorrect";
        if not cap1includesRequested then begin
            print_endline "Cap1 not within requested bounds";
            print_endline ("requested base " ^ (Z.format "x" (snd base1)) ^ " got " ^ (Z.format "x" newBase1));
            print_endline ("requested top " ^ (Z.format "x" (snd top1)) ^ " got " ^ (Z.format "x" newTop1));
          end;
        if not cap2includesRequested then begin
            print_endline "Cap2 not within requested bounds";
            print_endline ("requested base " ^ (Z.format "x" (snd base2)) ^ " got " ^ (Z.format "x" newBase2));
            print_endline ("requested top " ^ (Z.format "x" (snd top2)) ^ " got " ^ (Z.format "x" newTop2));
          end;
        if not cap2inCap1 then begin
            print_endline "Cap2 breaks monotonicity:";
            print_endline ("cap1: " ^ (Z.format "x" newBase1) ^ " .. " ^ (Z.format "x" newTop1));
            print_endline ("cap2: " ^ (Z.format "x" newBase2) ^ " .. " ^ (Z.format "x" newTop2));
          end;
      end;
    passed
  end

let gen_bounds2 =
  QCheck.Gen.(list_repeat 2 (gen_sailbits_geom 64))

let gen_offset = gen_sailbits_geom_signed 64

let b64_of_s = bits_of_string 64
let setOffset_regressions = List.map (fun (base, top, offset) -> ([b64_of_s base; b64_of_s top], b64_of_s offset)) [
("0x0000000000000000", "0x0000000000000000", "0xffffffffffffffff");
("0xffffffffffff0000", "0xffffffffffffffff", "0x0000000000010000"); (* NB top should round to 2**64 *)
]

let gen_setOffset = QCheck.Gen.graft_corners (QCheck.Gen.pair gen_bounds2 gen_offset) setOffset_regressions ()
  
  
let test_setOffset (bounds, offset) =
  (* pair each bit list with Big_int for easy comparison etc. *)
  let zippedBounds = List.combine bounds (List.map Sail_lib.uint bounds) in
  let sortedBounds = List.sort (fun (_, a) (_, b) -> BI.compare a b) zippedBounds in
  let [base; top] = sortedBounds in
  let (exact, cap1) = Cheri_cc.zsetCapBounds(Cheri_cc.zdefault_cap, fst(base), B0::fst(top)) in
  let (rep, cap2) = Cheri_cc.zsetCapOffset(cap1, offset) in
  let zoff = Sail_lib.sint(offset) in
  let len = BI.max (BI.of_int 4096) (Cheri_cc.zgetCapLength cap1) in
  let z4 = BI.of_int 4 in
  let z6 = BI.of_int 6 in
  let lowerRepOff = BI.negate (BI.div len z4) in
  let upperRepOff = BI.div (BI.mul len z6) z4 in
  let success = rep || (BI.less zoff lowerRepOff) || (BI.greater zoff upperRepOff) in begin
      if not success then begin
          print_endline (Cheri_cc.string_of_zCapability cap1);
          print_endline ("lowerRepOff=" ^ (Z.format "x" lowerRepOff));
          print_endline ("uppperRepOff=" ^ (Z.format "x" upperRepOff));
        end;
      success
  end

let print_setOffset = QCheck.Print.pair print_bounds string_of_bits

let arbitrary_setOffset = QCheck.make ~print:print_setOffset gen_setOffset

let testsuite = [
  QCheck.Test.make ~count:10000 ~long_factor:1000 ~name:"setOffset"  arbitrary_setOffset test_setOffset;
  QCheck.Test.make ~count:10000 ~long_factor:1000 ~name:"setCapBounds"  arbitrary_bounds test_setBounds;
  QCheck.Test.make ~count:10000 ~long_factor:1000 ~name:"cap_decode_encode" arbitrary_cap_bits test_cap_decode_encode;
  (*  QCheck.Test.make ~count:10000 ~long_factor:1000 ~name:"cap_length" arbitrary_cap_bits test_get_length; *)
]
  
let () =
  begin
    QCheck_runner.run_tests_main testsuite;
  end
