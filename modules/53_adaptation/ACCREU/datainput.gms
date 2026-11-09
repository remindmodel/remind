*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF .modules/53_adaptation/ACCREU/datainput.gms

*satisfy dependencies
$ifi not %damages% == 'ACCREU' abort "module adaptation=ACCREU requires module damages=ACCREU";

p53_adapt1(regi) = 0
p53_adapt2(regi) = 0;

*non-SLR 
parameter p53_adaptCoefs(all_regi,adapt_coef_53)	"coefficients for adaptation function, non-SLR" 
/
$ondelim
$include "./modules/53_adaptation/ACCREU/input/nonSLR_combined_Kaj_REMIND_adapt_coefs.inc"
$offdelim
/
;

p53_adapt1(regi)=p53_adaptCoefs(regi,"g1");
p53_adapt2(regi)=p53_adaptCoefs(regi,"g2");


*SLR 
parameter p53_adaptCoefs_SLR(all_regi,adapt_coef_53)	"coefficients for adaptation function, SLR" 
/
$ondelim
$include "./modules/53_adaptation/ACCREU/input/SLR_Kaj_REMIND_adapt_coefs.inc"
$offdelim
/
;

*adaptive capacity
parameter p53_adaptCap(all_regi,ttot)	"adaptive capacity parameters"
/
$ondelim
$include "./modules/53_adaptation/ACCREU/input/governance_REMIND_coefs.inc"
$offdelim
/
;


p53_SLRadapt1(regi) = 0;
p53_SLRadapt2(regi) = 0;

p53_SLRadapt1(regi)=p53_adaptCoefs_SLR(regi,"g1");
p53_SLRadapt2(regi)=p53_adaptCoefs_SLR(regi,"g2");

pm_protectionLevelNonSLR(tall,regi) = 0;
pm_protectionLevelSLR(tall,regi) = 0;

p53_costProtectNonSLR(tall,regi) = 0;
p53_costProtectSLR(tall,regi) = 0;

*default value for effectiveness limit - no limit
s53_effLim = 1;

$ifthen.cm_exoCost %cm_adaCostExogenous% == "on"

$include "./modules/53_adaptation/ACCREU/input/p53_costAdaptNonSLR_exo.inc"
$include "./modules/53_adaptation/ACCREU/input/p53_costAdaptSLR_exo.inc"

if(cm_adaLim =3, 	!!limited adaptation effectiveness
	s53_effLim = 0.5;
);

$endif.cm_exoCost

*** EOF .modules/53_adaptation/ACCREU/datainput.gms
