*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/postsolve.gms

*** calculation of FE Industry Prices (useful for internal use and reporting 
*** purposes)
pm_FEPrice(ttot,regi,entyFE,"indst",emiMkt)$( abs(qm_budget.m(ttot,regi)) gt sm_eps )
  = q37_demFeIndst.m(ttot,regi,entyFE,emiMkt)
  / qm_budget.m(ttot,regi);

*** calculate reporting parameters for FE per subsector and SE origin to make R
*** reporting easier
*** total FE per energy carrier and emissions market in industry (sum over
*** subsectors)
o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt)
  = sum((fe2ppfEn37(entyFe,in),secInd37_2_pf(secInd37,in),
                         secInd37_emiMkt(secInd37,emiMkt)),
      (vm_cesIO.l(ttot,regi,in)
      +pm_cesdata(ttot,regi,in,"offset_quantity"))
    );

*** share of subsector in FE industry energy carriers and emissions markets
o37_shIndFE(ttot,regi,entyFe,secInd37,emiMkt)$(
                                    o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt) )
  = sum(( fe2ppfEn37(entyFe,in),
          secInd37_2_pf(secInd37,in),
          secInd37_emiMkt(secInd37,emiMkt)),
      (vm_cesIO.l(ttot,regi,in)
      +pm_cesdata(ttot,regi,in,"offset_quantity"))
    )
  / o37_demFeIndTotEn(ttot,regi,entyFe,emiMkt);


*** FE per subsector and energy carriers
o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt)
  = sum(secInd37_emiMkt(secInd37,emiMkt),
      o37_shIndFE(ttot,regi,entyFe,secInd37,emiMkt)
    * vm_demFeSector_afterTax.l(ttot,regi,entySe,entyFe,"indst",emiMkt)
  );

*** industry captured fuel CO2
pm_IndstCO2Captured(ttot,regi,entySE,entyFE(entyFEcc37),secInd37,emiMkt)$(
                     macBaseInd37(entyFE,secInd37)
                 AND sum(entyFE2, vm_macBaseInd.l(ttot,regi,entyFE2,secInd37)) )
  = ( o37_demFEindsub(ttot,regi,entySE,entyFE,secInd37,emiMkt)
    * sum(se2fe(entySE2,entyFE,te),
        !! collapse entySE dimension, so emission factors apply to all entyFE
	!! regardless or origin, and therefore entySEbio and entySEsyn have
	!! non-zero emission factors
        pm_emifac(ttot,regi,entySE2,entyFE,te,"co2")
      )
    ) !! subsector emissions (smokestack, i.e. including biomass & synfuels)

  * ( sum(secInd37_2_emiInd37(secInd37,emiInd37(emiInd37_fuel)),
        vm_emiIndCCS.l(ttot,regi,emiInd37)
      ) !! subsector captured energy emissions

    / sum(entyFE2,
        vm_macBaseInd.l(ttot,regi,entyFE2,secInd37)
      ) !! subsector total energy emissions
    ) !! subsector capture share
;

*** EOF ./modules/37_industry/subsectors/postsolve.gms
