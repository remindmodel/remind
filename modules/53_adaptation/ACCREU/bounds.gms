*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/53_adaptation/ACCREU/bounds.gms

v53_protectNonSLR.up(tall,regi) = 1;
v53_protectSLR.up(tall,regi) = 1;

*** set to 0 if the costs are read in exogenously
$ifthen.cm_exoCost %cm_adaCostExogenous% == "on"
v53_costProtectSLR.fx(tall,regi) = 0;
v53_costProtectNonSLR.fx(tall,regi) = 0;

if(cm_adaLim = 2,	!!limited adaptation expenditure
	v53_costProtectNonSLR.fx(ttot,regi)=p53_costProtectNonSLR(ttot,regi)*p53_adaptCap(regi,ttot);
	v53_costProtectSLR.fx(ttot,regi)=p53_costProtectSLR(ttot,regi)*p53_adaptCap(regi,ttot);
else
	v53_costProtectNonSLR.fx(ttot,regi)=p53_costProtectNonSLR(ttot,regi);
	v53_costProtectSLR.fx(ttot,regi)=p53_costProtectSLR(ttot,regi);
);
$else.cm_exoCost

v53_costProtectSLR.lo(tall,regi) = 0;
v53_costProtectNonSLR.lo(tall,regi) = 0;

$endif.cm_exoCost

*** EOF ./modules/53_adaptation/ACCREU/bounds.gms
