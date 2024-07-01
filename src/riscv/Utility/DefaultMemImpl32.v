Require Import Coq.ZArith.ZArith.
Require Import nondet.coqutil.Z.Lia.
Require Import nondet.coqutil.Word.Interface nondet.coqutil.Word.Properties nondet.coqutil.Word.Naive.
Require Import nondet.coqutil.Map.Interface.
Require Import riscv.Utility.Words32Naive.
Require nondet.coqutil.Map.SortedList nondet.coqutil.Map.SortedListWord.


#[global] Instance params: SortedList.parameters := {|
  SortedList.parameters.key := word32;
  SortedList.parameters.value := Byte.byte;
  SortedList.parameters.ltb := word.ltu;
|}.

#[global] Instance Mem: map.map word32 Byte.byte := SortedList.map params _.
#[global] Instance MemOk: map.ok Mem := SortedList.map_ok.
