*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/netZero/postsolve.gms


if(ord(iteration)>10, !!start only after 10 iterations, so to already have some stability of the overall carbon price trajectory

p48_2020_regi(regi)=vm_co2eq.l("2020",regi)*sm_c_2_co2*1000;

p48_actual_co2eq_regi(nz_reg2050) = vm_co2eq.l("2050",nz_reg2050)*sm_c_2_co2*1000 + vm_emiFgas.L("2050",nz_reg2050,"emiFgasTotal")
***or*    substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2050",nz_reg2050,enty,enty2,te,"co2")
        * vm_demFeSector.l("2050",nz_reg2050,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 

p48_actual_co2eq_regi(nz_reg2060) = vm_co2eq.l("2060",nz_reg2060)*sm_c_2_co2*1000 + vm_emiFgas.L("2060",nz_reg2060,"emiFgasTotal")
***or*    substract the bunker emissions
    - sum(se2fe(enty,enty2,te),
        pm_emifac("2060",nz_reg2060,enty,enty2,te,"co2")
        * vm_demFeSector.l("2060",nz_reg2060,enty,enty2,"trans","other") * sm_c_2_co2 * 1000
      ); 

***calculate relative change of overall price required to bring emissions to zero
p48_taxCO2eq_factor(nz_reg)=(1+(p48_actual_co2eq_regi(nz_reg)/p48_2020_regi(nz_reg)))**2;

***calculate relative change in markup, taking into account change in tax:
p48_taxCO2eq_regi_factor(nz_reg) = max(1-0.75*1.01**(-iteration.val),((p48_taxCO2eq_last("2050",nz_reg)+p48_taxCO2eq_regi_last("2050",nz_reg))*p48_taxCO2eq_factor(nz_reg)-pm_taxCO2eq("2050",nz_reg))
                               /(p48_taxCO2eq_regi_last("2050",nz_reg)+0.0001));!!to avoid division by zero in case of mark-up being not necessary



***calculate new mark-up:
pm_taxCO2eq_regi(t,nz_reg)=pm_taxCO2eq_regi(t,nz_reg)*p48_taxCO2eq_regi_factor(nz_reg);



);!! ord(iteration)>10

display p48_actual_co2eq_regi,p48_2020_regi,p48_taxCO2eq_factor, p48_taxCO2eq_regi_factor, pm_taxCO2eq_regi, p48_taxCO2eq_regi_last;

p48_taxCO2eq_regi_last(t,regi) = pm_taxCO2eq_regi(t,regi);
p48_taxCO2eq_last(t,regi) = pm_taxCO2eq(t,regi);

*** EOF ./modules/48_carbonpriceRegi/netZero/postsolve.gms
