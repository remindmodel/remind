*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/53_adaptation/ACCREU/declarations.gms

scalars
s53_effLim	"limit to adaptation effectiveness"
;

parameters
p53_adapt1(all_regi)	 "adaptation cost coefficient"
p53_adapt2(all_regi)	 "adaptation cost exponent"

p53_SLRadapt1(all_regi)  "adaptation cost coefficient for SLR"
p53_SLRadapt2(all_regi)  "adaptation cost coefficient 2 for SLR"

pm_protectionLevelNonSLR(tall,all_regi)	"protection level for non-SLR damages"
pm_protectionLevelSLR(tall,all_regi)	"protection level for SLR damages"

p53_costProtectNonSLR(tall,all_regi)	"protection costs for non-SLR damages"
p53_costProtectSLR(tall,all_regi)	"protection costs for SLR damages"
;

positive variables
v53_protectNonSLR(tall,all_regi)	"aggregate protection level"
v53_costProtectNonSLR(tall,all_regi)	"nonSLR protection costs"

v53_protectSLR(tall,all_regi)   "SLR protection level"
v53_costProtectSLR(tall,all_regi)  "SLR protection costs"

vm_damageFactorAdapt(tall,all_regi)	"damage factor after adaptation"
;

equations
q53_adapt(ttot,all_regi)	"calculates final damage factor after adaptation"
q53_adaptNonSLR(ttot,all_regi)	"adaptation cost function for non-SLR damages"
q53_adaptSLR(ttot,all_regi)	"adaptation cost function for SLR damages"
;

*** EOF ./modules/53_adaptation/ACCREU/declarations.gms

