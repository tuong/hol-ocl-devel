(*****************************************************************************
 * Featherweight-OCL --- A Formal Semantics for UML-OCL Version OCL 2.4
 *                       for the OMG Standard.
 *                       http://www.brucker.ch/projects/hol-testgen/
 *
 * OCL_state.thy --- State Operations and Objects.
 * This file is part of HOL-TestGen.
 *
 * Copyright (c) 2012-2013 Université Paris-Sud, France
 *               2013      IRT SystemX, France
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

header{* Part III: State Operations and Objects *}

theory OCL_state
imports OCL_lib
begin

section{* Complex Types: The Object Type (I) Core *}
subsection{* Recall: The generic structure of States *}

text{* Next we will introduce the foundational concept of an object id (oid),
which is just some infinite set.

\begin{isar}
type_synonym oid = nat
\end{isar}

 States are pair of a partial map from oid's to elements of an object universe @{text "'\<AA>"}
--- the heap --- and a map to relations of objects. The relations were encoded as lists of
pairs in order to leave the possibility to have Bags, OrderedSets or Sequences as association
ends.  *}
text{* Recall:
\begin{isar}
record ('\<AA>)state =
             heap   :: "oid \<rightharpoonup> '\<AA> "
             assocs :: "oid  \<rightharpoonup> (oid \<times> oid) list"


type_synonym ('\<AA>)st = "'\<AA> state \<times> '\<AA> state"
\end{isar}

Now we refine our state-interface.
In certain contexts, we will require that the elements of the object universe have
a particular structure; more precisely, we will require that there is a function that
reconstructs the oid of an object in the state (we will settle the question how to define
this function later). *}

class object =  fixes oid_of :: "'a \<Rightarrow> oid"

text{* Thus, if needed, we can constrain the object universe to objects by adding
the following type class constraint:*}
typ "'\<AA> :: object"

instantiation   option  :: (object)object
begin
   definition oid_of_option_def: "oid_of x = oid_of (the x)"
   instance ..
end

section{* Fundamental Predicates on Object: Strict Equality *}
subsection{* Definition *}

text{* Generic referential equality - to be used for instantiations
 with concrete object types ... *}
definition  StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t :: "('\<AA>,'a::{object,null})val \<Rightarrow> ('\<AA>,'a)val \<Rightarrow> ('\<AA>)Boolean"
where      "StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x y
            \<equiv> \<lambda> \<tau>. if (\<upsilon> x) \<tau> = true \<tau> \<and> (\<upsilon> y) \<tau> = true \<tau>
                    then if x \<tau> = null \<or> y \<tau> = null
                         then \<lfloor>\<lfloor>x \<tau> = null \<and> y \<tau> = null\<rfloor>\<rfloor>
                         else \<lfloor>\<lfloor>(oid_of (x \<tau>)) = (oid_of (y \<tau>)) \<rfloor>\<rfloor>
                    else invalid \<tau>"

subsection{* Logic and Algebraic Layer on Object *}
subsubsection{* Validity and Definedness Properties *}

text{* We derive the usual laws on definedness for (generic) object equality:*}
lemma StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_defargs:
"\<tau> \<Turnstile> (StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x (y::('\<AA>,'a::{null,object})val))\<Longrightarrow> (\<tau> \<Turnstile>(\<upsilon> x)) \<and> (\<tau> \<Turnstile>(\<upsilon> y))"
by(simp add: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def OclValid_def true_def invalid_def bot_option_def
        split: bool.split_asm HOL.split_if_asm)


subsubsection{* Symmetry *}

lemma StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_sym : assumes x_val : "\<tau> \<Turnstile> \<upsilon> x" shows "\<tau> \<Turnstile> StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x x"
by(simp add: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def true_def OclValid_def x_val[simplified OclValid_def])

subsubsection{* Execution with invalid or null as argument *}

lemma StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_strict1[simp] :
"(StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x invalid) = invalid"
by(rule ext, simp add: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def true_def false_def)

lemma StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_strict2[simp] :
"(StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t invalid x) = invalid"
by(rule ext, simp add: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def true_def false_def)

subsubsection{* Context Passing *}

lemma cp_StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t:
"(StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x y \<tau>) = (StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t (\<lambda>_. x \<tau>) (\<lambda>_. y \<tau>)) \<tau>"
by(auto simp: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def cp_valid[symmetric])

lemmas cp_intro''[simp,intro!] =
       cp_intro''
       cp_StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t[THEN allI[THEN allI[THEN allI[THEN cpI2]],
             of "StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t"]]

subsubsection{* Behavior vs StrongEq *}

text{* A key-concept for linking strict referential equality to
       logical equality: in well-formed states (i.e. those
       states where the self (oid-of) field contains the pointer
       to which the object is associated to in the state),
       referential equality coincides with logical equality. *}

definition WFF :: "('\<AA>::object)st \<Rightarrow> bool"
where "WFF \<tau> = ((\<forall> x \<in> ran(heap(fst \<tau>)). \<lceil>heap(fst \<tau>) (oid_of x)\<rceil> = x) \<and>
                (\<forall> x \<in> ran(heap(snd \<tau>)). \<lceil>heap(snd \<tau>) (oid_of x)\<rceil> = x))"

text{* This is a generic definition of referential equality:
Equality on objects in a state is reduced to equality on the
references to these objects. As in HOL-OCL, we will store
the reference of an object inside the object in a (ghost) field.
By establishing certain invariants ("consistent state"), it can
be assured that there is a "one-to-one-correspondance" of objects
to their references --- and therefore the definition below
behaves as we expect. *}
text{* Generic Referential Equality enjoys the usual properties:
(quasi) reflexivity, symmetry, transitivity, substitutivity for
defined values. For type-technical reasons, for each concrete
object type, the equality @{text "\<doteq>"} is defined by generic referential
equality. *}

theorem StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_vs_StrongEq:
"WFF \<tau> \<Longrightarrow> \<tau> \<Turnstile>(\<upsilon> x) \<Longrightarrow> \<tau> \<Turnstile>(\<upsilon> y) \<Longrightarrow>
(x \<tau> \<in> ran (heap(fst \<tau>)) \<and> y \<tau> \<in> ran (heap(fst \<tau>))) \<and>
(x \<tau> \<in> ran (heap(snd \<tau>)) \<and> y \<tau> \<in> ran (heap(snd \<tau>))) \<Longrightarrow> (* x and y must be object representations
                                                          that exist in either the pre or post state *)
           (\<tau> \<Turnstile> (StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t x y)) = (\<tau> \<Turnstile> (x \<triangleq> y))"
apply(auto simp: StrictRefEq\<^sub>O\<^sub>b\<^sub>j\<^sub>e\<^sub>c\<^sub>t_def OclValid_def WFF_def StrongEq_def true_def Ball_def)
apply(erule_tac x="x \<tau>" in allE', simp_all)
done

text{* So, if two object descriptions live in the same state (both pre or post), the referential
equality on objects implies in a WFF state the logical equality. Uffz. *}

section{* Complex Types: The Object Type (II) Library *}
subsection{* Initial States (for Testing and Code Generation) *}

definition \<tau>\<^sub>0 :: "('\<AA>)st"
where     "\<tau>\<^sub>0 \<equiv> (\<lparr>heap=Map.empty, assocs\<^sub>2= Map.empty, assocs\<^sub>3= Map.empty\<rparr>,
                 \<lparr>heap=Map.empty, assocs\<^sub>2= Map.empty, assocs\<^sub>3= Map.empty\<rparr>)"

subsection{* OclAllInstances *}

text{* In order to denote OCL-types occuring in OCL expressions syntactically --- as, for example,
as "argument" of allInstances --- we use the inverses of the injection functions into the object
universes; we show that this is sufficient "characterization". *}

definition [simp]: "OclAllInstances = (\<lambda> fst_snd H \<tau>.
                 Abs_Set_0 \<lfloor>\<lfloor> Some ` ((H ` ran (heap (fst_snd \<tau>))) - { None }) \<rfloor>\<rfloor>)"

definition OclAllInstances_at_post :: "('\<AA> \<Rightarrow> '\<alpha> option) \<Rightarrow> ('\<AA> :: object, '\<alpha> option option) Set"
                           ("_ .allInstances'(')")
where  "OclAllInstances_at_post H \<tau> = OclAllInstances snd H \<tau>"

definition OclAllInstances_at_pre :: "('\<AA> \<Rightarrow> '\<alpha> option) \<Rightarrow> ('\<AA> ::object, '\<alpha> option option) Set"
                           ("_ .allInstances@pre'(')")
where  "OclAllInstances_at_pre H \<tau> = OclAllInstances fst H \<tau>"

lemma OclAllInstances_defined: "\<tau> \<Turnstile> \<delta> (X .allInstances())"
 apply(simp add: defined_def OclValid_def OclAllInstances_at_post_def bot_fun_def bot_Set_0_def null_fun_def null_Set_0_def false_def true_def)
 apply(rule conjI)
 apply(rule notI, subst (asm) Abs_Set_0_inject, simp)
 apply(rule disjI2)+
  apply (metis bot_option_def option.distinct(1))
 apply(simp add: bot_option_def)+

 apply(rule notI, subst (asm) Abs_Set_0_inject, simp)
 apply(rule disjI2)+
  apply (metis bot_option_def option.distinct(1))
 apply(simp add: bot_option_def null_option_def)+
done

lemma "\<tau>\<^sub>0 \<Turnstile> H .allInstances() \<triangleq> Set{}"
by(simp add: StrongEq_def OclAllInstances_at_post_def OclValid_def \<tau>\<^sub>0_def mtSet_def)


lemma "\<tau>\<^sub>0 \<Turnstile> H .allInstances@pre() \<triangleq> Set{}"
by(simp add: StrongEq_def OclAllInstances_at_pre_def OclValid_def \<tau>\<^sub>0_def mtSet_def)

lemma state_update_vs_allInstances_empty:
shows   "(Type .allInstances())
         (\<sigma>, \<lparr>heap=empty, assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)
         =
         Set{}
         (\<sigma>, \<lparr>heap=empty, assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)"
by(simp add: OclAllInstances_at_post_def mtSet_def)

lemma state_update_vs_allInstances_including':
assumes "\<And>x. \<sigma>' oid = Some x \<Longrightarrow> x = Object"
    and "Type Object \<noteq> None"
  shows "(Type .allInstances())
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)
         =
         ((Type .allInstances())->including(\<lambda> _. \<lfloor>\<lfloor> drop (Type Object) \<rfloor>\<rfloor>))
         (\<sigma>, \<lparr>heap=\<sigma>',assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)"
proof -
 have allinst_def : "(\<sigma>, \<lparr>heap = \<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>) \<Turnstile> (\<delta> (Type .allInstances()))"
  apply(simp add: defined_def OclValid_def bot_fun_def null_fun_def bot_Set_0_def null_Set_0_def OclAllInstances_at_post_def)
  apply(subst (1 2) Abs_Set_0_inject)
 by(simp add: bot_option_def null_option_def)+

 have drop_none : "\<And>x. x \<noteq> None \<Longrightarrow> \<lfloor>\<lceil>x\<rceil>\<rfloor> = x"
 by(case_tac x, simp+)

 have insert_diff : "\<And>x S. insert \<lfloor>x\<rfloor> (S - {None}) = (insert \<lfloor>x\<rfloor> S) - {None}"
 by (metis insert_Diff_if option.distinct(1) singletonE)

 show ?thesis
  apply(simp add: OclIncluding_def allinst_def[simplified OclValid_def] OclAllInstances_at_post_def)
  apply(subst Abs_Set_0_inverse, simp add: bot_option_def, simp add: comp_def)
  apply(subst image_insert[symmetric])
  apply(subst drop_none, simp add: assms)
  apply(case_tac "Type Object", simp add: assms, simp only:)
  apply(subst insert_diff, drule sym, simp)
  apply(subgoal_tac "ran (\<sigma>'(oid \<mapsto> Object)) = insert Object (ran \<sigma>')", simp)
  apply(case_tac "\<not> (\<exists>x. \<sigma>' oid = Some x)")
  apply(rule ran_map_upd, simp)
  apply(simp, erule exE, frule assms, simp)
  apply(subgoal_tac "Object \<in> ran \<sigma>'") prefer 2
  apply(rule ranI, simp)
  apply(subst insert_absorb, simp)
 by (metis fun_upd_apply)
qed


lemma state_update_vs_allInstances_including:
assumes "\<And>x. \<sigma>' oid = Some x \<Longrightarrow> x = Object"
    and "Type Object \<noteq> None"
shows   "(Type .allInstances())
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)
         =
         ((\<lambda>_. (Type .allInstances()) (\<sigma>, \<lparr>heap=\<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>))->including(\<lambda> _. \<lfloor>\<lfloor> drop (Type Object) \<rfloor>\<rfloor>))
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)"
proof -
 have allinst_def : "(\<sigma>, \<lparr>heap = \<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>) \<Turnstile> (\<delta> (Type .allInstances()))"
  apply(simp add: defined_def OclValid_def bot_fun_def null_fun_def bot_Set_0_def null_Set_0_def OclAllInstances_at_post_def)
  apply(subst (1 2) Abs_Set_0_inject)
 by(simp add: bot_option_def null_option_def)+

 show ?thesis

  apply(subst state_update_vs_allInstances_including', (simp add: assms)+)
  apply(subst cp_OclIncluding)
  apply(simp add: OclIncluding_def)
  apply(subst (1 3) cp_defined[symmetric], simp add: allinst_def[simplified OclValid_def])

  apply(simp add: defined_def OclValid_def bot_fun_def null_fun_def bot_Set_0_def null_Set_0_def OclAllInstances_at_post_def)
  apply(subst (1 3) Abs_Set_0_inject)
 by(simp add: bot_option_def null_option_def)+
qed



lemma state_update_vs_allInstances_noincluding':
assumes "\<And>x. \<sigma>' oid = Some x \<Longrightarrow> x = Object"
    and "Type Object = None"
  shows "(Type .allInstances())
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)
         =
         (Type .allInstances())
         (\<sigma>, \<lparr>heap=\<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)"
proof -
 have allinst_def : "(\<sigma>, \<lparr>heap = \<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>) \<Turnstile> (\<delta> (Type .allInstances()))"
  apply(simp add: defined_def OclValid_def bot_fun_def null_fun_def bot_Set_0_def null_Set_0_def OclAllInstances_at_post_def)
  apply(subst (1 2) Abs_Set_0_inject)
 by(simp add: bot_option_def null_option_def)+

 have drop_none : "\<And>x. x \<noteq> None \<Longrightarrow> \<lfloor>\<lceil>x\<rceil>\<rfloor> = x"
 by(case_tac x, simp+)

 have insert_diff : "\<And>x S. insert \<lfloor>x\<rfloor> (S - {None}) = (insert \<lfloor>x\<rfloor> S) - {None}"
 by (metis insert_Diff_if option.distinct(1) singletonE)

 show ?thesis
  apply(simp add: OclIncluding_def allinst_def[simplified OclValid_def] OclAllInstances_at_post_def)
  apply(subgoal_tac "ran (\<sigma>'(oid \<mapsto> Object)) = insert Object (ran \<sigma>')", simp add: assms)
  apply(case_tac "\<not> (\<exists>x. \<sigma>' oid = Some x)")
  apply(rule ran_map_upd, simp)
  apply(simp, erule exE, frule assms, simp)
  apply(subgoal_tac "Object \<in> ran \<sigma>'") prefer 2
  apply(rule ranI, simp)
  apply(subst insert_absorb, simp)
 by (metis fun_upd_apply)
qed


lemma state_update_vs_allInstances_noincluding:
assumes "\<And>x. \<sigma>' oid = Some x \<Longrightarrow> x = Object"
    and "Type Object = None"
shows   "(Type .allInstances())
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)
         =
         (\<lambda>_. (Type .allInstances()) (\<sigma>, \<lparr>heap=\<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>))
         (\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>)"
by(subst state_update_vs_allInstances_noincluding', (simp add: assms)+)

theorem state_update_vs_allInstances:
assumes "oid\<notin>dom \<sigma>'"
and     "cp P"
shows   "((\<sigma>, \<lparr>heap=\<sigma>'(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>) \<Turnstile> (P(Type .allInstances()))) =
         ((\<sigma>, \<lparr>heap=\<sigma>', assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>) \<Turnstile> (P((Type .allInstances())->including(\<lambda> _. \<lfloor>\<lfloor> drop (Type Object) \<rfloor>\<rfloor>)))) "
proof -
 have P_cp : "\<And>x \<tau>. P x \<tau> = P (\<lambda>_. x \<tau>) \<tau>"
 by (metis (full_types) assms(2) cp_def)
oops

theorem state_update_vs_allInstances_at_pre:
assumes "oid\<notin>dom \<sigma>"
and     "cp P"
shows   "((\<lparr>heap=\<sigma>(oid\<mapsto>Object), assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>, \<sigma>') \<Turnstile> (P(Type .allInstances@pre()))) =
          ((\<lparr>heap=\<sigma>, assocs\<^sub>2=A, assocs\<^sub>3=B\<rparr>, \<sigma>') \<Turnstile> (P((Type .allInstances@pre())->including(\<lambda> _. \<lfloor>\<lfloor>drop (Type Object)\<rfloor>\<rfloor>)))) "
oops

subsection{* OclIsNew *}

definition OclIsNew:: "('\<AA>, '\<alpha>::{null,object})val \<Rightarrow> ('\<AA>)Boolean"   ("(_).oclIsNew'(')")
where "X .oclIsNew() \<equiv> (\<lambda>\<tau> . if (\<delta> X) \<tau> = true \<tau>
                              then \<lfloor>\<lfloor>oid_of (X \<tau>) \<notin> dom(heap(fst \<tau>)) \<and>
                                     oid_of (X \<tau>) \<in> dom(heap(snd \<tau>))\<rfloor>\<rfloor>
                              else invalid \<tau>)"

text{* The following predicates --- which are not part of the OCL standard descriptions ---
complete the goal of oclIsNew() by describing where an object belongs.
*}

definition OclIsOld:: "('\<AA>, '\<alpha>::{null,object})val \<Rightarrow> ('\<AA>)Boolean"   ("(_).oclIsOld'(')")
where "X .oclIsOld() \<equiv> (\<lambda>\<tau> . if (\<delta> X) \<tau> = true \<tau>
                              then \<lfloor>\<lfloor>oid_of (X \<tau>) \<in> dom(heap(fst \<tau>)) \<and>
                                     oid_of (X \<tau>) \<notin> dom(heap(snd \<tau>))\<rfloor>\<rfloor>
                              else invalid \<tau>)"

definition OclIsMaintained:: "('\<AA>, '\<alpha>::{null,object})val \<Rightarrow> ('\<AA>)Boolean"   ("(_).oclIsMaintained'(')")
where "X .oclIsMaintained() \<equiv> (\<lambda>\<tau> . if (\<delta> X) \<tau> = true \<tau>
                              then \<lfloor>\<lfloor>oid_of (X \<tau>) \<in> dom(heap(fst \<tau>)) \<and>
                                     oid_of (X \<tau>) \<in> dom(heap(snd \<tau>))\<rfloor>\<rfloor>
                              else invalid \<tau>)"

definition OclIsAbsent:: "('\<AA>, '\<alpha>::{null,object})val \<Rightarrow> ('\<AA>)Boolean"   ("(_).oclIsAbsent'(')")
where "X .oclIsAbsent() \<equiv> (\<lambda>\<tau> . if (\<delta> X) \<tau> = true \<tau>
                              then \<lfloor>\<lfloor>oid_of (X \<tau>) \<notin> dom(heap(fst \<tau>)) \<and>
                                     oid_of (X \<tau>) \<notin> dom(heap(snd \<tau>))\<rfloor>\<rfloor>
                              else invalid \<tau>)"

lemma state_split : "\<tau> \<Turnstile> \<delta> X \<Longrightarrow> \<tau> \<Turnstile> (X .oclIsNew()) \<or> \<tau> \<Turnstile> (X .oclIsOld()) \<or> \<tau> \<Turnstile> (X .oclIsMaintained()) \<or> \<tau> \<Turnstile> (X .oclIsAbsent())"
by(simp add: OclIsOld_def OclIsNew_def OclIsMaintained_def OclIsAbsent_def
             OclValid_def true_def, blast)

lemma notNew_vs_others : "\<tau> \<Turnstile> \<delta> X \<Longrightarrow> (\<not> \<tau> \<Turnstile> (X .oclIsNew())) = (\<tau> \<Turnstile> (X .oclIsOld()) \<or> \<tau> \<Turnstile> (X .oclIsMaintained()) \<or> \<tau> \<Turnstile> (X .oclIsAbsent()))"
by(simp add: OclIsOld_def OclIsNew_def OclIsMaintained_def OclIsAbsent_def
                OclNot_def OclValid_def true_def, blast)

subsection{* OclIsModifiedOnly *}

text{* The following predicate --- which is not part of the OCL standard descriptions ---
provides a simple, but powerful means to describe framing conditions. For any formal
approach, be it animation of OCL contracts, test-case generation or die-hard theorem
proving, the specification of the part of a system transistion that DOES NOT CHANGE
is of premordial importance. The following operator establishes the equality between
old and new objects in the state (provided that they exist in both states), with the
exception of those objects
*}

definition OclIsModifiedOnly ::"('\<AA>::object,'\<alpha>::{null,object})Set \<Rightarrow> '\<AA> Boolean"
                        ("_->oclIsModifiedOnly'(')")
where "X->oclIsModifiedOnly() \<equiv> (\<lambda>(\<sigma>,\<sigma>').  let  X' = (oid_of ` \<lceil>\<lceil>Rep_Set_0(X(\<sigma>,\<sigma>'))\<rceil>\<rceil>);
                                                 S = ((dom (heap \<sigma>) \<inter> dom (heap \<sigma>')) - X')
                                            in if (\<delta> X) (\<sigma>,\<sigma>') = true (\<sigma>,\<sigma>')
                                               then \<lfloor>\<lfloor>\<forall> x \<in> S. (heap \<sigma>) x = (heap \<sigma>') x\<rfloor>\<rfloor>
                                               else invalid (\<sigma>,\<sigma>'))"

lemma cp_OclIsModifiedOnly : "X->oclIsModifiedOnly() \<tau> = (\<lambda>_. X \<tau>)->oclIsModifiedOnly() \<tau>"
by(simp only: OclIsModifiedOnly_def, case_tac \<tau>, simp only:, subst cp_defined, simp)

definition [simp]: "OclSelf x H fst_snd = (\<lambda>\<tau> . if (\<delta> x) \<tau> = true \<tau>
                        then if oid_of (x \<tau>) \<in> dom(heap(fst \<tau>)) \<and> oid_of (x \<tau>) \<in> dom(heap (snd \<tau>))
                             then  H \<lceil>(heap(fst_snd \<tau>))(oid_of (x \<tau>))\<rceil>
                             else invalid \<tau>
                        else invalid \<tau>)"

definition OclSelf_at_pre :: "('\<AA>::object,'\<alpha>::{null,object})val \<Rightarrow>
                      ('\<AA> \<Rightarrow> '\<alpha>) \<Rightarrow>
                      ('\<AA>::object,'\<alpha>::{null,object})val" ("(_)@pre(_)")
where "x @pre H = OclSelf x H fst"

definition OclSelf_at_post :: "('\<AA>::object,'\<alpha>::{null,object})val \<Rightarrow>
                      ('\<AA> \<Rightarrow> '\<alpha>) \<Rightarrow>
                      ('\<AA>::object,'\<alpha>::{null,object})val" ("(_)@post(_)")
where "x @post H = OclSelf x H snd"

theorem framing:
      assumes modifiesclause:"\<tau> \<Turnstile> (X->excluding(x :: ('\<AA>::object,'\<alpha>::{null,object})val))->oclIsModifiedOnly()"
      and    represented_x: "\<tau> \<Turnstile> \<delta>(x @pre (H::('\<AA> \<Rightarrow> '\<alpha>)))"
      and oid_is_typerepr : "inj_on (oid_of :: '\<alpha> \<Rightarrow> _) (insert (x \<tau>) \<lceil>\<lceil>Rep_Set_0 (X \<tau>)\<rceil>\<rceil>)"
      shows "\<tau> \<Turnstile> (x @pre H  \<triangleq>  (x @post H))"
proof -
 have def_x : "\<tau> \<Turnstile> \<delta> x"
 by(insert represented_x, simp add: defined_def OclValid_def null_fun_def bot_fun_def false_def true_def OclSelf_at_pre_def invalid_def split: split_if_asm)
 show ?thesis
  apply(simp add:StrongEq_def OclValid_def true_def OclSelf_at_pre_def OclSelf_at_post_def def_x[simplified OclValid_def])
  apply(rule conjI, rule impI)
  apply(rule_tac f = "\<lambda>x. H \<lceil>x\<rceil>" in arg_cong)
  apply(insert modifiesclause[simplified OclIsModifiedOnly_def OclValid_def])
  apply(case_tac \<tau>, rename_tac \<sigma> \<sigma>', simp split: split_if_asm)
  apply(simp add: OclExcluding_def)
  apply(drule foundation5[simplified OclValid_def true_def], simp)
  apply(subst (asm) Abs_Set_0_inverse, simp)
  apply(rule disjI2)+
  apply (metis (hide_lams, no_types) DiffD1 OclValid_def Set_inv_lemma def_x foundation16 foundation18')
  apply(simp)
  apply(erule_tac x = "oid_of (x (\<sigma>, \<sigma>'))" in ballE) apply simp
  apply(subst (asm) inj_on_image_set_diff[where C = "insert (x (\<sigma>, \<sigma>')) \<lceil>\<lceil>Rep_Set_0 (X (\<sigma>, \<sigma>'))\<rceil>\<rceil>"], simp add: oid_is_typerepr)
  apply (metis (hide_lams, no_types) inj_on_insert oid_is_typerepr)
  apply (metis subset_insertI)
  apply(simp add: invalid_def bot_option_def)+

  apply(blast)
 done
qed
(*
theorem framing':
      assumes modifiesclause:"\<tau> \<Turnstile> (X->excluding(x :: ('\<AA>::object,'\<alpha>::{null,object})val))->oclIsModifiedOnly()"
      and    represented_x: "\<tau> \<Turnstile> \<delta>(x @pre (H::('\<AA> \<Rightarrow> '\<alpha>)))"
      and oid_is_typerepr : "WFF \<tau>"
      shows "\<tau> \<Turnstile> (x @pre H  \<triangleq>  (x @post H))"
apply(rule framing[OF modifiesclause represented_x])
apply(insert oid_is_typerepr, simp add: WFF_def)
sorry
*)
lemma pre_post_new: "\<tau> \<Turnstile> (x .oclIsNew()) \<Longrightarrow> \<not> (\<tau> \<Turnstile> \<upsilon>(x @pre H1)) \<and> \<not> (\<tau> \<Turnstile> \<upsilon>(x @post H2))"
by(simp add: OclIsNew_def OclSelf_at_pre_def OclSelf_at_post_def
             OclValid_def StrongEq_def true_def false_def
             bot_option_def invalid_def bot_fun_def valid_def
      split: split_if_asm)

lemma pre_post_old: "\<tau> \<Turnstile> (x .oclIsOld()) \<Longrightarrow> \<not> (\<tau> \<Turnstile> \<upsilon>(x @pre H1)) \<and> \<not> (\<tau> \<Turnstile> \<upsilon>(x @post H2))"
by(simp add: OclIsOld_def OclSelf_at_pre_def OclSelf_at_post_def
             OclValid_def StrongEq_def true_def false_def
             bot_option_def invalid_def bot_fun_def valid_def
      split: split_if_asm)

lemma pre_post_absent: "\<tau> \<Turnstile> (x .oclIsAbsent()) \<Longrightarrow> \<not> (\<tau> \<Turnstile> \<upsilon>(x @pre H1)) \<and> \<not> (\<tau> \<Turnstile> \<upsilon>(x @post H2))"
by(simp add: OclIsAbsent_def OclSelf_at_pre_def OclSelf_at_post_def
             OclValid_def StrongEq_def true_def false_def
             bot_option_def invalid_def bot_fun_def valid_def
      split: split_if_asm)

lemma pre_post_maintained: "(\<tau> \<Turnstile> \<upsilon>(x @pre H1) \<or> \<tau> \<Turnstile> \<upsilon>(x @post H2)) \<Longrightarrow> \<tau> \<Turnstile> (x .oclIsMaintained())"
by(simp add: OclIsMaintained_def OclSelf_at_pre_def OclSelf_at_post_def
             OclValid_def StrongEq_def true_def false_def
             bot_option_def invalid_def bot_fun_def valid_def
      split: split_if_asm)

lemma pre_post_maintained': "\<tau> \<Turnstile> (x .oclIsMaintained()) \<Longrightarrow> (\<tau> \<Turnstile> \<upsilon>(x @pre (Some o H1)) \<and> \<tau> \<Turnstile> \<upsilon>(x @post (Some o H2)))"
by(simp add: OclIsMaintained_def OclSelf_at_pre_def OclSelf_at_post_def
             OclValid_def StrongEq_def true_def false_def
             bot_option_def invalid_def bot_fun_def valid_def
      split: split_if_asm)

lemma framing_same_state: "(\<sigma>, \<sigma>) \<Turnstile> (x @pre H  \<triangleq>  (x @post H))"
by(simp add: OclSelf_at_pre_def OclSelf_at_post_def OclValid_def StrongEq_def)

end
