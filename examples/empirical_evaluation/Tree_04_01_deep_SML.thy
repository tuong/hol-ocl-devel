theory Tree_04_01_deep_SML imports  "../../src/compiler/OCL_compiler_generator_dynamic" begin
generation_syntax [ deep
                      (generation_semantics [ analysis (*, oid_start 10*) ])
                      skip_export
                      (THEORY Tree_04_01_generated_SML)
                      (IMPORTS ["../../../src/UML_Main", "../../../src/compiler/OCL_compiler_static"]
                               "../../../src/compiler/OCL_compiler_generator_dynamic")
                      SECTION
                      [ in SML module_name M (no_signatures) ]
                      (output_directory "./doc") ]

Class Aazz End
Class Bbyy End
Class Ccxx End
Class Ddww End

(* 4 *)

generation_syntax deep flush_all


end
