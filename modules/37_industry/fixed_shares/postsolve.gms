*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
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
          + ( 0.001638
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

*** EOF ./modules/37_industry/fixed_shares/postsolve.gms

