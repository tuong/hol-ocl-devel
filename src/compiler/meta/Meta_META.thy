(*****************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.5
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * Meta_META.thy ---
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2013-2015 Université Paris-Saclay, Univ. Paris-Sud, France
 *               2013-2015 IRT SystemX, France
 *
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 *
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *
 *     * Redistributions in binary form must reproduce the above
 *       copyright notice, this list of conditions and the following
 *       disclaimer in the documentation and/or other materials provided
 *       with the distribution.
 *
 *     * Neither the name of the copyright holders nor the names of its
 *       contributors may be used to endorse or promote products derived
 *       from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 ******************************************************************************)
(* $Id:$ *)

section\<open>Regrouping Together All Existing Meta-Models\<close>

theory  Meta_META
imports Meta_UML
        Meta_UML_extended
        "../../compiler_generic/meta_isabelle/Meta_Isabelle"
begin

subsection\<open>A Basic Meta-Model\<close>

text\<open>The following basic Meta-Model is an empty Meta-Model.\<close>

text\<open>Most of the Meta-Model we have defined (in particular those defined in UML)
     can be used in exceptional situations 
     for requiring an eager or lazy interactive evaluation of already encountered Meta-Models.
     This is also the case for this basic Meta-Model.\<close>

datatype ocl_flush_all = OclFlushAll

subsection\<open>The META Meta-Model (I)\<close>

datatype floor = Floor1 | Floor2 | Floor3 (* NOTE nat can be used *)

text\<open>
Meta-Models can be seen as arranged in a semantic tower with several floors.
By default, @{term Floor1} corresponds to the first level we are situating by default,
then a subsequent meta-evaluation would jump to a deeper floor,
to @{term Floor2}, then @{term Floor3}...\<close>

text\<open>
It is not mandatory to jump to a floor superior than the one we currently are.
The important point is to be sure that all jumps will ultimately terminate.\<close>

(* *)

text\<open>
Most of the following constructors are preceded by an additional
@{typ floor} field, which explicitly indicates the intended associated semantic to consider
during the meta-embedding to Isabelle.
In case no @{typ floor} is precised, we fix it to be @{term Floor1} by default.\<close>

(* le meta-model de "tout le monde" - frederic. *)
datatype all_meta_embedding =
  (* TODO: we can merge Enum and ClassRaw into a common record *)

                              (* USE *)
                              META_enum ocl_enum
                            | META_class_raw floor ocl_class_raw
                            | META_association ocl_association
                            | META_ass_class floor ocl_ass_class
                            | META_ctxt floor ocl_ctxt

                              (* invented *)
                            | META_class_synonym ocl_class_synonym
                            | META_instance ocl_instance
                            | META_def_base_l ocl_def_base_l
                            | META_def_state floor ocl_def_state
                            | META_def_pre_post floor ocl_def_pre_post
                            | META_flush_all ocl_flush_all

subsection\<open>Main Compiling Environment\<close>

text\<open>The environment constitutes the main data-structure carried by all monadic translations.\<close>

datatype generation_semantics_ocl = Gen_only_design | Gen_only_analysis | Gen_default
datatype generation_lemma_mode = Gen_sorry | Gen_no_dirty

record compiler_env_config =  D_output_disable_thy :: bool
                              D_output_header_thy :: "(string (* theory *)
                                                      \<times> string list (* imports *)
                                                      \<times> string (* import optional (compiler bootstrap) *)) option"
                              D_ocl_oid_start :: internal_oids
                              D_output_position :: "nat \<times> nat"
                              D_ocl_semantics :: generation_semantics_ocl
                              D_input_class :: "ocl_class option"
                                               (* last class considered for the generation *)
                              D_input_meta :: "all_meta_embedding list"
                              D_input_instance :: "(string\<^sub>b\<^sub>a\<^sub>s\<^sub>e (* name (as key for rbt) *)
                                                   \<times> ocl_instance_single
                                                   \<times> internal_oids) list"
                                                  (* instance namespace environment *)
                              D_input_state :: "(string\<^sub>b\<^sub>a\<^sub>s\<^sub>e (* name (as key for rbt) *)
                                                \<times> (internal_oids
                                                \<times> (string (* name *)
                                                  \<times> ocl_instance_single (* alias *))
                                                  ocl_def_state_core) list) list"
                                               (* state namespace environment *)
                              D_output_header_force :: bool (* true : the header should import the compiler for bootstrapping *)
                              D_output_auto_bootstrap :: bool (* true : add the generation_syntax command *)
                              D_ocl_accessor :: " string\<^sub>b\<^sub>a\<^sub>s\<^sub>e (* name of the constant added *) list (* pre *)
                                                \<times> string\<^sub>b\<^sub>a\<^sub>s\<^sub>e (* name of the constant added *) list (* post *)"
                              D_ocl_HO_type :: "(string\<^sub>b\<^sub>a\<^sub>s\<^sub>e (* raw HOL name (as key for rbt) *)) list"
                              D_output_sorry_dirty :: "generation_lemma_mode option \<times> bool (* dirty *)" (* Some Gen_sorry or None and {dirty}: activate sorry mode for skipping proofs *)

subsection\<open>Operations of Fold, Map, ..., on the Meta-Model\<close>

definition "ignore_meta_header = (\<lambda> META_class_raw Floor1 _ \<Rightarrow> True
                                  | META_ass_class Floor1 _ \<Rightarrow> True
                                  | META_ctxt Floor1 _ \<Rightarrow> True
                                  | META_def_state Floor1 _ \<Rightarrow> True
                                  | META_def_pre_post Floor1 _ \<Rightarrow> True
                                  | _ \<Rightarrow> False)"

definition "map2_ctxt_term f =
 (let f_prop = \<lambda> OclProp_ctxt n prop \<Rightarrow> OclProp_ctxt n (f prop)
    ; f_inva = \<lambda> T_inv b prop \<Rightarrow> T_inv b (f_prop prop) in
  \<lambda> META_ctxt Floor2 c \<Rightarrow>
    META_ctxt Floor2
      (Ctxt_clause_update
        (L.map (\<lambda> Ctxt_pp pp \<Rightarrow> Ctxt_pp (Ctxt_expr_update (L.map (\<lambda> T_pp pref prop \<Rightarrow> T_pp pref (f_prop prop)
                                                                        | T_invariant inva \<Rightarrow> T_invariant (f_inva inva))) pp)
                   | Ctxt_inv l_inv \<Rightarrow> Ctxt_inv (f_inva l_inv))) c)
  | x \<Rightarrow> x)"

definition "compiler_env_config_more_map f ocl =
            compiler_env_config.extend  (compiler_env_config.truncate ocl) (f (compiler_env_config.more ocl))"

subsection\<open>The META Meta-Model (II)\<close>
subsubsection\<open>Type Definition\<close>

text\<open>
For bootstrapping the environment through the jumps to another semantic floor, we additionally
consider the environment as a Meta-Model.\<close>

datatype boot_generation_syntax = Boot_generation_syntax generation_semantics_ocl
datatype boot_setup_env = Boot_setup_env compiler_env_config

datatype all_meta = (* pure Isabelle *)
                    META_semi__theories semi__theories

                    (* bootstrapping embedded languages *)
                  | META_boot_generation_syntax boot_generation_syntax
                  | META_boot_setup_env boot_setup_env
                  | META_all_meta_embedding all_meta_embedding

text\<open>As remark, the Isabelle Meta-Model represented by @{typ semi__theories} can be merged
with the previous META Meta-Model @{typ all_meta_embedding}. 
However a corresponding parser and printer would then be required.\<close>

subsubsection\<open>Extending the Meta-Model\<close>

locale O (* outer syntax *)
begin
definition "i x = META_semi__theories o Theories_one o x"
definition "datatype = i Theory_datatype"
definition "type_synonym = i Theory_type_synonym"
definition "type_notation = i Theory_type_notation"
definition "instantiation = i Theory_instantiation"
definition "defs = i Theory_defs"
definition "consts = i Theory_consts"
definition "definition = i Theory_definition"
definition "lemmas = i Theory_lemmas"
definition "lemma = i Theory_lemma"
definition "axiomatization = i Theory_axiomatization"
definition "section = i Theory_section"
definition "text = i Theory_text"
definition "ML = i Theory_ML"
definition "setup = i Theory_setup"
definition "thm = i Theory_thm"
definition "interpretation = i Theory_interpretation"
end

lemmas [code] =
  (*def*)
  O.i_def
  O.datatype_def
  O.type_synonym_def
  O.type_notation_def
  O.instantiation_def
  O.defs_def
  O.consts_def
  O.definition_def
  O.lemmas_def
  O.lemma_def
  O.axiomatization_def
  O.section_def
  O.text_def
  O.ML_def
  O.setup_def
  O.thm_def
  O.interpretation_def

locale O'
begin
definition "datatype = Theory_datatype"
definition "type_synonym = Theory_type_synonym"
definition "type_notation = Theory_type_notation"
definition "instantiation = Theory_instantiation"
definition "defs = Theory_defs"
definition "consts = Theory_consts"
definition "definition = Theory_definition"
definition "lemmas = Theory_lemmas"
definition "lemma = Theory_lemma"
definition "axiomatization = Theory_axiomatization"
definition "section = Theory_section"
definition "text = Theory_text"
definition "ML = Theory_ML"
definition "setup = Theory_setup"
definition "thm = Theory_thm"
definition "interpretation = Theory_interpretation"
end

lemmas [code] =
  (*def*)
  O'.datatype_def
  O'.type_synonym_def
  O'.type_notation_def
  O'.instantiation_def
  O'.defs_def
  O'.consts_def
  O'.definition_def
  O'.lemmas_def
  O'.lemma_def
  O'.axiomatization_def
  O'.section_def
  O'.text_def
  O'.ML_def
  O'.setup_def
  O'.thm_def
  O'.interpretation_def

subsubsection\<open>Operations of Fold, Map, ..., on the Meta-Model\<close>

definition "map_semi__theory f = (\<lambda> META_semi__theories (Theories_one x) \<Rightarrow> META_semi__theories (Theories_one (f x))
                                  | META_semi__theories (Theories_locale data l) \<Rightarrow> META_semi__theories (Theories_locale data (L.map (L.map f) l))
                                  | x \<Rightarrow> x)"

end
