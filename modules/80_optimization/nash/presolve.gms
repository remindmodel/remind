*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/presolve.gms
*MLB* 12062013* update of learning externality
*MLB 20130920* update of spillover eternality
*ML+LB 20140107* update of climate externality (carbon market)
*LB* 20140506 update of climate externality (link to the climate module)
*AJS* TODO: this is non-optimal: in summing over regi2, we'd like to keep the last known optimal value. To achieve that, param0 should not be overwritten in core/presolve.gms - we'd have to make p80_repynoninfes an interface.  
pm_capCumForeign(ttot,regi,teLearn)$((ttot.val ge 2005) and (pm_SolNonInfes(regi) eq 1)) = sum(regi2$((NOT sameas(regi,regi2))), pm_capCum0(ttot,regi2,teLearn));

pm_cumEff(ttot,regi, in)$(ttot.val ge 2005 and pm_SolNonInfes(regi) eq 1) = sum( regi2$(pm_SolNonInfes(regi2) eq 1), (pm_cesdata("2005",regi2,in,"eff") * vm_effGr.l(ttot,regi2,in))) - (pm_cesdata("2005",regi,in,"eff") * vm_effGr.l(ttot,regi,in)); !! TODO: take care of the case of infeasible solution

pm_co2eqForeign(ttot,regi)$((ttot.val ge 2005) and (pm_SolNonInfes(regi) eq 1)) = sum(regi2$((NOT sameas(regi,regi2))), pm_co2eq0(ttot,regi2)); !! does this interfere with the initialization in datainput?

pm_emissionsForeign(ttot,regi,enty)$((ttot.val ge 2005) and (pm_SolNonInfes(regi) eq 1)) = sum(regi2$((NOT sameas(regi,regi2))), pm_emissions0(ttot,regi2,enty));

pm_fuExtrForeign(ttot,regi,enty,rlf)$((ttot.val ge 2005) and (pm_SolNonInfes(regi) eq 1)) = sum(regi2$((NOT sameas(regi,regi2))), vm_fuExtr.l(ttot,regi2,enty,rlf));

display pm_capCumForeign, pm_co2eqForeign,pm_emissionsForeign;
*** EOF ./modules/80_optimization/nash/presolve.gms
