*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/off/postsolve.gms

loop (enty$( sameas(enty,"co2") OR sameas(enty,"cco2") ),
  !! No emission from energy use are computed for subsectors
  o37_emiInd(ttot,regi,peRe,secInd37,enty) = 0;

  !! Compute cement process emissions for post-processing
  o37_cementProcessEmissions(ttot,regi,enty)$( ttot.val ge 2005 )
  = vm_macBaseInd.l(ttot,regi,"co2cement_process","cement")
  * ( 1$( sameas(enty,"co2") )                   !! 1 for co2, 0 for cco2
    + ( pm_macSwitch("co2cement")
      * pm_macAbatLev(ttot,regi,"co2cement")
      * ((0.5 - 1$( sameas(enty,"co2") )) * 2)   !! -1 for co2, 1 for cco2
      )
    );   !! residual emissions for co2, abated emissions for cco2

);

*** EOF ./modules/37_industry/off/postsolve.gms

