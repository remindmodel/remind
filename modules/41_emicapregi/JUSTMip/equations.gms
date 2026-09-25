*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/equations.gms

*' @equations

*' calculate emission cap in absolute terms (1e9 converts GtCeq to tonnes of CO2-equivalent and 1e-12 then converts the result to trillion USD)

*** preparation: calculate the total trade volume of emission permits in each region and globally (as seen by each region in a given nash iteration)
q41_tradeVolumeRegi(t,regi) ..
    (vm_Xport(t,regi,"perm") + vm_Mport(t,regi,"perm"))
        * pm_taxCO2eq(t,regi)
    =e=
    vm_permTradeVolumeRegi(t,regi);

q41_tradeVolumeGlo(t,regi) ..
    vm_permTradeVolumeRegi(t,regi) +
    pm_otherRegionsTradeVolume(t,regi) 
    =e=
    vm_permTradeVolumeGlo(t,regi)
;

*** Define the actual limitation equations 
*** limitation based on global GDP, relevant if cm_permTradingLimGlo between 0 and 1
q41_globalPermitTradeCap(t,regi) ..
    vm_permTradeVolumeGlo(t,regi)
    =l=
    cm_permTradingLimGlo * p41_gdpGlob(t)
;

*** limitation based on regional GDP, relevant if cm_permTradingLimRegi between 0 and 1
q41_globalPermitTradeCapRegi(t,regi) ..

    vm_permTradeVolumeRegi(t,regi)
    =l=
    cm_permTradingLimRegi  * pm_gdp(t,regi)
;



*' @stop
*** EOF ./modules/41_emicapregi/JUSTMip/equations.gms
