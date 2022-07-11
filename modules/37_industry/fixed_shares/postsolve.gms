*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/postsolve.gms

*** calculation of FE Industry Prices (useful for internal use and reporting 
*** purposes)
pm_FEPrice(ttot,regi,entyFE,"indst",emiMkt)$( abs(qm_budget.m(ttot,regi)) gt sm_eps )
  = q37_demFeIndst.m(ttot,regi,entyFE,emiMkt)
  / qm_budget.m(ttot,regi);


*** calculate reporting parameters for FE per subsector and SE origin to make R 
*** reporting easier

*** FE per subsector and energy carrier for fixed_shares
*** note: this does not split the energy carriers correctly across emissions 
*** markets following secInd37_emiMkt as the FE share of subsectors p37_shIndFE
*** is only defined for total FE not FE per emissions market.
*** A correct split is done in the subsectors realization.
o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt) 
  = sum(fe2ppfEn37(entyFe,in), p37_shIndFE(regi,in,secInd37)) 
  * vm_demFeSector.l(ttot,regi,entySe,entyFe,"indst",emiMkt);
  
*** FE per subsector whose emissions can be captured (helper parameter for 
*** calculation of industry captured CO2 below)
o37_demFeIndSub_SecCC(ttot,regi,secInd37) 
  = sum((se2fe(entySe,entyFe,te),macBaseInd37(entyFe,secInd37),
                                 sector2emiMkt("indst",emiMkt)), 
      o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt)
    );

*** industry captured CO2
pm_IndstCO2Captured(ttot,regi,entySe,entyFe,secInd37,emiMkt)$(
                        entyFeCC37(entyFe) AND o37_demFeIndSub_SecCC(ttot,regi,secInd37)
                         AND macBaseInd37(entyFe,secInd37)) 
  = sum( secInd37_2_emiInd37(secInd37,emiInd37)$(emiInd37_fuel(emiInd37)), 
      vm_emiIndCCS.l(ttot,regi,emiInd37)
      )
  * o37_demFeIndSub(ttot,regi,entySe,entyFe,secInd37,emiMkt) 
  / o37_demFeIndSub_SecCC(ttot,regi,secInd37);

*** EOF ./modules/37_industry/fixed_shares/postsolve.gms
