*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

*** SOF ./modules/30_biomass/magpie_40/presolve.gms

*** Calcualte total primary energy to limit BECCS (see q30_limitTeBio)
*** This must be calculated outside the optimization and stored in a 
*** parameter so as not to create an incentive to increase the total
*** PE demand just to increase the BECCS limit (see also presolve.gms).
*** Using the substitution method to adjust vm_ prodSE from non-fossil
*** energy sources to the primary energy inputs that would be needed
*** if it was generated from fossil fuels. 

p30_demPe(ttot,regi) =
  sum(pe2se(enty,enty2,te)$(sameas(enty,"peoil") OR sameas(enty,"pecoal") OR sameas(enty,"pegas") OR sameas(enty,"pebiolc") OR sameas(enty,"pebios") OR sameas(enty,"pebioil")),
    vm_demPe.l(ttot,regi,enty,enty2,te)
  ) 
  + sum(entySe,
      sum(te,
          vm_prodSe.l(ttot,regi,"pegeo",entySe,te)
        + vm_prodSe.l(ttot,regi,"pehyd",entySe,te)
        + vm_prodSe.l(ttot,regi,"pewin",entySe,te)
        + vm_prodSe.l(ttot,regi,"pesol",entySe,te)
        + vm_prodSe.l(ttot,regi,"peur",entySe,te)
      )
    ) * 100/40  !!! substitution method
;


*** EOF ./modules/30_biomass/magpie_40/presolve.gms
