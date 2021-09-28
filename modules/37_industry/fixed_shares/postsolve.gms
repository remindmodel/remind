*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/postsolve.gms

loop (enty$( sameas(enty,"co2") OR sameas(enty,"cco2") ),
  !! prepare industry CCS emissions for post-processing
  o37_emiInd(ttot,regi,entyPe,secInd37,enty)$( ttot.val ge 2005 )
  = sum(secInd37_2_emiInd37(secInd37,emiInd37(emiInd37_fuel)),
      sum(pe2se(entyPE,entySE,te),
        sum(se2fe(entySE,entyFE,te2),
          sum(fe2ppfen(entyFE,in),
            vm_cesIO.l(ttot,regi,in)
          * p37_shIndFE(regi,in,secInd37)
          )
        * p37_fctEmi(entyFE)
        !! share of SE in FE production
        * ( vm_prodFE.l(ttot,regi,entySE,entyFE,te2)
          / sum(se2fe2(entySE2,entyFE,te3),
              vm_prodFE.l(ttot,regi,entySE2,entyFE,te3)
            )
          )
        )
        !! share of PE in SE production
      * ( vm_prodSE.l(ttot,regi,entyPE,entySE,te)
        / ( sum(pe2se2(entyPE2,entySE,te2), 
              vm_prodSE.l(ttot,regi,entyPE2,entySE,te2)
            )
            !! SE CH4 from waste bypass
          + ( sm_MtCH4_2_TWa
            * ( vm_macBase.l(ttot,regi,"ch4wstl")
              - vm_emiMacSector.l(ttot,regi,"ch4wstl")
              )
            )$( sameas(entySE,"segabio") )
          + sm_eps
          )
        )
      )
    * ( 1$( sameas(enty,"co2") )                   !! 1 for co2, 0 for cco2
      + ( pm_macSwitch(emiInd37)
        * pm_macAbatLev(ttot,regi,emiInd37)
        * ((0.5 - 1$( sameas(enty,"co2") )) * 2)   !! -1 for co2, 1 for cco2
        )
      )   !! residual emissions for co2, abated emissions for cco2
    );

  !! renewable primary energy carriers have zero emissions, but may have 
  !! non-zero CCS
  o37_emiInd(ttot,regi,peRe,secInd37,"co2") = 0;

  !! prepare cement process emissions for post-processing
  o37_cementProcessEmissions(ttot,regi,enty)$( ttot.val ge 2005 )
  = vm_macBaseInd.l(ttot,regi,"co2cement_process","cement")
  * ( 1$( sameas(enty,"co2") )                   !! 1 for co2, 0 for cco2
    + ( pm_macSwitch("co2cement")
      * pm_macAbatLev(ttot,regi,"co2cement")
      * ((0.5 - 1$( sameas(enty,"co2") )) * 2)   !! -1 for co2, 1 for cco2
      )
    );   !! residual emissions for co2, abated emissions for cco2

);

*** calculation of FE Industry Prices (useful for internal use and reporting 
*** purposes)
pm_FEPrice(t,regi,entyFE,"indst",emiMkt)$( abs(qm_budget.m(t,regi)) gt sm_eps )
  = q37_demFeIndst.m(t,regi,entyFE,emiMkt)
  / qm_budget.m(t,regi);


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
