*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/presolve.gms
*JS*
*** calculation of tax rate, as a function of per-capita gdp levels
p21_tau_so2_tax(ttot,regi)$(ttot.val ge 2005)=s21_so2_tax_2010*pm_gdp_gdx(ttot,regi)/pm_pop(ttot,regi);  !! scaled by GDP/cap in the unit [trn US$/bn people]
p21_tau_so2_tax("2005",regi)=0;
p21_tau_so2_tax("2100",regi)=s21_so2_tax_2010*pm_gdp_gdx("2100",regi)/pm_pop("2100",regi);
p21_tau_so2_tax(ttot,regi)$(ttot.val>2100)=p21_tau_so2_tax("2100",regi);

*** sum all 4 CO2eq tax components
pm_taxCO2eqSum(ttot,regi) = pm_taxCO2eq(ttot,regi) + pm_taxCO2eqRegi(ttot,regi) + pm_taxCO2eqSCC(ttot,regi) + pm_taxCO2eqHist(ttot,regi);

*GL* save reference level value of taxed variables for revenue recycling
*JH* !!Warning!! The same allocation block exists in postsolve.gms. 
***                Do not forget to update the other file.
*** save level value of all taxes
pm_taxrevGHG0(ttot,regi) = pm_taxCO2eqSum(ttot,regi) * (vm_co2eq.l(ttot,regi) - vm_emiMacSector.l(ttot,regi,"co2luc")$(cm_multigasscen ne 3));
pm_taxrevCO2Sector0(ttot,regi,emi_sectors) = p21_CO2TaxSectorMarkup(ttot,regi,emi_sectors) * pm_taxCO2eqSum(ttot,regi) * vm_emiCO2Sector.l(ttot,regi,emi_sectors);
pm_taxrevCO2LUC0(ttot,regi) = pm_taxCO2eqSum(ttot,regi) * vm_emiMacSector.l(ttot,regi,"co2luc")$(cm_multigasscen ne 3);
p21_taxrevCCS0(ttot,regi) = cm_frac_CCS * pm_data(regi,"omf","ccsinje") * pm_inco0_t(ttot,regi,"ccsinje") 
                            * ( sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf) ) ) )
                            * (1/pm_ccsinjecrate(regi)) * sum(teCCS2rlf(te,rlf), sum(ccs2te(ccsCO2(enty),enty2,te), vm_co2CCS.l(ttot,regi,enty,enty2,te,rlf) ) ) / pm_dataccs(regi,"quan","1");
pm_taxrevNetNegEmi0(ttot,regi) = cm_frac_NetNegEmi * pm_taxCO2eqSum(ttot,regi) * v21_emiALLco2neg.l(ttot,regi);
p21_emiALLco2neg0(ttot,regi)  = v21_emiALLco2neg.l(ttot,regi);
p21_taxrevFE0(ttot,regi) = sum((entyFe,sector)$entyFe2Sector(entyFe,sector),
    ( pm_tau_fe_tax(ttot,regi,sector,entyFe) + pm_tau_fe_sub(ttot,regi,sector,entyFe) )
    *
    sum(emiMkt$sector2emiMkt(sector,emiMkt),
      sum(se2fe(entySe,entyFe,te),   
        vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt)
      )
    )
  )
;
p21_taxrevResEx0(ttot,regi) = sum(pe2rlf(peEx(enty),rlf), p21_tau_fuEx_sub(ttot,regi,enty) * vm_fuExtr.l(ttot,regi,enty,rlf));
p21_taxrevPE0(ttot,regi,entyPe) = pm_tau_pe_tax(ttot,regi,entyPe) * vm_prodPe.l(ttot,regi,entyPe);
p21_taxrevCES0(ttot,regi,in) = pm_tau_ces_tax(ttot,regi,in) * vm_cesIO.l(ttot,regi,in);
p21_taxrevPE2SE0(ttot,regi) = SUM(pe2se(enty,enty2,te),
                                    (p21_tau_pe2se_tax(ttot,regi,te) + p21_tau_pe2se_sub(ttot,regi,te) + p21_tau_pe2se_inconv(ttot,regi,te)) * vm_prodSe.l(ttot,regi,enty,enty2,te)
                                  ); 
p21_taxrevTech0(ttot,regi) = sum(te2rlf(te,rlf), (p21_tech_tax(ttot,regi,te,rlf) + p21_tech_sub(ttot,regi,te,rlf)) * vm_deltaCap.l(ttot,regi,te,rlf));
p21_taxrevXport0(ttot,regi) = SUM(tradePe(enty), p21_tau_XpRes_tax(ttot,regi,enty) * vm_Xport.l(ttot,regi,enty));
p21_taxrevSO20(ttot,regi) = p21_tau_so2_tax(ttot,regi) * vm_emiTe.l(ttot,regi,"so2");
p21_taxrevBio0(ttot,regi) = v21_tau_bio.l(ttot) * vm_pebiolc_price.l(ttot,regi) * vm_fuExtr.l(ttot,regi,"pebiolc","1")
                            + p21_bio_EF(ttot,regi) * pm_taxCO2eq(ttot,regi) * (vm_fuExtr.l(ttot,regi,"pebiolc","1") - (vm_Xport.l(ttot,regi,"pebiolc")-vm_Mport.l(ttot,regi,"pebiolc")));
p21_implicitDiscRate0(ttot,regi) = sum(ppfKap(in),  p21_implicitDiscRateMarg(ttot,regi,in)  * vm_cesIO.l(ttot,regi,in) );
p21_taxemiMkt0(ttot,regi,emiMkt) = pm_taxemiMkt(ttot,regi,emiMkt) * vm_co2eqMkt.l(ttot,regi,emiMkt);
p21_taxrevFlex0(ttot,regi)   =  sum(en2en(enty,enty2,te)$(teFlexTax(te)),
                                        -vm_flexAdj.l(ttot,regi,te) * vm_demSe.l(ttot,regi,enty,enty2,te));
p21_taxrevImport0(ttot,regi,tradePe) = p21_tau_Import(ttot,regi,tradePe) * pm_pvp(ttot,tradePe) / pm_pvp(ttot,"good") * vm_Mport.l(ttot,regi,tradePe);
p21_taxrevChProdStartYear0(t,regi) = sum(en2en(enty,enty2,te), vm_changeProdStartyearCost.l(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) );

*** EOF ./modules/21_tax/on/presolve.gms
