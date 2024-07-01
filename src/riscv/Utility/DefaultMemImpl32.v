Require Import Coq.ZArith.ZArith.
Require Import det.coqutil.Z.Lia.
Require Import det.coqutil.Word.Interface det.coqutil.Word.Properties det.coqutil.Word.Naive.
Require Import det.coqutil.Map.Interface.
Require Import riscv.Utility.Words32Naive.
Require det.coqutil.Map.SortedList det.coqutil.Map.SortedListWord.


#[global] Instance params: SortedList.parameters := {|
  SortedList.parameters.key := word32;
  SortedList.parameters.value := Byte.byte;
  SortedList.parameters.ltb := word.ltu;
|}.

#[global] Instance Mem: map.map word32 Byte.byte := SortedList.map params _.
#[global] Instance MemOk: map.ok Mem := SortedList.map_ok.
