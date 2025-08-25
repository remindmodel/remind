*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/80_optimization/nash/presolve.gms

*** AJS TODO: this is non-optimal: in summing over regi2, we'd like to keep the last known optimal value.
*** To achieve that, param0 should not be overwritten in core/presolve.gms - we'd have to make p80_repynoninfes an interface.
loop(regi $ (pm_SolNonInfes(regi) = 1),
  loop(ttot $ (ttot.val >= 2005),
    pm_cumEff(ttot,regi,in)
      = sum(regi2 $ (not sameas(regi,regi2) and pm_SolNonInfes(regi2) = 1),
          pm_cesdata("2005",regi2,in,"eff") * vm_effGr.l(ttot,regi2,in)); !! TODO: take care of the case of infeasible solution

    pm_co2eqForeign(ttot,regi)
      = sum(regi2 $ (not sameas(regi,regi2)), pm_co2eq0(ttot,regi2)); !! does this interfere with the initialization in datainput?

    pm_emissionsForeign(ttot,regi,enty)
      = sum(regi2 $ (not sameas(regi,regi2)), pm_emissions0(ttot,regi2,enty));

    pm_fuExtrForeign(ttot,regi,enty,rlf)
      = sum(regi2 $ (not sameas(regi,regi2)), vm_fuExtr.l(ttot,regi2,enty,rlf));

    pm_capCumForeign(ttot,regi,teLearn)
      = sum(regi2 $ (not sameas(regi,regi2)), pm_capCum0(ttot,regi2,teLearn));
  );
*** If cm_LearningSpillover is 0, the foreign capacity in technology learning is fixed to the level of 2020.
*** This simulates a world of protectionism with no further foreign technology learning spillover.
  pm_capCumForeign(ttot,regi,teLearn) $ (ttot.val >= 2025 and cm_LearningSpillover = 0)
    = sum(regi2 $ (not sameas(regi,regi2)), pm_capCum0("2020",regi2,teLearn));
);

display pm_capCumForeign, pm_co2eqForeign, pm_emissionsForeign;
*** EOF ./modules/80_optimization/nash/presolve.gms
