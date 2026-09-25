*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/41_emicapregi/JUSTMip/postsolve.gms

***------------------------------------------------------------------------------------------------------------------------------------------------
*** regional eoc emission budget: 
***------------------------------------------------------------------------------------------------------------------------------------------------

*** Save the trade volume information from this iteration for debugging and for use in the next iteration
  pm_permTradeVolumeRegi_iter(iteration,t,regi) = vm_permTradeVolumeRegi.l(t,regi);

  pm_permTradeVolumeGlo_full(iteration, t) = sum(regi, vm_permTradeVolumeRegi.l(t,regi));

  pm_otherRegionsTradeVolume(t,regi) = pm_permTradeVolumeGlo_full(iteration, t) - vm_permTradeVolumeRegi.l(t,regi);

  pm_otherRegionsTradeVolume_iter(iteration,t,regi) = pm_otherRegionsTradeVolume(t,regi); !! Save for debugging

  
*** EOF ./modules/41_emicapregi/JUSTMip/postsolve.gms
