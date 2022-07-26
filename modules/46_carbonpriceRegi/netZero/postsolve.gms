*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms

if(sameas("%carbonprice%","none"), p46_startInIteration = 0);

if(ord(iteration) > p46_startInIteration, !!start only after 10 iterations, so to already have some stability of the overall carbon price trajectory

p46_emi_2020(regi) = vm_co2eq.l("2020",regi) * sm_c_2_co2 * 1000;

*** OR: calculate actual emissions for all with GHG target

p46_emi_actual(nz_reg2050(all_regi))$(not nz_reg_CO2(all_regi))
   = vm_co2eq.l("2050",nz_reg2050)*sm_c_2_co2*1000 + vm_emiFgas.L("2050",nz_reg2050,"emiFgasTotal")
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2050",nz_reg2050,enty,enty2,te,"co2")
        * vm_demFeSector.l("2050",nz_reg2050,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2055(all_regi))$(not nz_reg_CO2(all_regi))
   = vm_co2eq.l("2055",nz_reg2055)*sm_c_2_co2*1000 + vm_emiFgas.L("2055",nz_reg2055,"emiFgasTotal")
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2055",nz_reg2055,enty,enty2,te,"co2")
        * vm_demFeSector.l("2055",nz_reg2055,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2060(all_regi))$(not nz_reg_CO2(all_regi))
   = vm_co2eq.l("2060",nz_reg2060)*sm_c_2_co2*1000 + vm_emiFgas.L("2060",nz_reg2060,"emiFgasTotal")
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2060",nz_reg2060,enty,enty2,te,"co2")
        * vm_demFeSector.l("2060",nz_reg2060,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2070(all_regi))$(not nz_reg_CO2(all_regi))
   = vm_co2eq.l("2070",nz_reg2070)*sm_c_2_co2*1000 + vm_emiFgas.L("2070",nz_reg2070,"emiFgasTotal")
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2070",nz_reg2070,enty,enty2,te,"co2")
        * vm_demFeSector.l("2070",nz_reg2070,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

*** OR: calculate actual emissions for all with CO2 target

p46_emi_actual(nz_reg2050(all_regi))$(nz_reg_CO2(all_regi))
   = (vm_emiTe.l("2050",nz_reg2050,"co2") + vm_emiMac.L("2050",nz_reg2050,"co2") + vm_emiCdr.L("2050",nz_reg2050,"co2"))*sm_c_2_co2*1000
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2050",nz_reg2050,enty,enty2,te,"co2")
        * vm_demFeSector.l("2050",nz_reg2050,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2055(all_regi))$(nz_reg_CO2(all_regi))
   = (vm_emiTe.l("2055",nz_reg2055,"co2") + vm_emiMac.L("2055",nz_reg2055,"co2") + vm_emiCdr.L("2055",nz_reg2055,"co2"))*sm_c_2_co2*1000
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2055",nz_reg2055,enty,enty2,te,"co2")
        * vm_demFeSector.l("2055",nz_reg2055,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2060(all_regi))$(nz_reg_CO2(all_regi))
   = (vm_emiTe.l("2060",nz_reg2060,"co2") + vm_emiMac.L("2060",nz_reg2060,"co2") + vm_emiCdr.L("2060",nz_reg2060,"co2"))*sm_c_2_co2*1000
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2060",nz_reg2060,enty,enty2,te,"co2")
        * vm_demFeSector.l("2060",nz_reg2060,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );

p46_emi_actual(nz_reg2070(all_regi))$(nz_reg_CO2(all_regi))
   = (vm_emiTe.l("2070",nz_reg2070,"co2") + vm_emiMac.L("2070",nz_reg2070,"co2") + vm_emiCdr.L("2070",nz_reg2070,"co2"))*sm_c_2_co2*1000
***   substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2070",nz_reg2070,enty,enty2,te,"co2")
        * vm_demFeSector.l("2070",nz_reg2070,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      );


***calculate relative change of overall price required to bring emissions to zero
p46_factorRescaleCO2Tax(nz_reg)=(1+(p46_emi_actual(nz_reg)/p46_emi_2020(nz_reg)))**2;

***calculate relative change in markup, taking into account change in tax:
p46_factorRescaleCO2TaxRegi(nz_reg) = max(1-0.75*1.01**(-iteration.val),((p46_taxCO2eqLast("2050",nz_reg)+p46_taxCO2eqRegiLast("2050",nz_reg))*p46_factorRescaleCO2Tax(nz_reg)-pm_taxCO2eq("2050",nz_reg))
                               /(p46_taxCO2eqRegiLast("2050",nz_reg)+0.0001));!!to avoid division by zero in case of mark-up being not necessary

p46_factorRescaleCO2TaxLtd_iter(iteration,nz_reg) = p46_factorRescaleCO2TaxRegi(nz_reg);

***calculate new mark-up:
pm_taxCO2eqRegi(t,nz_reg)=pm_taxCO2eqRegi(t,nz_reg)*p46_factorRescaleCO2TaxRegi(nz_reg);



);!! ord(iteration) > p46_startInIteration

display p46_emi_actual,p46_emi_2020,p46_factorRescaleCO2Tax, p46_factorRescaleCO2TaxRegi, pm_taxCO2eqRegi, p46_taxCO2eqRegiLast;

p46_taxCO2eqRegiLast(t,regi) = pm_taxCO2eqRegi(t,regi);
p46_taxCO2eqLast(t,regi) = pm_taxCO2eq(t,regi);

p46_taxCO2eqRegi_iter(iteration,t,nz_reg2050)$sameas(t,"2050") = pm_taxCO2eqRegi(t,nz_reg2050);
p46_taxCO2eqRegi_iter(iteration,t,nz_reg2055)$sameas(t,"2055") = pm_taxCO2eqRegi(t,nz_reg2055);
p46_taxCO2eqRegi_iter(iteration,t,nz_reg2060)$sameas(t,"2060") = pm_taxCO2eqRegi(t,nz_reg2060);
p46_taxCO2eqRegi_iter(iteration,t,nz_reg2070)$sameas(t,"2070") = pm_taxCO2eqRegi(t,nz_reg2070);
p46_taxCO2eq_iter(iteration,t,nz_reg2050)$sameas(t,"2050") = pm_taxCO2eq(t,nz_reg2050);
p46_taxCO2eq_iter(iteration,t,nz_reg2055)$sameas(t,"2055") = pm_taxCO2eq(t,nz_reg2055);
p46_taxCO2eq_iter(iteration,t,nz_reg2060)$sameas(t,"2060") = pm_taxCO2eq(t,nz_reg2060);
p46_taxCO2eq_iter(iteration,t,nz_reg2070)$sameas(t,"2070") = pm_taxCO2eq(t,nz_reg2070);
p46_emi_actual_iter(iteration,t,nz_reg2050)$sameas(t,"2050") = p46_emi_actual(nz_reg2050);
p46_emi_actual_iter(iteration,t,nz_reg2055)$sameas(t,"2055") = p46_emi_actual(nz_reg2055);
p46_emi_actual_iter(iteration,t,nz_reg2060)$sameas(t,"2060") = p46_emi_actual(nz_reg2060);
p46_emi_actual_iter(iteration,t,nz_reg2070)$sameas(t,"2070") = p46_emi_actual(nz_reg2070);

*** EOF ./modules/46_carbonpriceRegi/netZero/postsolve.gms
