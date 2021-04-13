*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/postsolve.gms

*' Prepare industry emissions for post-processing
loop (enty$( sameas(enty,"co2") OR sameas(enty,"cco2") ),
  !! emissions from fuel burning
  o37_emiInd(ttot,regi,entyPE,secInd37,enty)$( ttot.val ge 2005 )
    !! link sector to emissions (sector-specifc MAC)
  = sum(secInd37_2_emiInd37(secInd37,emiInd37(emiInd37_fuel)),
      !! link sector energy use to FE/SE/PE production
      sum(pe2se(entyPE,entySE,te),
        sum(se2fe(entySE,entyFE,te2),
          sum(fe2ppfen(entyFE,ppfen_industry_dyn37(in)),
            !! link sector to sector energy use
            sum(secInd37_2_pf(secInd37,in),
              vm_cesIO.l(ttot,regi,in)
            )
          )
        * p37_fctEmi(entyFE) !! convert energy to emissions
        )
        !! share of PE in SE production
      * ( vm_prodSE.l(ttot,regi,entyPE,entySE,te)
        / ( sum(pe2se2(entyPE2,entySE,te2),
              vm_prodSE.l(ttot,regi,entyPE2,entySE,te2)
            )
            !! SE CH4 from waste bypass
          + ( 0.001638
            * ( vm_macBase.l(ttot,regi,"ch4wstl")
              - vm_emiMacSector.l(ttot,regi,"ch4wstl")
              )
            )$( sameas(entySE,"segabio") )
          + sm_eps
          )
        )
      )
      !! residual emissions for co2, abated emissions for cco2
    * ( 1$( sameas(enty,"co2") )                   !! 1 for co2, 0 for cco2
      + ( pm_macSwitch(emiInd37)
        * pm_macAbatlev(ttot,regi,emiInd37)
        * ((0.5 - 1$( sameas(enty,"co2") )) * 2)   !! -1 for co2, 1 for cco2
        )
      )
    );
          
  !! cement process emissions
  o37_cementProcessEmissions(ttot,regi,enty)$( ttot.val ge 2005 )
  = vm_macBaseInd.l(ttot,regi,"co2cement_process","cement")
    !! residual emissions for co2, abated emissions for cco2
  * ( 1$( sameas(enty,"co2") )                   !! 1 for co2, 0 for cco2
    + ( pm_macSwitch("co2cement")
      * pm_macAbatLev(ttot,regi,"co2cement")
      * ((0.5 - 1$( sameas(enty,"co2") )) * 2)   !! -1 for co2, 1 for cco2
      )
    );
);


*** calculation of FE Industry Prices (useful for internal use and reporting 
*** purposes)
pm_FEPrice(t,regi,entyFE,"indst",emiMkt)$( abs (qm_budget.m(t,regi)) gt sm_eps )
  = q37_demFeIndst.m(t,regi,entyFE,emiMkt)
  / qm_budget.m(t,regi);

*** EOF ./modules/37_industry/subsectors/postsolve.gms

