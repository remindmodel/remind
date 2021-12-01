*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/testOneRegi/datainput.gms

pm_w(regi) = 1;

*LB* initialize price parameter, import from gdx in preloop
pm_pvp(ttot,trade)$((ttot.val ge 2005) AND (NOT tradeSe(trade))) = 0;
p80_etaXp(tradePe) = 1;
p80_etaXp("good") = 1;
p80_etaXp("perm") = 1;

*load fallback prices

$include "./modules/80_optimization/testOneRegi/input/prices_NASH.inc";


*MLB 12062013* initialize learning externality (can be improved by including file)
pm_capCumForeign(ttot,regi,teLearn)$(ttot.val ge 2005) = 0;
pm_cumEff(t,regi,in) = 0;
pm_co2eqForeign(t,regi) = 0;
pm_emissionsForeign(t,regi,enty) = 0;
pm_SolNonInfes(regi) = 1; !! assume the starting point came from a feasible solution 
pm_fuExtrForeign(t,regi,enty,rlf) = 0;

*** EOF ./modules/80_optimization/testOneRegi/datainput.gms
