Require Import Coq.ZArith.BinInt.
Require Import coqutil.Z.Lia.
Require Import coqutil.Word.Properties.
Require Import coqutil.Word.Bitwidth.
Require Export coqutil.Word.Naive.

Local Open Scope Z_scope.

#[export] Hint Extern 0 (word.word 32) => exact (Naive.word 32) : typeclass_instances.
Notation word := (Naive.word 32).

#[export] Instance Words32Naive: Bitwidth 32 := {|
  width_cases := or_introl eq_refl;
|}.
