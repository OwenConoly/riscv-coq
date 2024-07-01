Require Import Coq.ZArith.BinInt.
Require Import det.coqutil.Z.Lia.
Require Import det.coqutil.Word.Properties.
Require Import det.coqutil.Word.Bitwidth.
Require Import det.coqutil.Word.Naive.

Local Open Scope Z_scope.

#[global] Instance word: word.word 32 := Naive.word 32.

#[global] Instance Words32Naive: Bitwidth 32 := {|
  width_cases := or_introl eq_refl;
|}.
