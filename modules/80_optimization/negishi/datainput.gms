*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/negishi/datainput.gms

pm_pvp(ttot,trade)$(ttot.val ge 2005)               = 1;
p80_trade(ttot,regi,trade)$(ttot.val ge 2005)       = 0;

if (cm_emiscen eq 1,
  Execute_Loadpoint "./input.gdx", p80_currentaccount_bau = p80_curracc;
else
  Execute_Loadpoint "./input_ref.gdx", p80_currentaccount_bau = p80_curracc;
);


p80_defic_sum("1") = 1;

*MLB*LB*AJS* This parameter is only relevant for the nash algorithm. 
pm_capCumForeign(t,regi,teLearn) = 0;
pm_cumEff(t,regi,in) = 0;
pm_co2eqForeign(t,regi) = 0;
pm_emissionsForeign(t,regi,enty) = 0;
pm_fuExtrForeign(t,regi,enty,rlf) = 0;

pm_SolNonInfes(regi) = 1; !! assume the starting point came from a feasible solution 

*** EOF ./modules/80_optimization/negishi/datainput.gms
