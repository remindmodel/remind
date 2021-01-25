*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/exogenous/datainput.gms

p31_fix_costfu_ex(tall,regi,enty) = 0;
$include "./modules/31_fossil/exogenous/input/p31_fix_costfu_ex.put";
p31_fix_fuelex(tall,regi,enty,rlf) = 0;
$include "./modules/31_fossil/exogenous/input/p31_fix_fuelex.put";

*LB* preliminary dummy for $ condition in core/equations.gms
p31_grades(regi,"xi3",enty,rlf) = 0.0001;
*** EOF ./modules/31_fossil/exogenous/datainput.gms
