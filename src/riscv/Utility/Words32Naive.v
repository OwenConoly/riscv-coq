Require Import Coq.ZArith.BinInt.
Require Import nondet.coqutil.Z.Lia.
Require Import nondet.coqutil.Word.Properties.
Require Import nondet.coqutil.Word.Bitwidth.
Require Import nondet.coqutil.Word.Naive.

Local Open Scope Z_scope.

#[global] Instance word: word.word 32 := Naive.word 32.

#[global] Instance Words32Naive: Bitwidth 32 := {|
  width_cases := or_introl eq_refl;
|}.
