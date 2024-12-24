*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/39_CCU/on/bounds.gms

*' no CCU technologies (liquid synfuel, synthetic gas) before 2025
vm_cap.up(t,regi,te_ccu39,"1")$(t.val lt 2025) = 0;

*' no synthetic gas production before 2030
vm_cap.up(t,regi,"h22ch4","1")$(t.val lt 2030) = 0;

*' upper bounds for near-term trends on liquid synfuels (CCU-fuels) 2025 and 2030
*' based on project announcements from IEA database
*' https://www.iea.org/data-and-statistics/data-product/hydrogen-production-and-infrastructure-projects-database
*' distribute to regions via GDP share of 2025
*' in future this should be differentiated by region based on regionalized input data of project announcements
*' 0.5 TWh/yr liquid synfuel production globally at minimum in 2025
*' corresponds to projects operational as of 2024
vm_cap.lo("2025",regi,"MeOH","1")= 0.5 / pm_cf("2025",regi,"MeOH") / 8760
                                    * pm_gdp("2025",regi)
                                    / sum(regi2,pm_gdp("2025",regi2));


*' 5 TWh/yr liquid synfuel production globally at maximum in 2025
*' corresponds to about half of project announcements from IEA database
vm_cap.up("2025",regi,"MeOH","1")= 5 / pm_cf("2025",regi,"MeOH") / 8760
                                    * pm_gdp("2025",regi)
                                    / sum(regi2,pm_gdp("2025",regi2));



*' 30 TWh/yr liquid synfuel production globally at maximum in 2030,
*' corresponds to about half of project announcements from IEA database
vm_cap.up("2030",regi,"MeOH","1")= 30 / pm_cf("2030",regi,"MeOH") / 8760
                                    * pm_gdp("2025",regi)
                                    / sum(regi2,pm_gdp("2025",regi2));


*** switch off CCU in baseline runs (as CO2 capture technologies teCCS are also switched off)
if(cm_emiscen = 1,
  vm_cap.fx(t,regi,te_ccu39,rlf) = 0;
);

***----------------------------------------------------------------------------
*** force synthetic liquids in as a minimum share of total liquids if cm_shSynLiq switch used 
***----------------------------------------------------------------------------

if (cm_shSynLiq gt 0,
  v39_shSynLiq.lo(t,regi)$(t.val eq 2035) = cm_shSynLiq / 4;
  v39_shSynLiq.lo(t,regi)$(t.val eq 2040) = cm_shSynLiq / 2;
  v39_shSynLiq.lo(t,regi)$(t.val ge 2045) = cm_shSynLiq;
);

***----------------------------------------------------------------------------
*** force synthetic gases in as a minimum share of total liquids if cm_shSynGas switch used 
***----------------------------------------------------------------------------

if (cm_shSynGas gt 0,
v39_shSynGas.lo(t,regi)$(t.val eq 2035) = cm_shSynGas / 4;
v39_shSynGas.lo(t,regi)$(t.val eq 2040) = cm_shSynGas / 2;
v39_shSynGas.lo(t,regi)$(t.val ge 2045) = cm_shSynGas;
);
*** EOF ./modules/39_CCU/on/bounds.gms
