(* Default settings (from HsToCoq.Coq.Preamble) *)

Generalizable All Variables.

Unset Implicit Arguments.
Set Maximal Implicit Insertion.
Unset Strict Implicit.
Unset Printing Implicit Defensive.

Require Coq.Program.Tactics.
Require Coq.Program.Wf.

(* Preamble *)

Require Coq.ZArith.BinInt.
Local Open Scope Z_scope.

Notation Register := BinInt.Z (only parsing).
Notation FPRegister := BinInt.Z (only parsing).
Notation RoundMode := BinInt.Z (only parsing).
Notation Opcode := BinInt.Z (only parsing).

(* Converted imports: *)

Require Coq.Init.Datatypes.
Require Coq.Lists.List.
Require Import Coq.ZArith.BinInt.
Require Import Utility.Utility.

Require Import riscv.Utility.Monads.
Require Import riscv.Utility.MonadNotations.
Section WithMonad.
  Context {M : Type -> Type} {MM : Monad M}.

(* Converted type declarations: *)

Inductive InstructionSet : Type :=
  | RV32I : InstructionSet
  | RV32IM : InstructionSet
  | RV32IA : InstructionSet
  | RV32IMA : InstructionSet
  | RV32IF : InstructionSet
  | RV32IMF : InstructionSet
  | RV32IAF : InstructionSet
  | RV32IMAF : InstructionSet
  | RV64I : InstructionSet
  | RV64IM : InstructionSet
  | RV64IA : InstructionSet
  | RV64IMA : InstructionSet
  | RV64IF : InstructionSet
  | RV64IMF : InstructionSet
  | RV64IAF : InstructionSet
  | RV64IMAF : InstructionSet.

Inductive InstructionM64 : Type :=
  | Mulw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM64
  | Divw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM64
  | Divuw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM64
  | Remw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM64
  | Remuw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM64
  | InvalidM64 : InstructionM64.

Inductive LeakageM64
  {width} {BW : Bitwidth width} {word: word.word width} : Type :=
| Mulw_leakage (*andres says that this is constant-time*)
| Divw_leakage (num : word) (den : word) (*but that this is not.*)
| Divuw_leakage (num : word) (den : word)
| Remw_leakage (num : word) (den : word) (*i'm not sure about this one. probably same as div, so not constant-time.*)
| Remuw_leakage (num : word) (den : word)
| InvalidM64_leakage.

Definition leakage_of_instr_M64 
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionM64) : M LeakageM64 :=
  match instr with
  | Mulw _ _ _ => Return Mulw_leakage
  | Divw _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Divw_leakage num den) 
  | Divuw _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Divuw_leakage num den)
  | Remw _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Remw_leakage num den)
  | Remuw _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Remuw_leakage num den)
  | InvalidM64 => Return InvalidM64_leakage
  end.

Inductive InstructionM : Type :=
  | Mul (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Mulh (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Mulhsu (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Mulhu (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Div (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Divu (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Rem (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | Remu (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionM
  | InvalidM : InstructionM.

Inductive LeakageM
  {width} {BW : Bitwidth width} {word: word.word width} : Type :=
| Mul_leakage
| Mulh_leakage
| Mulhsu_leakage
| Mulhu_leakage
| Div_leakage (num : word) (den : word)
| Divu_leakage (num : word) (den : word)
| Rem_leakage (num : word) (den : word)
| Remu_leakage (num : word) (den : word)
| InvalidM_leakage.

Definition leakage_of_instr_M
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionM) : M LeakageM :=
  match instr with
  | Mul _ _ _ => Return Mul_leakage
  | Mulh _ _ _ => Return Mulh_leakage
  | Mulhsu _ _ _ => Return Mulhsu_leakage
  | Mulhu _ _ _ => Return Mulhu_leakage
  | Div _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Div_leakage num den)
  | Divu _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Divu_leakage num den)
  | Rem _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Rem_leakage num den)
  | Remu _ rs1 rs2 => num <- getRegister rs1; den <- getRegister rs2; Return (Remu_leakage num den)
  | InvalidM => Return InvalidM_leakage
  end.

Inductive InstructionI64 : Type :=
  | Ld (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI64
  | Lwu (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI64
  | Addiw (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI64
  | Slliw (rd : Register) (rs1 : Register) (shamt5 : Z) : InstructionI64
  | Srliw (rd : Register) (rs1 : Register) (shamt5 : Z) : InstructionI64
  | Sraiw (rd : Register) (rs1 : Register) (shamt5 : Z) : InstructionI64
  | Sd (rs1 : Register) (rs2 : Register) (simm12 : Utility.Utility.MachineInt)
   : InstructionI64
  | Addw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI64
  | Subw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI64
  | Sllw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI64
  | Srlw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI64
  | Sraw (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI64
  | InvalidI64 : InstructionI64.

Inductive LeakageI64
{width} {BW : Bitwidth width} {word: word.word width}
  : Type :=
| Ld_leakage (addr: word)
| Lwu_leakage (addr: word)
| Addiw_leakage
| Slliw_leakage (shamt : Z)
| Srliw_leakage (shamt : Z)
| Sraiw_leakage (shamt : Z)
| Sd_leakage (addr: word)
| Addw_leakage
| Subw_leakage
| Sllw_leakage (shamt : word)
| Srlw_leakage (shamt : word)
| Sraw_leakage (shamt : word)
| InvalidI64_leakage.

Definition leakage_of_instr_I64
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionI64) : M LeakageI64 :=
  match instr with
  | Ld _ rs1 oimm12 => Bind (getRegister rs1) (fun rs1_val => Return (Ld_leakage (word.add rs1_val (word.of_Z oimm12))))
  | Lwu _ rs1 oimm12 => Bind (getRegister rs1) (fun rs1_val => Return (Lwu_leakage (word.add rs1_val (word.of_Z oimm12))))
  | Addiw _ _ _ => Return Addiw_leakage
  | Slliw _ _ shamt => Return (Slliw_leakage shamt)
  | Srliw _ _ shamt => Return (Srliw_leakage shamt)
  | Sraiw _ _ shamt => Return (Sraiw_leakage shamt)
  | Sd rs1 _ simm12 => Bind (getRegister rs1) (fun rs1_val => Return (Sd_leakage (word.add rs1_val (word.of_Z simm12))))
  | Addw _ _ _ => Return Addw_leakage
  | Subw _ _ _ => Return Subw_leakage
  | Sllw _ _ rs2 => shamt <- getRegister rs2; Return (Sllw_leakage shamt)
  | Srlw _ _ rs2 => shamt <- getRegister rs2; Return (Srlw_leakage shamt)
  | Sraw _ _ rs2 => shamt <- getRegister rs2; Return (Sraw_leakage shamt)
  | InvalidI64 => Return InvalidI64_leakage
  end.

Inductive LeakageI
  {width} {BW : Bitwidth width} {word: word.word width}
  : Type :=
| Lb_leakage (addr: word)
| Lh_leakage (addr: word)
| Lw_leakage (addr: word)
| Lbu_leakage (addr: word)
| Lhu_leakage (addr: word)
| Fence_leakage (* unsure about this one. *)
| Fence_i_leakage
| Addi_leakage
| Slli_leakage (shamt : Z)
| Slti_leakage (shamt : Z)
| Sltiu_leakage (shamt : Z)
| Xori_leakage
| Ori_leakage
| Andi_leakage
| Srli_leakage (shamt : Z)
| Srai_leakage (shamt : Z)
| Auipc_leakage
| Sb_leakage (addr: word)
| Sh_leakage (addr: word)
| Sw_leakage (addr: word)
| Add_leakage
| Sub_leakage
| Sll_leakage (shamt : word)
| Slt_leakage (shamt : word)
| Sltu_leakage (shamt : word)
| Xor_leakage
| Srl_leakage (shamt : word)
| Sra_leakage (shamt : word)
| Or_leakage
| And_leakage
| Lui_leakage
| Beq_leakage (branch: bool) (* unsure whether this should be here - i think that andres said that having this argument would make my life harder *)
| Bne_leakage (branch: bool)
| Blt_leakage (branch: bool)
| Bge_leakage (branch: bool)
| Bltu_leakage (branch: bool)
| Bgeu_leakage (branch: bool)
| Jalr_leakage (* unsure whether i should add the location we're jumping to here - or on the branches. i think not? *)
| Jal_leakage
| InvalidI_leakage.
                            
Inductive InstructionI : Type :=
  | Lb (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Lh (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Lw (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Lbu (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Lhu (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Fence (pred : Utility.Utility.MachineInt) (succ : Utility.Utility.MachineInt)
   : InstructionI
  | Fence_i : InstructionI
  | Addi (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Slli (rd : Register) (rs1 : Register) (shamt6 : Z) : InstructionI
  | Slti (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Sltiu (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Xori (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Ori (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Andi (rd : Register) (rs1 : Register) (imm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Srli (rd : Register) (rs1 : Register) (shamt6 : Z) : InstructionI
  | Srai (rd : Register) (rs1 : Register) (shamt6 : Z) : InstructionI
  | Auipc (rd : Register) (oimm20 : Utility.Utility.MachineInt) : InstructionI
  | Sb (rs1 : Register) (rs2 : Register) (simm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Sh (rs1 : Register) (rs2 : Register) (simm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Sw (rs1 : Register) (rs2 : Register) (simm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Add (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Sub (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Sll (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Slt (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Sltu (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Xor (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Srl (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Sra (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Or (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | And (rd : Register) (rs1 : Register) (rs2 : Register) : InstructionI
  | Lui (rd : Register) (imm20 : Utility.Utility.MachineInt) : InstructionI
  | Beq (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Bne (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Blt (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Bge (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Bltu (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Bgeu (rs1 : Register) (rs2 : Register) (sbimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Jalr (rd : Register) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionI
  | Jal (rd : Register) (jimm20 : Utility.Utility.MachineInt) : InstructionI
  | InvalidI : InstructionI.

(* are the immediates already signed, or do I need to do some sort of sign extension thing?  surely not, since they're already Z, right? *)
Definition leakage_of_instr_I
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionI) : M LeakageI :=
  match instr with
  | Lb _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Lb_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Lh _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Lh_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Lw _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Lw_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Lbu _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Lbu_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Lhu _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Lhu_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Fence _ _ => Return Fence_leakage
  | Fence_i => Return Fence_i_leakage
  | Addi _ _ _ => Return Addi_leakage
  | Slli _ _ shamt => Return (Slli_leakage shamt)
  | Slti _ _ shamt => Return (Slti_leakage shamt)
  | Sltiu _ _ shamt => Return (Sltiu_leakage shamt)
  | Xori _ _ _ => Return Xori_leakage
  | Ori _ _ _ => Return Ori_leakage
  | Andi _ _ _ => Return Andi_leakage
  | Srli _ _ shamt => Return (Srli_leakage shamt)
  | Srai _ _ shamt => Return (Srai_leakage shamt)
  | Auipc _ _ => Return Auipc_leakage
  | Sb rs1 _ simm12 => rs1_val <- getRegister rs1; Return (Sb_leakage (word.add rs1_val (word.of_Z simm12)))
  | Sh rs1 _ simm12 => rs1_val <- getRegister rs1; Return (Sh_leakage (word.add rs1_val (word.of_Z simm12)))
  | Sw rs1 _ simm12 => rs1_val <- getRegister rs1; Return (Sw_leakage (word.add rs1_val (word.of_Z simm12)))
  | Add _ _ _ => Return Add_leakage
  | Sub _ _ _ => Return Sub_leakage
  | Sll _ _ rs2 => shamt <- getRegister rs2; Return (Sll_leakage shamt)
  | Slt _ _ rs2 => shamt <- getRegister rs2; Return (Slt_leakage shamt)
  | Sltu _ _ rs2 => shamt <- getRegister rs2; Return (Sltu_leakage shamt)
  | Xor _ _ _ => Return Xor_leakage
  | Srl _ _ rs2 => shamt <- getRegister rs2; Return (Srl_leakage shamt)
  | Sra _ _ rs2 => shamt <- getRegister rs2; Return (Sra_leakage shamt)
  | Or _ _ _ => Return Or_leakage
  | And _ _ _ => Return And_leakage
  | Lui _ _ => Return Lui_leakage
  | Beq rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Beq_leakage (word.eqb rs1_val rs2_val))
  | Bne rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Bne_leakage (negb (word.eqb rs1_val rs2_val)))
  | Blt rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Blt_leakage (word.lts rs1_val rs2_val))
  | Bge rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Bge_leakage (negb (word.lts rs1_val rs2_val)))
  | Bltu rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Bltu_leakage (word.ltu rs1_val rs2_val))
  | Bgeu rs1 rs2 _ => rs1_val <- getRegister rs1; rs2_val <- getRegister rs2; Return (Bgeu_leakage (negb (word.ltu rs1_val rs2_val)))
  | Jalr _ _ _ => Return Jalr_leakage
  | Jal _ _ => Return Jal_leakage
  | InvalidI => Return InvalidI_leakage
  end.

Inductive InstructionF64 : Type :=
  | Fcvt_l_s (rd : Register) (rs1 : FPRegister) (rm : RoundMode) : InstructionF64
  | Fcvt_lu_s (rd : Register) (rs1 : FPRegister) (rm : RoundMode) : InstructionF64
  | Fcvt_s_l (rd : FPRegister) (rs1 : Register) (rm : RoundMode) : InstructionF64
  | Fcvt_s_lu (rd : FPRegister) (rs1 : Register) (rm : RoundMode) : InstructionF64
  | InvalidF64 : InstructionF64.

Inductive LeakageF64 : Type :=
| Fcvt_l_s_leakage
| Fcvt_lu_s_leakage
| Fcvt_s_l_leakage
| Fcvt_s_lu_leakage
| InvalidF64_leakage.

Definition leakage_of_instr_F64 (instr : InstructionF64) : M LeakageF64 :=
  match instr with
  | Fcvt_l_s _ _ _ => Return Fcvt_l_s_leakage
  | Fcvt_lu_s _ _ _ => Return Fcvt_lu_s_leakage
  | Fcvt_s_l _ _ _ => Return Fcvt_s_l_leakage
  | Fcvt_s_lu _ _ _ => Return Fcvt_s_lu_leakage
  | InvalidF64 => Return InvalidF64_leakage
  end.

Inductive LeakageF
  {width} {BW : Bitwidth width} {word: word.word width}
  : Type :=
| Flw_leakage (addr: word)
| Fsw_leakage (addr: word)
| Fmadd_s_leakage
| Fmsub_s_leakage
| Fnmsub_s_leakage
| Fnmadd_s_leakage
| Fadd_s_leakage
| Fsub_s_leakage
| Fmul_s_leakage
| Fdiv_s_leakage
| Fsqrt_s_leakage
| Fsgnj_s_leakage
| Fsgnjn_s_leakage
| Fsgnjx_s_leakage
| Fmin_s_leakage
| Fmax_s_leakage
| Fcvt_w_s_leakage
| Fcvt_wu_s_leakage
| Fmv_x_w_leakage
| Feq_s_leakage
| Flt_s_leakage
| Fle_s_leakage
| Fclass_s_leakage
| Fcvt_s_w_leakage
| Fcvt_s_wu_leakage
| Fmv_w_x_leakage
| InvalidF_leakage.

Inductive InstructionF : Type :=
  | Flw (rd : FPRegister) (rs1 : Register) (oimm12 : Utility.Utility.MachineInt)
   : InstructionF
  | Fsw (rs1 : Register) (rs2 : FPRegister) (simm12 : Utility.Utility.MachineInt)
   : InstructionF
  | Fmadd_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rs3
    : FPRegister) (rm : RoundMode)
   : InstructionF
  | Fmsub_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rs3
    : FPRegister) (rm : RoundMode)
   : InstructionF
  | Fnmsub_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rs3
    : FPRegister) (rm : RoundMode)
   : InstructionF
  | Fnmadd_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rs3
    : FPRegister) (rm : RoundMode)
   : InstructionF
  | Fadd_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rm
    : RoundMode)
   : InstructionF
  | Fsub_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rm
    : RoundMode)
   : InstructionF
  | Fmul_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rm
    : RoundMode)
   : InstructionF
  | Fdiv_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) (rm
    : RoundMode)
   : InstructionF
  | Fsqrt_s (rd : FPRegister) (rs1 : FPRegister) (rm : RoundMode) : InstructionF
  | Fsgnj_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Fsgnjn_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister)
   : InstructionF
  | Fsgnjx_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister)
   : InstructionF
  | Fmin_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Fmax_s (rd : FPRegister) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Fcvt_w_s (rd : Register) (rs1 : FPRegister) (rm : RoundMode) : InstructionF
  | Fcvt_wu_s (rd : Register) (rs1 : FPRegister) (rm : RoundMode) : InstructionF
  | Fmv_x_w (rd : Register) (rs1 : FPRegister) : InstructionF
  | Feq_s (rd : Register) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Flt_s (rd : Register) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Fle_s (rd : Register) (rs1 : FPRegister) (rs2 : FPRegister) : InstructionF
  | Fclass_s (rd : Register) (rs1 : FPRegister) : InstructionF
  | Fcvt_s_w (rd : FPRegister) (rs1 : Register) (rm : RoundMode) : InstructionF
  | Fcvt_s_wu (rd : FPRegister) (rs1 : Register) (rm : RoundMode) : InstructionF
  | Fmv_w_x (rd : FPRegister) (rs1 : Register) : InstructionF
  | InvalidF : InstructionF. Print word.word.

Definition leakage_of_instr_F
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionF) : M LeakageF :=
  match instr with
  | Flw _ rs1 oimm12 => rs1_val <- getRegister rs1; Return (Flw_leakage (word.add rs1_val (word.of_Z oimm12)))
  | Fsw rs1 _ simm12 => rs1_val <- getRegister rs1; Return (Fsw_leakage (word.add rs1_val (word.of_Z simm12)))
  | Fmadd_s _ _ _ _ _ => Return Fmadd_s_leakage
  | Fmsub_s _ _ _ _ _ => Return Fmsub_s_leakage
  | Fnmsub_s _ _ _ _ _ => Return Fnmsub_s_leakage
  | Fnmadd_s _ _ _ _ _ => Return Fnmadd_s_leakage
  | Fadd_s _ _ _ _ => Return Fadd_s_leakage
  | Fsub_s _ _ _ _ => Return Fsub_s_leakage
  | Fmul_s _ _ _ _ => Return Fmul_s_leakage
  | Fdiv_s _ _ _ _ => Return Fdiv_s_leakage
  | Fsqrt_s _ _ _ => Return Fsqrt_s_leakage
  | Fsgnj_s _ _ _ => Return Fsgnj_s_leakage
  | Fsgnjn_s _ _ _ => Return Fsgnjn_s_leakage
  | Fsgnjx_s _ _ _ => Return Fsgnjx_s_leakage
  | Fmin_s _ _ _ => Return Fmin_s_leakage
  | Fmax_s _ _ _ => Return Fmax_s_leakage
  | Fcvt_w_s _ _ _ => Return Fcvt_w_s_leakage
  | Fcvt_wu_s _ _ _ => Return Fcvt_wu_s_leakage
  | Fmv_x_w _ _ => Return Fmv_x_w_leakage
  | Feq_s _ _ _ => Return Feq_s_leakage
  | Flt_s _ _ _ => Return Flt_s_leakage
  | Fle_s _ _ _ => Return Fle_s_leakage
  | Fclass_s _ _ => Return Fclass_s_leakage
  | Fcvt_s_w _ _ _ => Return Fcvt_s_w_leakage
  | Fcvt_s_wu _ _ _ => Return Fcvt_s_wu_leakage
  | Fmv_w_x _ _ => Return Fmv_w_x_leakage
  | InvalidF => Return InvalidF_leakage
  end.

(* unsure what some of these mean, so unsure whether I have the right definition here. *)
Inductive LeakageCSR : Type :=
| Ecall_leakage
| Ebreak_leakage
| Uret_leakage
| Sret_leakage
| Mret_leakage
| Wfi_leakage
| Sfence_vma_leakage
| Csrrw_leakage
| Csrrs_leakage
| Csrrc_leakage
| Csrrwi_leakage
| Csrrsi_leakage
| Csrrci_leakage
| InvalidCSR_leakage.

(* what are these, and why is it hard to find documentation for them? *)
Inductive InstructionCSR : Type :=
  | Ecall : InstructionCSR
  | Ebreak : InstructionCSR
  | Uret : InstructionCSR
  | Sret : InstructionCSR
  | Mret : InstructionCSR
  | Wfi : InstructionCSR
  | Sfence_vma (rs1 : Register) (rs2 : Register) : InstructionCSR
  | Csrrw (rd : Register) (rs1 : Register) (csr12 : Utility.Utility.MachineInt)
   : InstructionCSR
  | Csrrs (rd : Register) (rs1 : Register) (csr12 : Utility.Utility.MachineInt)
   : InstructionCSR
  | Csrrc (rd : Register) (rs1 : Register) (csr12 : Utility.Utility.MachineInt)
   : InstructionCSR
  | Csrrwi (rd : Register) (zimm : Utility.Utility.MachineInt) (csr12
    : Utility.Utility.MachineInt)
   : InstructionCSR
  | Csrrsi (rd : Register) (zimm : Utility.Utility.MachineInt) (csr12
    : Utility.Utility.MachineInt)
   : InstructionCSR
  | Csrrci (rd : Register) (zimm : Utility.Utility.MachineInt) (csr12
    : Utility.Utility.MachineInt)
   : InstructionCSR
  | InvalidCSR : InstructionCSR.

Definition leakage_of_instr_CSR (instr : InstructionCSR) : M LeakageCSR :=
  match instr with
  | Ecall => Return Ecall_leakage
  | Ebreak => Return Ebreak_leakage
  | Uret => Return Uret_leakage
  | Sret => Return Uret_leakage
  | Mret => Return Mret_leakage
  | Wfi => Return Wfi_leakage
  | Sfence_vma _ _ => Return Sfence_vma_leakage
  | Csrrw _ _ _ => Return Csrrw_leakage
  | Csrrs _ _ _ => Return Csrrs_leakage
  | Csrrc _ _ _ => Return Csrrc_leakage
  | Csrrwi _ _ _ => Return Csrrwi_leakage
  | Csrrsi _ _ _ => Return Csrrsi_leakage
  | Csrrci _ _ _ => Return Csrrci_leakage
  | InvalidCSR => Return InvalidCSR_leakage
  end.

(* do we care about aqrl here? *)
Inductive LeakageA64
  {width} {BW : Bitwidth width} {word: word.word width}
  : Type :=
| Lr_d_leakage (addr : word)
| Sc_d_leakage (addr : word) (* behavior of this depends on whether there is a reservation on addr... *)
| Amoswap_d_leakage (addr : word)
| Amoadd_d_leakage (addr : word)
| Amoand_d_leakage (addr : word)
| Amoor_d_leakage (addr : word)
| Amoxor_d_leakage (addr : word)
| Amomax_d_leakage (addr : word)
| Amomaxu_d_leakage (addr : word)
| Amomin_d_leakage (addr : word)
| Amominu_d_leakage (addr : word)
| InvalidA64_leakage.

Inductive InstructionA64 : Type :=
  | Lr_d (rd : Register) (rs1 : Register) (aqrl : Utility.Utility.MachineInt)
   : InstructionA64
  | Sc_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amoswap_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amoadd_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amoand_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amoor_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amoxor_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amomax_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amomaxu_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amomin_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | Amominu_d (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA64
  | InvalidA64 : InstructionA64.

Definition leakage_of_instr_A64
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionA64) : M LeakageA64 :=
  match instr with
  | Lr_d _ rs1 _ => rs1_val <- getRegister rs1; Return (Lr_d_leakage rs1_val)
  | Sc_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Sc_d_leakage rs1_val)
  | Amoswap_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoswap_d_leakage rs1_val)
  | Amoadd_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoadd_d_leakage rs1_val)
  | Amoand_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoand_d_leakage rs1_val)
  | Amoor_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoor_d_leakage rs1_val)
  | Amoxor_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoxor_d_leakage rs1_val)
  | Amomax_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomax_d_leakage rs1_val)
  | Amomaxu_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomaxu_d_leakage rs1_val)
  | Amomin_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomin_d_leakage rs1_val)
  | Amominu_d _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amominu_d_leakage rs1_val)
  | InvalidA64 => Return InvalidA64_leakage
  end.

  Inductive LeakageA
    {width} {BW : Bitwidth width} {word: word.word width}
    : Type :=
| Lr_w_leakage (addr : word)
| Sc_w_leakage (addr : word)
| Amoswap_w_leakage (addr : word)
| Amoadd_w_leakage (addr : word)
| Amoand_w_leakage (addr : word)
| Amoor_w_leakage (addr : word)
| Amoxor_w_leakage (addr : word)
| Amomax_w_leakage (addr : word)
| Amomaxu_w_leakage (addr : word)
| Amomin_w_leakage (addr : word)
| Amominu_w_leakage (addr : word)
| InvalidA_leakage.

Inductive InstructionA : Type :=
  | Lr_w (rd : Register) (rs1 : Register) (aqrl : Utility.Utility.MachineInt)
   : InstructionA
  | Sc_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amoswap_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amoadd_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amoand_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amoor_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amoxor_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amomax_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amomaxu_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amomin_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | Amominu_w (rd : Register) (rs1 : Register) (rs2 : Register) (aqrl
    : Utility.Utility.MachineInt)
   : InstructionA
  | InvalidA : InstructionA.

Definition leakage_of_instr_A
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : InstructionA) : M LeakageA :=
  match instr with
  | Lr_w _ rs1 _ => rs1_val <- getRegister rs1; Return (Lr_w_leakage rs1_val)
  | Sc_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Sc_w_leakage rs1_val)
  | Amoswap_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoswap_w_leakage rs1_val)
  | Amoadd_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoadd_w_leakage rs1_val)
  | Amoand_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoand_w_leakage rs1_val)
  | Amoor_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoor_w_leakage rs1_val)
  | Amoxor_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amoxor_w_leakage rs1_val)
  | Amomax_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomax_w_leakage rs1_val)
  | Amomaxu_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomaxu_w_leakage rs1_val)
  | Amomin_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amomin_w_leakage rs1_val)
  | Amominu_w _ rs1 _ _ => rs1_val <- getRegister rs1; Return (Amominu_w_leakage rs1_val)
  | InvalidA => Return InvalidA_leakage
  end.

Inductive Instruction : Type :=
  | IInstruction (iInstruction : InstructionI) : Instruction
  | MInstruction (mInstruction : InstructionM) : Instruction
  | AInstruction (aInstruction : InstructionA) : Instruction
  | FInstruction (fInstruction : InstructionF) : Instruction
  | I64Instruction (i64Instruction : InstructionI64) : Instruction
  | M64Instruction (m64Instruction : InstructionM64) : Instruction
  | A64Instruction (a64Instruction : InstructionA64) : Instruction
  | F64Instruction (f64Instruction : InstructionF64) : Instruction
  | CSRInstruction (csrInstruction : InstructionCSR) : Instruction
  | InvalidInstruction (inst : Utility.Utility.MachineInt) : Instruction.

Inductive LeakageEvent
  {width} {BW : Bitwidth width} {word: word.word width}
  : Type :=
| ILeakage (iLeakage : LeakageI)
| MLeakage (mLeakage : LeakageM)
| ALeakage (aLeakage : LeakageA)
| FLeakage (fLeakage : LeakageF)
| I64Leakage (i64Leakage : LeakageI64)
| M64Leakage (m64Leakage : LeakageM64)
| A64Leakage (a64Leakage : LeakageA64)
| F64Leakage (f64Leakage : LeakageF64)
| CSRLeakage (csrLeakage : LeakageCSR)
| InvalidLeakage.

Definition leakage_of_instr
  {width} {BW : Bitwidth width} {word: word.word width} (getRegister : Register -> M word)
  (instr : Instruction) : M LeakageEvent :=
  match instr with
  | IInstruction instr => l <- leakage_of_instr_I getRegister instr; Return (ILeakage l)
  | MInstruction instr => l <- leakage_of_instr_M getRegister instr; Return (MLeakage l)
  | AInstruction instr => l <- leakage_of_instr_A getRegister instr; Return (ALeakage l)
  | FInstruction instr => l <- leakage_of_instr_F getRegister instr; Return (FLeakage l)
  | I64Instruction instr => l <- leakage_of_instr_I64 getRegister instr; Return (I64Leakage l)
  | M64Instruction instr => l <- leakage_of_instr_M64 getRegister instr; Return (M64Leakage l)
  | A64Instruction instr => l <- leakage_of_instr_A64 getRegister instr; Return (A64Leakage l)
  | F64Instruction instr => l <- leakage_of_instr_F64 instr; Return (F64Leakage l)
  | CSRInstruction instr => l <- leakage_of_instr_CSR instr; Return (CSRLeakage l)
  | InvalidInstruction _ => Return InvalidLeakage
end.

End WithMonad.

(* Converted value declarations: *)

(* Skipping instance `Spec.Decode.Eq___InstructionSet' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Show__InstructionSet' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionCSR' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionCSR' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionCSR' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionA64' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionA64' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionA64' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionM64' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionM64' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionM64' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionI64' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionI64' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionI64' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionA' of class `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionA' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionA' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionM' of class `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionM' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionM' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionI' of class `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionI' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionI' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionF64' of class
   `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionF64' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionF64' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___InstructionF' of class `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__InstructionF' of class
   `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__InstructionF' of class
   `GHC.Show.Show' *)

(* Skipping instance `Spec.Decode.Eq___Instruction' of class `GHC.Base.Eq_' *)

(* Skipping instance `Spec.Decode.Read__Instruction' of class `GHC.Read.Read' *)

(* Skipping instance `Spec.Decode.Show__Instruction' of class `GHC.Show.Show' *)

Definition bitwidth : InstructionSet -> Z :=
  fun arg_0__ =>
    match arg_0__ with
    | RV32I => 32
    | RV32IM => 32
    | RV32IA => 32
    | RV32IMA => 32
    | RV32IF => 32
    | RV32IMF => 32
    | RV32IAF => 32
    | RV32IMAF => 32
    | RV64I => 64
    | RV64IM => 64
    | RV64IA => 64
    | RV64IMA => 64
    | RV64IF => 64
    | RV64IMF => 64
    | RV64IAF => 64
    | RV64IMAF => 64
    end.

Definition supportsM : InstructionSet -> bool :=
  fun arg_0__ =>
    match arg_0__ with
    | RV32IM => true
    | RV32IMA => true
    | RV32IMF => true
    | RV32IMAF => true
    | RV64IM => true
    | RV64IMA => true
    | RV64IMF => true
    | RV64IMAF => true
    | _ => false
    end.

Definition supportsA : InstructionSet -> bool :=
  fun arg_0__ =>
    match arg_0__ with
    | RV32IA => true
    | RV32IMA => true
    | RV32IAF => true
    | RV32IMAF => true
    | RV64IA => true
    | RV64IMA => true
    | RV64IAF => true
    | RV64IMAF => true
    | _ => false
    end.

Definition supportsF : InstructionSet -> bool :=
  fun arg_0__ =>
    match arg_0__ with
    | RV32IF => true
    | RV32IMF => true
    | RV32IAF => true
    | RV32IMAF => true
    | RV64IF => true
    | RV64IMF => true
    | RV64IAF => true
    | RV64IMAF => true
    | _ => false
    end.

Definition opcode_LOAD : Opcode :=
  3.

Definition opcode_LOAD_FP : Opcode :=
  7.

Definition opcode_MISC_MEM : Opcode :=
  15.

Definition opcode_OP_IMM : Opcode :=
  19.

Definition opcode_AUIPC : Opcode :=
  23.

Definition opcode_OP_IMM_32 : Opcode :=
  27.

Definition opcode_STORE : Opcode :=
  35.

Definition opcode_STORE_FP : Opcode :=
  39.

Definition opcode_AMO : Opcode :=
  47.

Definition opcode_OP : Opcode :=
  51.

Definition opcode_LUI : Opcode :=
  55.

Definition opcode_OP_32 : Opcode :=
  59.

Definition opcode_MADD : Opcode :=
  67.

Definition opcode_MSUB : Opcode :=
  71.

Definition opcode_NMSUB : Opcode :=
  75.

Definition opcode_NMADD : Opcode :=
  79.

Definition opcode_OP_FP : Opcode :=
  83.

Definition opcode_BRANCH : Opcode :=
  99.

Definition opcode_JALR : Opcode :=
  103.

Definition opcode_JAL : Opcode :=
  111.

Definition opcode_SYSTEM : Opcode :=
  115.

Definition funct3_LB : Utility.Utility.MachineInt :=
  0.

Definition funct3_LH : Utility.Utility.MachineInt :=
  1.

Definition funct3_LW : Utility.Utility.MachineInt :=
  2.

Definition funct3_LD : Utility.Utility.MachineInt :=
  3.

Definition funct3_LBU : Utility.Utility.MachineInt :=
  4.

Definition funct3_LHU : Utility.Utility.MachineInt :=
  5.

Definition funct3_LWU : Utility.Utility.MachineInt :=
  6.

Definition funct3_FENCE : Utility.Utility.MachineInt :=
  0.

Definition funct3_FENCE_I : Utility.Utility.MachineInt :=
  1.

Definition funct3_ADDI : Utility.Utility.MachineInt :=
  0.

Definition funct3_SLLI : Utility.Utility.MachineInt :=
  1.

Definition funct3_SLTI : Utility.Utility.MachineInt :=
  2.

Definition funct3_SLTIU : Utility.Utility.MachineInt :=
  3.

Definition funct3_XORI : Utility.Utility.MachineInt :=
  4.

Definition funct3_SRLI : Utility.Utility.MachineInt :=
  5.

Definition funct3_SRAI : Utility.Utility.MachineInt :=
  5.

Definition funct3_ORI : Utility.Utility.MachineInt :=
  6.

Definition funct3_ANDI : Utility.Utility.MachineInt :=
  7.

Definition funct6_SLLI : Utility.Utility.MachineInt :=
  0.

Definition funct6_SRLI : Utility.Utility.MachineInt :=
  0.

Definition funct6_SRAI : Utility.Utility.MachineInt :=
  16.

Definition funct3_ADDIW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SLLIW : Utility.Utility.MachineInt :=
  1.

Definition funct7_SLLIW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRLIW : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRLIW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRAIW : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRAIW : Utility.Utility.MachineInt :=
  32.

Definition funct3_SB : Utility.Utility.MachineInt :=
  0.

Definition funct3_SH : Utility.Utility.MachineInt :=
  1.

Definition funct3_SW : Utility.Utility.MachineInt :=
  2.

Definition funct3_SD : Utility.Utility.MachineInt :=
  3.

Definition funct3_ADD : Utility.Utility.MachineInt :=
  0.

Definition funct7_ADD : Utility.Utility.MachineInt :=
  0.

Definition funct3_SUB : Utility.Utility.MachineInt :=
  0.

Definition funct7_SUB : Utility.Utility.MachineInt :=
  32.

Definition funct3_SLL : Utility.Utility.MachineInt :=
  1.

Definition funct7_SLL : Utility.Utility.MachineInt :=
  0.

Definition funct3_SLT : Utility.Utility.MachineInt :=
  2.

Definition funct7_SLT : Utility.Utility.MachineInt :=
  0.

Definition funct3_SLTU : Utility.Utility.MachineInt :=
  3.

Definition funct7_SLTU : Utility.Utility.MachineInt :=
  0.

Definition funct3_XOR : Utility.Utility.MachineInt :=
  4.

Definition funct7_XOR : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRL : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRL : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRA : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRA : Utility.Utility.MachineInt :=
  32.

Definition funct3_OR : Utility.Utility.MachineInt :=
  6.

Definition funct7_OR : Utility.Utility.MachineInt :=
  0.

Definition funct3_AND : Utility.Utility.MachineInt :=
  7.

Definition funct7_AND : Utility.Utility.MachineInt :=
  0.

Definition funct3_MUL : Utility.Utility.MachineInt :=
  0.

Definition funct7_MUL : Utility.Utility.MachineInt :=
  1.

Definition funct3_MULH : Utility.Utility.MachineInt :=
  1.

Definition funct7_MULH : Utility.Utility.MachineInt :=
  1.

Definition funct3_MULHSU : Utility.Utility.MachineInt :=
  2.

Definition funct7_MULHSU : Utility.Utility.MachineInt :=
  1.

Definition funct3_MULHU : Utility.Utility.MachineInt :=
  3.

Definition funct7_MULHU : Utility.Utility.MachineInt :=
  1.

Definition funct3_DIV : Utility.Utility.MachineInt :=
  4.

Definition funct7_DIV : Utility.Utility.MachineInt :=
  1.

Definition funct3_DIVU : Utility.Utility.MachineInt :=
  5.

Definition funct7_DIVU : Utility.Utility.MachineInt :=
  1.

Definition funct3_REM : Utility.Utility.MachineInt :=
  6.

Definition funct7_REM : Utility.Utility.MachineInt :=
  1.

Definition funct3_REMU : Utility.Utility.MachineInt :=
  7.

Definition funct7_REMU : Utility.Utility.MachineInt :=
  1.

Definition funct3_ADDW : Utility.Utility.MachineInt :=
  0.

Definition funct7_ADDW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SUBW : Utility.Utility.MachineInt :=
  0.

Definition funct7_SUBW : Utility.Utility.MachineInt :=
  32.

Definition funct3_SLLW : Utility.Utility.MachineInt :=
  1.

Definition funct7_SLLW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRLW : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRLW : Utility.Utility.MachineInt :=
  0.

Definition funct3_SRAW : Utility.Utility.MachineInt :=
  5.

Definition funct7_SRAW : Utility.Utility.MachineInt :=
  32.

Definition funct3_MULW : Utility.Utility.MachineInt :=
  0.

Definition funct7_MULW : Utility.Utility.MachineInt :=
  1.

Definition funct3_DIVW : Utility.Utility.MachineInt :=
  4.

Definition funct7_DIVW : Utility.Utility.MachineInt :=
  1.

Definition funct3_DIVUW : Utility.Utility.MachineInt :=
  5.

Definition funct7_DIVUW : Utility.Utility.MachineInt :=
  1.

Definition funct3_REMW : Utility.Utility.MachineInt :=
  6.

Definition funct7_REMW : Utility.Utility.MachineInt :=
  1.

Definition funct3_REMUW : Utility.Utility.MachineInt :=
  7.

Definition funct7_REMUW : Utility.Utility.MachineInt :=
  1.

Definition funct3_BEQ : Utility.Utility.MachineInt :=
  0.

Definition funct3_BNE : Utility.Utility.MachineInt :=
  1.

Definition funct3_BLT : Utility.Utility.MachineInt :=
  4.

Definition funct3_BGE : Utility.Utility.MachineInt :=
  5.

Definition funct3_BLTU : Utility.Utility.MachineInt :=
  6.

Definition funct3_BGEU : Utility.Utility.MachineInt :=
  7.

Definition funct3_JALR : Utility.Utility.MachineInt :=
  0.

Definition funct3_PRIV : Utility.Utility.MachineInt :=
  0.

Definition funct12_ECALL : Utility.Utility.MachineInt :=
  0.

Definition funct12_EBREAK : Utility.Utility.MachineInt :=
  1.

Definition funct12_URET : Utility.Utility.MachineInt :=
  2.

Definition funct12_SRET : Utility.Utility.MachineInt :=
  258.

Definition funct12_MRET : Utility.Utility.MachineInt :=
  770.

Definition funct12_WFI : Utility.Utility.MachineInt :=
  261.

Definition funct7_SFENCE_VMA : Utility.Utility.MachineInt :=
  9.

Definition funct3_CSRRW : Utility.Utility.MachineInt :=
  1.

Definition funct3_CSRRS : Utility.Utility.MachineInt :=
  2.

Definition funct3_CSRRC : Utility.Utility.MachineInt :=
  3.

Definition funct3_CSRRWI : Utility.Utility.MachineInt :=
  5.

Definition funct3_CSRRSI : Utility.Utility.MachineInt :=
  6.

Definition funct3_CSRRCI : Utility.Utility.MachineInt :=
  7.

Definition funct3_AMOW : Utility.Utility.MachineInt :=
  2.

Definition funct3_AMOD : Utility.Utility.MachineInt :=
  3.

Definition funct5_LR : Utility.Utility.MachineInt :=
  2.

Definition funct5_SC : Utility.Utility.MachineInt :=
  3.

Definition funct5_AMOSWAP : Utility.Utility.MachineInt :=
  1.

Definition funct5_AMOADD : Utility.Utility.MachineInt :=
  0.

Definition funct5_AMOXOR : Utility.Utility.MachineInt :=
  4.

Definition funct5_AMOAND : Utility.Utility.MachineInt :=
  12.

Definition funct5_AMOOR : Utility.Utility.MachineInt :=
  8.

Definition funct5_AMOMIN : Utility.Utility.MachineInt :=
  16.

Definition funct5_AMOMAX : Utility.Utility.MachineInt :=
  20.

Definition funct5_AMOMINU : Utility.Utility.MachineInt :=
  24.

Definition funct5_AMOMAXU : Utility.Utility.MachineInt :=
  28.

Definition funct3_FLW : Utility.Utility.MachineInt :=
  2 : Utility.Utility.MachineInt.

Definition funct3_FSW : Utility.Utility.MachineInt :=
  2 : Utility.Utility.MachineInt.

Definition funct7_FADD_S : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition funct7_FSUB_S : Utility.Utility.MachineInt :=
  4 : Utility.Utility.MachineInt.

Definition funct7_FMUL_S : Utility.Utility.MachineInt :=
  8 : Utility.Utility.MachineInt.

Definition funct7_FDIV_S : Utility.Utility.MachineInt :=
  12 : Utility.Utility.MachineInt.

Definition funct7_FSQRT_S : Utility.Utility.MachineInt :=
  44 : Utility.Utility.MachineInt.

Definition funct7_FSGNJ_S : Utility.Utility.MachineInt :=
  16 : Utility.Utility.MachineInt.

Definition funct7_FMIN_S : Utility.Utility.MachineInt :=
  20 : Utility.Utility.MachineInt.

Definition funct7_FCVT_W_S : Utility.Utility.MachineInt :=
  96 : Utility.Utility.MachineInt.

Definition funct7_FMV_X_W : Utility.Utility.MachineInt :=
  112 : Utility.Utility.MachineInt.

Definition funct7_FEQ_S : Utility.Utility.MachineInt :=
  80 : Utility.Utility.MachineInt.

Definition funct7_FCLASS_S : Utility.Utility.MachineInt :=
  112 : Utility.Utility.MachineInt.

Definition funct7_FCVT_S_W : Utility.Utility.MachineInt :=
  104 : Utility.Utility.MachineInt.

Definition funct7_FMV_W_X : Utility.Utility.MachineInt :=
  120 : Utility.Utility.MachineInt.

Definition funct3_FSGNJ_S : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition funct3_FSGNJN_S : Utility.Utility.MachineInt :=
  1 : Utility.Utility.MachineInt.

Definition funct3_FSGNJX_S : Utility.Utility.MachineInt :=
  2 : Utility.Utility.MachineInt.

Definition funct3_FMIN_S : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition funct3_FMAX_S : Utility.Utility.MachineInt :=
  1 : Utility.Utility.MachineInt.

Definition funct3_FMV_X_W : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition funct3_FEQ_S : Utility.Utility.MachineInt :=
  2 : Utility.Utility.MachineInt.

Definition funct3_FLT_S : Utility.Utility.MachineInt :=
  1 : Utility.Utility.MachineInt.

Definition funct3_FLE_S : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition funct3_FCLASS_S : Utility.Utility.MachineInt :=
  1 : Utility.Utility.MachineInt.

Definition rs2_FCVT_W_S : Utility.Utility.MachineInt :=
  0 : Utility.Utility.MachineInt.

Definition rs2_FCVT_WU_S : Utility.Utility.MachineInt :=
  1 : Utility.Utility.MachineInt.

Definition rs2_FCVT_L_S : Utility.Utility.MachineInt :=
  2 : Utility.Utility.MachineInt.

Definition rs2_FCVT_LU_S : Utility.Utility.MachineInt :=
  3 : Utility.Utility.MachineInt.

Definition funct2_FMADD_S : Utility.Utility.MachineInt :=
  0.

Definition isValidI : InstructionI -> bool :=
  fun inst => match inst with | InvalidI => false | _ => true end.

Definition isValidI64 : InstructionI64 -> bool :=
  fun inst => match inst with | InvalidI64 => false | _ => true end.

Definition isValidM : InstructionM -> bool :=
  fun inst => match inst with | InvalidM => false | _ => true end.

Definition isValidM64 : InstructionM64 -> bool :=
  fun inst => match inst with | InvalidM64 => false | _ => true end.

Definition isValidA : InstructionA -> bool :=
  fun inst => match inst with | InvalidA => false | _ => true end.

Definition isValidA64 : InstructionA64 -> bool :=
  fun inst => match inst with | InvalidA64 => false | _ => true end.

Definition isValidF : InstructionF -> bool :=
  fun inst => match inst with | InvalidF => false | _ => true end.

Definition isValidF64 : InstructionF64 -> bool :=
  fun inst => match inst with | InvalidF64 => false | _ => true end.

Definition isValidCSR : InstructionCSR -> bool :=
  fun inst => match inst with | InvalidCSR => false | _ => true end.

(* Skipping definition `Spec.Decode.head_default' *)

(* Skipping definition `Spec.Decode.isAmbiguous' *)

Definition decode
   : InstructionSet -> Utility.Utility.MachineInt -> Instruction :=
  fun iset inst =>
    let aqrl := Utility.Utility.bitSlice inst 25 27 in
    let funct5 := Utility.Utility.bitSlice inst 27 32 in
    let zimm := Utility.Utility.bitSlice inst 15 20 in
    let funct6 := Utility.Utility.bitSlice inst 26 32 in
    let shamtHi := Utility.Utility.bitSlice inst 25 26 in
    let shamtHiTest := orb (Z.eqb shamtHi 0) (Z.eqb (bitwidth iset) 64) in
    let shamt6 :=
      Utility.Utility.machineIntToShamt (Utility.Utility.bitSlice inst 20 26) in
    let shamt5 :=
      Utility.Utility.machineIntToShamt (Utility.Utility.bitSlice inst 20 25) in
    let sbimm12 :=
      Utility.Utility.signExtend 13 (Z.lor (Z.lor (Z.lor (Z.shiftl
                                                          (Utility.Utility.bitSlice inst 31 32) 12) (Z.shiftl
                                                          (Utility.Utility.bitSlice inst 25 31) 5)) (Z.shiftl
                                                   (Utility.Utility.bitSlice inst 8 12) 1)) (Z.shiftl
                                            (Utility.Utility.bitSlice inst 7 8) 11)) in
    let simm12 :=
      Utility.Utility.signExtend 12 (Z.lor (Z.shiftl (Utility.Utility.bitSlice inst 25
                                                      32) 5) (Utility.Utility.bitSlice inst 7 12)) in
    let csr12 := Utility.Utility.bitSlice inst 20 32 in
    let oimm12 :=
      Utility.Utility.signExtend 12 (Utility.Utility.bitSlice inst 20 32) in
    let imm12 :=
      Utility.Utility.signExtend 12 (Utility.Utility.bitSlice inst 20 32) in
    let jimm20 :=
      Utility.Utility.signExtend 21 (Z.lor (Z.lor (Z.lor (Z.shiftl
                                                          (Utility.Utility.bitSlice inst 31 32) 20) (Z.shiftl
                                                          (Utility.Utility.bitSlice inst 21 31) 1)) (Z.shiftl
                                                   (Utility.Utility.bitSlice inst 20 21) 11)) (Z.shiftl
                                            (Utility.Utility.bitSlice inst 12 20) 12)) in
    let oimm20 :=
      Utility.Utility.signExtend 32 (Z.shiftl (Utility.Utility.bitSlice inst 12 32)
                                              12) in
    let imm20 :=
      Utility.Utility.signExtend 32 (Z.shiftl (Utility.Utility.bitSlice inst 12 32)
                                              12) in
    let msb4 := Utility.Utility.bitSlice inst 28 32 in
    let pred := Utility.Utility.bitSlice inst 24 28 in
    let succ := Utility.Utility.bitSlice inst 20 24 in
    let funct2 := Utility.Utility.bitSlice inst 25 27 in
    let rs3 := Utility.Utility.bitSlice inst 27 32 in
    let rs2 := Utility.Utility.bitSlice inst 20 25 in
    let rs1 := Utility.Utility.bitSlice inst 15 20 in
    let rd := Utility.Utility.bitSlice inst 7 12 in
    let funct12 := Utility.Utility.bitSlice inst 20 32 in
    let funct10 :=
      Z.lor (Z.shiftl (Utility.Utility.bitSlice inst 25 32) 3)
            (Utility.Utility.bitSlice inst 12 15) in
    let funct7 := Utility.Utility.bitSlice inst 25 32 in
    let funct3 := Utility.Utility.bitSlice inst 12 15 in
    let rm := funct3 in
    let opcode := Utility.Utility.bitSlice inst 0 7 in
    let decodeI :=
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LB) : bool
      then Lb rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LH) : bool
      then Lh rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LW) : bool
      then Lw rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LBU) : bool
      then Lbu rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LHU) : bool
      then Lhu rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_MISC_MEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                             funct3_FENCE) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                                  msb4 0)))) : bool
      then Fence pred succ else
      if andb (Z.eqb opcode opcode_MISC_MEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                             funct3_FENCE_I) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                                    imm12 0)))) : bool
      then Fence_i else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_ADDI) : bool
      then Addi rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_SLTI) : bool
      then Slti rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_SLTIU) : bool
      then Sltiu rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_XORI) : bool
      then Xori rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_ORI) : bool
      then Ori rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (Z.eqb funct3 funct3_ANDI) : bool
      then Andi rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM) (andb (Z.eqb funct3 funct3_SLLI) (andb
                                                  (Z.eqb funct6 funct6_SLLI) shamtHiTest)) : bool
      then Slli rd rs1 shamt6 else
      if andb (Z.eqb opcode opcode_OP_IMM) (andb (Z.eqb funct3 funct3_SRLI) (andb
                                                  (Z.eqb funct6 funct6_SRLI) shamtHiTest)) : bool
      then Srli rd rs1 shamt6 else
      if andb (Z.eqb opcode opcode_OP_IMM) (andb (Z.eqb funct3 funct3_SRAI) (andb
                                                  (Z.eqb funct6 funct6_SRAI) shamtHiTest)) : bool
      then Srai rd rs1 shamt6 else
      if Z.eqb opcode opcode_AUIPC : bool then Auipc rd oimm20 else
      if andb (Z.eqb opcode opcode_STORE) (Z.eqb funct3 funct3_SB) : bool
      then Sb rs1 rs2 simm12 else
      if andb (Z.eqb opcode opcode_STORE) (Z.eqb funct3 funct3_SH) : bool
      then Sh rs1 rs2 simm12 else
      if andb (Z.eqb opcode opcode_STORE) (Z.eqb funct3 funct3_SW) : bool
      then Sw rs1 rs2 simm12 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_ADD) (Z.eqb funct7
                                                                              funct7_ADD)) : bool
      then Add rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SUB) (Z.eqb funct7
                                                                              funct7_SUB)) : bool
      then Sub rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SLL) (Z.eqb funct7
                                                                              funct7_SLL)) : bool
      then Sll rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SLT) (Z.eqb funct7
                                                                              funct7_SLT)) : bool
      then Slt rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SLTU) (Z.eqb funct7
                                                                               funct7_SLTU)) : bool
      then Sltu rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_XOR) (Z.eqb funct7
                                                                              funct7_XOR)) : bool
      then Xor rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SRL) (Z.eqb funct7
                                                                              funct7_SRL)) : bool
      then Srl rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_SRA) (Z.eqb funct7
                                                                              funct7_SRA)) : bool
      then Sra rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_OR) (Z.eqb funct7
                                                                             funct7_OR)) : bool
      then Or rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_AND) (Z.eqb funct7
                                                                              funct7_AND)) : bool
      then And rd rs1 rs2 else
      if Z.eqb opcode opcode_LUI : bool then Lui rd imm20 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BEQ) : bool
      then Beq rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BNE) : bool
      then Bne rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BLT) : bool
      then Blt rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BGE) : bool
      then Bge rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BLTU) : bool
      then Bltu rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_BRANCH) (Z.eqb funct3 funct3_BGEU) : bool
      then Bgeu rs1 rs2 sbimm12 else
      if andb (Z.eqb opcode opcode_JALR) (Z.eqb funct3 funct3_JALR) : bool
      then Jalr rd rs1 oimm12 else
      if Z.eqb opcode opcode_JAL : bool then Jal rd jimm20 else
      InvalidI in
    let decodeM :=
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_MUL) (Z.eqb funct7
                                                                              funct7_MUL)) : bool
      then Mul rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_MULH) (Z.eqb funct7
                                                                               funct7_MULH)) : bool
      then Mulh rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_MULHSU) (Z.eqb
                                              funct7 funct7_MULHSU)) : bool
      then Mulhsu rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_MULHU) (Z.eqb funct7
                                                                                funct7_MULHU)) : bool
      then Mulhu rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_DIV) (Z.eqb funct7
                                                                              funct7_DIV)) : bool
      then Div rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_DIVU) (Z.eqb funct7
                                                                               funct7_DIVU)) : bool
      then Divu rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_REM) (Z.eqb funct7
                                                                              funct7_REM)) : bool
      then Rem rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP) (andb (Z.eqb funct3 funct3_REMU) (Z.eqb funct7
                                                                               funct7_REMU)) : bool
      then Remu rd rs1 rs2 else
      InvalidM in
    let decodeA :=
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (andb (Z.eqb
                                                                                funct5 funct5_LR) (Z.eqb rs2 0))) : bool
      then Lr_w rd rs1 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_SC)) : bool
      then Sc_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOSWAP)) : bool
      then Amoswap_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOADD)) : bool
      then Amoadd_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOXOR)) : bool
      then Amoxor_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOAND)) : bool
      then Amoand_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOOR)) : bool
      then Amoor_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOMIN)) : bool
      then Amomin_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOMAX)) : bool
      then Amomax_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOMINU)) : bool
      then Amominu_w rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOW) (Z.eqb funct5
                                                                                funct5_AMOMAXU)) : bool
      then Amomaxu_w rd rs1 rs2 aqrl else
      InvalidA in
    let decodeF :=
      if andb (Z.eqb opcode opcode_LOAD_FP) (Z.eqb funct3 funct3_FLW) : bool
      then Flw rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_STORE_FP) (Z.eqb funct3 funct3_FSW) : bool
      then Fsw rs1 rs2 simm12 else
      if andb (Z.eqb opcode opcode_MADD) (Z.eqb funct2 funct2_FMADD_S) : bool
      then Fmadd_s rd rs1 rs2 rs3 rm else
      if andb (Z.eqb opcode opcode_MSUB) (Z.eqb funct2 funct2_FMADD_S) : bool
      then Fmsub_s rd rs1 rs2 rs3 rm else
      if andb (Z.eqb opcode opcode_NMSUB) (Z.eqb funct2 funct2_FMADD_S) : bool
      then Fnmsub_s rd rs1 rs2 rs3 rm else
      if andb (Z.eqb opcode opcode_NMADD) (Z.eqb funct2 funct2_FMADD_S) : bool
      then Fnmadd_s rd rs1 rs2 rs3 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (Z.eqb funct7 funct7_FADD_S) : bool
      then Fadd_s rd rs1 rs2 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (Z.eqb funct7 funct7_FSUB_S) : bool
      then Fsub_s rd rs1 rs2 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (Z.eqb funct7 funct7_FMUL_S) : bool
      then Fmul_s rd rs1 rs2 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (Z.eqb funct7 funct7_FDIV_S) : bool
      then Fdiv_s rd rs1 rs2 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FSQRT_S) (Z.eqb
                                                 rs2 0)) : bool
      then Fsqrt_s rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FSGNJ_S) (Z.eqb
                                                 funct3 funct3_FSGNJ_S)) : bool
      then Fsgnj_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FSGNJ_S) (Z.eqb
                                                 funct3 funct3_FSGNJN_S)) : bool
      then Fsgnjn_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FSGNJ_S) (Z.eqb
                                                 funct3 funct3_FSGNJX_S)) : bool
      then Fsgnjx_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FMIN_S) (Z.eqb
                                                 funct3 funct3_FMIN_S)) : bool
      then Fmin_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FMIN_S) (Z.eqb
                                                 funct3 funct3_FMAX_S)) : bool
      then Fmax_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_W_S) (Z.eqb
                                                 rs2 rs2_FCVT_W_S)) : bool
      then Fcvt_w_s rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_W_S) (Z.eqb
                                                 rs2 rs2_FCVT_WU_S)) : bool
      then Fcvt_wu_s rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FMV_X_W) (andb
                                                 (Z.eqb rs2 0) (Z.eqb funct3 0))) : bool
      then Fmv_x_w rd rs1 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FEQ_S) (Z.eqb
                                                 funct3 funct3_FEQ_S)) : bool
      then Feq_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FEQ_S) (Z.eqb
                                                 funct3 funct3_FLT_S)) : bool
      then Flt_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FEQ_S) (Z.eqb
                                                 funct3 funct3_FLE_S)) : bool
      then Fle_s rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCLASS_S) (andb
                                                 (Z.eqb rs2 0) (Z.eqb funct3 funct3_FCLASS_S))) : bool
      then Fclass_s rd rs1 else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_S_W) (Z.eqb
                                                 rs2 rs2_FCVT_W_S)) : bool
      then Fcvt_s_w rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_S_W) (Z.eqb
                                                 rs2 rs2_FCVT_WU_S)) : bool
      then Fcvt_s_wu rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FMV_W_X) (andb
                                                 (Z.eqb rs2 0) (Z.eqb funct3 0))) : bool
      then Fmv_w_x rd rs1 else
      InvalidF in
    let decodeI64 :=
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LD) : bool
      then Ld rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_LOAD) (Z.eqb funct3 funct3_LWU) : bool
      then Lwu rd rs1 oimm12 else
      if andb (Z.eqb opcode opcode_OP_IMM_32) (Z.eqb funct3 funct3_ADDIW) : bool
      then Addiw rd rs1 imm12 else
      if andb (Z.eqb opcode opcode_OP_IMM_32) (andb (Z.eqb funct3 funct3_SLLIW) (Z.eqb
                                                     funct7 funct7_SLLIW)) : bool
      then Slliw rd rs1 shamt5 else
      if andb (Z.eqb opcode opcode_OP_IMM_32) (andb (Z.eqb funct3 funct3_SRLIW) (Z.eqb
                                                     funct7 funct7_SRLIW)) : bool
      then Srliw rd rs1 shamt5 else
      if andb (Z.eqb opcode opcode_OP_IMM_32) (andb (Z.eqb funct3 funct3_SRAIW) (Z.eqb
                                                     funct7 funct7_SRAIW)) : bool
      then Sraiw rd rs1 shamt5 else
      if andb (Z.eqb opcode opcode_STORE) (Z.eqb funct3 funct3_SD) : bool
      then Sd rs1 rs2 simm12 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_ADDW) (Z.eqb
                                                 funct7 funct7_ADDW)) : bool
      then Addw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_SUBW) (Z.eqb
                                                 funct7 funct7_SUBW)) : bool
      then Subw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_SLLW) (Z.eqb
                                                 funct7 funct7_SLLW)) : bool
      then Sllw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_SRLW) (Z.eqb
                                                 funct7 funct7_SRLW)) : bool
      then Srlw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_SRAW) (Z.eqb
                                                 funct7 funct7_SRAW)) : bool
      then Sraw rd rs1 rs2 else
      InvalidI64 in
    let decodeM64 :=
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_MULW) (Z.eqb
                                                 funct7 funct7_MULW)) : bool
      then Mulw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_DIVW) (Z.eqb
                                                 funct7 funct7_DIVW)) : bool
      then Divw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_DIVUW) (Z.eqb
                                                 funct7 funct7_DIVUW)) : bool
      then Divuw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_REMW) (Z.eqb
                                                 funct7 funct7_REMW)) : bool
      then Remw rd rs1 rs2 else
      if andb (Z.eqb opcode opcode_OP_32) (andb (Z.eqb funct3 funct3_REMUW) (Z.eqb
                                                 funct7 funct7_REMUW)) : bool
      then Remuw rd rs1 rs2 else
      InvalidM64 in
    let decodeA64 :=
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (andb (Z.eqb
                                                                                funct5 funct5_LR) (Z.eqb rs2 0))) : bool
      then Lr_d rd rs1 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_SC)) : bool
      then Sc_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOSWAP)) : bool
      then Amoswap_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOADD)) : bool
      then Amoadd_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOXOR)) : bool
      then Amoxor_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOAND)) : bool
      then Amoand_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOOR)) : bool
      then Amoor_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOMIN)) : bool
      then Amomin_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOMAX)) : bool
      then Amomax_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOMINU)) : bool
      then Amominu_d rd rs1 rs2 aqrl else
      if andb (Z.eqb opcode opcode_AMO) (andb (Z.eqb funct3 funct3_AMOD) (Z.eqb funct5
                                                                                funct5_AMOMAXU)) : bool
      then Amomaxu_d rd rs1 rs2 aqrl else
      InvalidA64 in
    let decodeF64 :=
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_W_S) (Z.eqb
                                                 rs2 rs2_FCVT_L_S)) : bool
      then Fcvt_l_s rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_W_S) (Z.eqb
                                                 rs2 rs2_FCVT_LU_S)) : bool
      then Fcvt_lu_s rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_S_W) (Z.eqb
                                                 rs2 rs2_FCVT_L_S)) : bool
      then Fcvt_s_l rd rs1 rm else
      if andb (Z.eqb opcode opcode_OP_FP) (andb (Z.eqb funct7 funct7_FCVT_S_W) (Z.eqb
                                                 rs2 rs2_FCVT_LU_S)) : bool
      then Fcvt_s_lu rd rs1 rm else
      InvalidF64 in
    let decodeCSR :=
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (Z.eqb funct7
                                                                                               funct7_SFENCE_VMA))) : bool
      then Sfence_vma rs1 rs2 else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_ECALL)))) : bool
      then Ecall else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_EBREAK)))) : bool
      then Ebreak else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_URET)))) : bool
      then Uret else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_SRET)))) : bool
      then Sret else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_MRET)))) : bool
      then Mret else
      if andb (Z.eqb opcode opcode_SYSTEM) (andb (Z.eqb rd 0) (andb (Z.eqb funct3
                                                                           funct3_PRIV) (andb (Z.eqb rs1 0) (Z.eqb
                                                                                               funct12
                                                                                               funct12_WFI)))) : bool
      then Wfi else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRW) : bool
      then Csrrw rd rs1 csr12 else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRS) : bool
      then Csrrs rd rs1 csr12 else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRC) : bool
      then Csrrc rd rs1 csr12 else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRWI) : bool
      then Csrrwi rd zimm csr12 else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRSI) : bool
      then Csrrsi rd zimm csr12 else
      if andb (Z.eqb opcode opcode_SYSTEM) (Z.eqb funct3 funct3_CSRRCI) : bool
      then Csrrci rd zimm csr12 else
      InvalidCSR in
    let resultCSR :=
      if isValidCSR decodeCSR : bool
      then cons (CSRInstruction decodeCSR) nil
      else nil in
    let resultF64 :=
      if isValidF64 decodeF64 : bool
      then cons (F64Instruction decodeF64) nil
      else nil in
    let resultA64 :=
      if isValidA64 decodeA64 : bool
      then cons (A64Instruction decodeA64) nil
      else nil in
    let resultM64 :=
      if isValidM64 decodeM64 : bool
      then cons (M64Instruction decodeM64) nil
      else nil in
    let resultI64 :=
      if isValidI64 decodeI64 : bool
      then cons (I64Instruction decodeI64) nil
      else nil in
    let resultF :=
      if isValidF decodeF : bool
      then cons (FInstruction decodeF) nil
      else nil in
    let resultA :=
      if isValidA decodeA : bool
      then cons (AInstruction decodeA) nil
      else nil in
    let resultM :=
      if isValidM decodeM : bool
      then cons (MInstruction decodeM) nil
      else nil in
    let resultI :=
      if isValidI decodeI : bool
      then cons (IInstruction decodeI) nil
      else nil in
    let results : list Instruction :=
      Coq.Init.Datatypes.app resultI (Coq.Init.Datatypes.app (if supportsM iset : bool
                                                              then resultM
                                                              else nil) (Coq.Init.Datatypes.app (if supportsA
                                                                                                    iset : bool
                                                                                                 then resultA
                                                                                                 else nil)
                                                                                                (Coq.Init.Datatypes.app
                                                                                                 (if supportsF
                                                                                                     iset : bool
                                                                                                  then resultF
                                                                                                  else nil)
                                                                                                 (Coq.Init.Datatypes.app
                                                                                                  (if Z.eqb (bitwidth
                                                                                                             iset)
                                                                                                            64 : bool
                                                                                                   then resultI64
                                                                                                   else nil)
                                                                                                  (Coq.Init.Datatypes.app
                                                                                                   (if andb (Z.eqb
                                                                                                             (bitwidth
                                                                                                              iset) 64)
                                                                                                            (supportsM
                                                                                                             iset) : bool
                                                                                                    then resultM64
                                                                                                    else nil)
                                                                                                   (Coq.Init.Datatypes.app
                                                                                                    (if andb (Z.eqb
                                                                                                              (bitwidth
                                                                                                               iset) 64)
                                                                                                             (supportsA
                                                                                                              iset) : bool
                                                                                                     then resultA64
                                                                                                     else nil)
                                                                                                    (Coq.Init.Datatypes.app
                                                                                                     (if andb (Z.eqb
                                                                                                               (bitwidth
                                                                                                                iset)
                                                                                                               64)
                                                                                                              (supportsF
                                                                                                               iset) : bool
                                                                                                      then resultF64
                                                                                                      else nil)
                                                                                                     resultCSR))))))) in
    if Z.gtb (Z.of_nat (Coq.Lists.List.length results)) 1 : bool
    then InvalidInstruction inst
    else Coq.Lists.List.nth O results (InvalidInstruction inst).

(* External variables:
     FPRegister O Opcode Register RoundMode Z Z.eqb Z.gtb Z.lor Z.of_nat Z.shiftl
     andb bool cons false list nil orb true Coq.Init.Datatypes.app
     Coq.Lists.List.length Coq.Lists.List.nth Utility.Utility.MachineInt
     Utility.Utility.bitSlice Utility.Utility.machineIntToShamt
     Utility.Utility.signExtend
*)

Definition Mtriv (x : Type) := x.
Definition trivialBind (A B : Type) (x : Mtriv A) (f : A -> B) : Mtriv B := f x.
Definition trivialReturn (A : Type) (a : A) : Mtriv A := a.
Print Monad.
Lemma trivial_left_identity : forall (A B : Type) (a : A) (f : A -> Mtriv B), trivialBind A B (trivialReturn A a) f = f a.
Proof. trivial. Qed.
Lemma trivial_right_identity : forall (A : Type) (m : Mtriv A), trivialBind A A m (trivialReturn A) = m.
Proof. trivial. Qed.
Lemma trivial_associativity : forall (A B C : Type) (m : Mtriv A) (f : A -> Mtriv B) (g : B -> Mtriv C), trivialBind B C (trivialBind A B m f) g = trivialBind A C m (fun x : A => trivialBind B C (f x) g).
Proof. trivial. Qed.
Check @leakage_of_instr.
Definition trivialMonad : Monad Mtriv :=
  {| Bind := trivialBind; Return := trivialReturn; left_identity := trivial_left_identity; right_identity := trivial_right_identity; associativity := trivial_associativity |}.
Definition concrete_leakage_of_instr {width} {BW: Bitwidth width} {word: word.word width} := @leakage_of_instr Mtriv trivialMonad width BW word.
