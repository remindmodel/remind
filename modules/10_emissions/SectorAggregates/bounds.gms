*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/bounds.gms


*** ==================================================================
*** ==================================================================
*' ### Non-CO2 emissions plus LUC MACCs
*** ==================================================================
*** ==================================================================

*' Bounds for the non-CO2 emissions and land-use change (LUC) CO2 subject to marginal abatement cost curves (MACCs),
*' and fixing of F-gas emissions to input data. 
*' Air pollutants are not part of this module (see 11_aerosols), but some
*' of their bounds are still set in the core.


*** ==================================================================
*' #### 1. Emissions with MACs
*** ==================================================================

vm_emiMacSector.lo(t,regi,enty) = 0;
vm_emiMacSector.lo(t,regi,"co2luc") = -5.0; !! afforestation can lead to negative emissions
vm_emiMacSector.lo(t,regi,"n2ofertsom") = -1; !! small negative emissions can result from human activity


*** ==================================================================
*' #### 2. F-gases
*** ==================================================================

*** fix F-gas emissions to inputdata (IMAGE)
vm_emiFgas.fx(ttot,all_regi,all_enty) = f10_emiFgas(ttot,all_regi,"%c_SSP_forcing_adjust%","%cm_rcp_scen%","SPA0",all_enty);
display vm_emiFgas.L;

*** EOF ./modules/10_emissions/SectorAggregates/bounds.gms
