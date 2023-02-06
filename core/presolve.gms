*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/presolve.gms
*JeS* calculate share of transport fuels in liquids

pm_share_trans(ttot,regi)$(ttot.val ge 2005) = sum(se2fe(entySe,entyFe,te)$(seAgg2se("all_seliq",entySe) AND ( sameas(entyFe,"fepet") OR sameas(entyFe,"fedie"))), vm_prodFe.l(ttot,regi,entySe,entyFe,te)) / (sum(se2fe(entySe,entyFe,te)$seAgg2se("all_seliq",entySe), vm_prodFe.l(ttot,regi,entySe,entyFe,te)) + 0.0000001);

*AJS* we need those in nash
pm_capCum0(ttot,regi,teLearn)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_capCum.l(ttot,regi,teLearn);
pm_co2eq0(ttot,regi)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_co2eq.l(ttot,regi);
pm_emissions0(ttot,regi,enty)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_emiAll.l(ttot,regi,enty);

*LB* moved here from datainput to be updated based on the gdp-path
*** calculate econometric emission data: p2
p_emineg_econometric(regi,"co2cement_process","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10) = 0.3744788;
p_emineg_econometric(regi,"ch4wstl","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)   = 0.5702590;
p_emineg_econometric(regi,"ch4wstl","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)   = 0.2057304;
p_emineg_econometric(regi,"ch4wsts","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)   = 0.5702590;
p_emineg_econometric(regi,"ch4wsts","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)   = 0.2057304;
p_emineg_econometric(regi,"n2owaste","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)  = 0.3813973;
p_emineg_econometric(regi,"n2owaste","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)  = 0.1686718;

*JeS CO2 emissions from cement production. p_switch_cement describes an s-curve to provide a smooth switching from the short-term
*** behavior (depending on per capita capital investments) to the long-term behavior (constant per capita emissions).
p_switch_cement(ttot,regi)$(ttot.val ge 2005) = 1 / ( 1 + exp( - (s_c_so2 / s_tau_cement)
                                          *(1000 * p_inv_gdx(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)) - p_emineg_econometric(regi,"co2cement_process","p4"))
                                        )
                              );
display p_switch_cement;

*** calculate p1
p_emineg_econometric(regi,"co2cement_process","p1")$( p_switch_cement("2005",regi) < 0.999 )
  = ( (p_macBase2005(regi,"co2cement_process") / pm_pop("2005",regi))
    - ( p_switch_cement("2005",regi)
      * p_emineg_econometric(regi,"co2cement_process","p3")
      )
    )
  / ( (1 - p_switch_cement("2005",regi))
    * ( ( 1000
          !! use default per-capita investments if no investment data in gdx
          !! (due to different region settings)
        * ( (p_inv_gdx("2005",regi) / pm_pop("2005",regi))$( p_inv_gdx("2005",regi) )
          + 4$( NOT p_inv_gdx("2005",regi) )
          )
        / pm_shPPPMER(regi)
        )
     ** p_emineg_econometric(regi,"co2cement_process","p2")
      )
    );
p_emineg_econometric(regi,"n2owaste","p1") = p_macBase2005(regi,"n2owaste") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"n2owaste","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10) = p_macBase2005(regi,"ch4wstl") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10) = p_macBase2005(regi,"ch4wsts") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10) = p_macBase1990(regi,"ch4wstl") / (pm_pop("1990",regi) * (1000*pm_gdp("1990",regi) / (pm_pop("1990",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10) = p_macBase1990(regi,"ch4wsts") / (pm_pop("1990",regi) * (1000*pm_gdp("1990",regi) / (pm_pop("1990",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));

display p_emineg_econometric;

***--------------------------------------
*** calculate some emission factors
***--------------------------------------
*** calculate global emission factor
loop (emi2fuel(entyPE,enty),
  p_efFossilFuelExtrGlo(entyPE,enty)
  = sum(regi, p_emiFossilFuelExtr(regi,entyPE))
  / sum((rlf,regi), vm_fuExtr.l("2005",regi,entyPE,rlf));

  loop (regi,
    sm_tmp =  sum(rlf, vm_fuExtr.l("2005",regi,entyPE,rlf));

    p_efFossilFuelExtr(regi,entyPE,enty)$( sm_tmp )
      = p_emiFossilFuelExtr(regi,entyPE) / sm_tmp;

    p_efFossilFuelExtr(regi,entyPE,enty)$( NOT sm_tmp )
      = p_efFossilFuelExtrGlo(entyPE,enty);
  );
);

loop(regi,
   if ( p_efFossilFuelExtr(regi,"pecoal","ch4coal") ge 50,
        p_efFossilFuelExtr(regi,"pecoal","ch4coal") = p_efFossilFuelExtrGlo("pecoal","ch4coal");
   );
  if ( p_efFossilFuelExtr(regi,"pegas","ch4gas") ge 50,
        p_efFossilFuelExtr(regi,"pegas","ch4gas") = p_efFossilFuelExtrGlo("pegas","ch4gas");
   );
   if ( p_efFossilFuelExtr(regi,"peoil","ch4oil") ge 25,
        p_efFossilFuelExtr(regi,"peoil","ch4oil") = p_efFossilFuelExtrGlo("peoil","ch4oil");
   );
);
display p_efFossilFuelExtr;

***--------------------------------------
*** Non-energy emissions reductions (MAC)
***--------------------------------------
*JeS CO2 emissions from cement production. p_switch_cement describes an s-curve to provide a smooth switching from the short-term
*** behavior (depending on per capita capital investments) to the long-term behavior (constant per capita emissions).
p_switch_cement(ttot,regi)$(ttot.val ge 1990)=1/(1+exp(-(s_c_so2/s_tau_cement)*(1000*p_inv_gdx(ttot,regi)/(pm_pop(ttot,regi)*pm_shPPPMER(regi))-p_emineg_econometric(regi,"co2cement_process","p4"))));
display p_switch_cement;

*** scale CO2 luc baselines from MAgPIE to EDGAR v4.2 2005 data in REMIND standalone runs: linear, phase out within 20 years
***$if %cm_MAgPIE_coupling% == "off" pm_macBaseMagpie(ttot,regi,"co2luc")$(ttot.val lt 2030) = pm_macBaseMagpie(ttot,regi,"co2luc") + ( (p_macBase2005(regi,"co2luc") - pm_macBaseMagpie("2005",regi,"co2luc")) * (1-(ttot.val - 2005)/20) );

*** make sure that minimum CO2 luc emissions given in p_macPolCO2luc do not exceed the baseline
loop(regi,
     loop(ttot,
          if( (p_macPolCO2luc(ttot,regi) > pm_macBaseMagpie(ttot,regi,"co2luc")),
                    p_macPolCO2luc(ttot,regi) = pm_macBaseMagpie(ttot,regi,"co2luc")
             );
          );
    );

  if (cm_emiscen eq 9 or (cm_emiscen eq 10),
*** TODO: take care, this means that the SCC are only priced into MAC-curve
*** abatement if emiscen = 9 and for emiscen = 10 for CBA runs. Might want to change this.
    p_priceCO2(ttot,regi) = (pm_taxCO2eq(ttot,regi)  + pm_taxCO2eqSCC(ttot,regi) + pm_taxCO2eqHist(ttot,regi) )* 1000;
  else
    p_priceCO2(ttot,regi) 
    = abs(pm_pvpRegi(ttot,regi,"perm") / (pm_pvp(ttot,"good") + sm_eps))
    * 1000;
  );

*** Define co2 price for entities that are used in MAC. 
loop((enty,enty2)$emiMac2mac(enty,enty2), !! make sure that both mac sectors and mac curves have prices asigned as both sets are used in calculations below
  pm_priceCO2forMAC(ttot,regi,enty) = p_priceCO2(ttot,regi);
  pm_priceCO2forMAC(ttot,regi,enty2) = p_priceCO2(ttot,regi);
);

*** Redefine the MAC price for regions with emission tax defined by the regipol module
$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off" 
 loop(ext_regi$regiEmiMktTarget(ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
*** average CO2 price aggregated by FE
    p_priceCO2(t,regi) = ( (sum(emiMkt, pm_taxemiMkt(t,regi,emiMkt) * sum((entySe,entyFe,sector)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) / (sum((entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt))) )*1000;
    loop((enty,emiMkt)$(macSector2emiMkt(enty,emiMkt)),
      loop(enty2$emiMac2mac(enty,enty2), !! make sure that both mac sectors and mac curves have prices asigned as both sets are used in calculations below
        pm_priceCO2forMAC(t,regi,enty) = pm_taxemiMkt(t,regi,emiMkt)* 1000;
        pm_priceCO2forMAC(t,regi,enty2) = pm_taxemiMkt(t,regi,emiMkt)* 1000;
        pm_priceCO2forMAC(t,regi,"co2chemicals") = pm_taxemiMkt(t,regi,"ETS")* 1000;
        pm_priceCO2forMAC(t,regi,"co2steel") = pm_taxemiMkt(t,regi,"ETS")* 1000;
      );
    );
  );
 );
$ENDIF.emiMkt

*** The co2 price for land-use entities needs to be reduced by the same factor as in MAgPIE.
*** Attention: the reduction factors need to be the same as in MAgPIE -> if they change in MAgPIE they need to be adapted here!
*** 1. Optional: Reduce co2 price for land-use entities (see s56_cprice_red_factor in MAgPIE). By default, the scaling factor
*** in MAgPIE is 1. Deviations from this MAgPIE default should only be handled in coupled runs and not in REMIND standalone runs.
*** Therefore, we do not need a counterpart in REMIND standalone.
*** 2. Phase-in of co2 price for land-use entities, see line 22-35 in preloop.gms in modules/56_ghg_policy/price_jan19 in MAgPIE
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val lt cm_startyear)    = 0;
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear)    = 0.1 * pm_priceCO2forMAC(ttot,regi,MacSectorMagpie);
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+5)  = 0.2 * pm_priceCO2forMAC(ttot,regi,MacSectorMagpie);
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+10) = 0.4 * pm_priceCO2forMAC(ttot,regi,MacSectorMagpie);
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+15) = 0.8 * pm_priceCO2forMAC(ttot,regi,MacSectorMagpie);
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val ge cm_startyear+20) = pm_priceCO2forMAC(ttot,regi,MacSectorMagpie);
*** 3. Reduce co2 price for land-use entities by level of development (uses the same data from MOINPUT as MAgPIE for im_development_state)
pm_priceCO2forMAC(ttot,regi,MacSectorMagpie) = pm_priceCO2forMAC(ttot,regi,MacSectorMagpie) * p_developmentState(ttot,regi);
*** 4. Price for MACs was calculated with AR4 GWPs --> convert CO2 price with old GWPs here as well
pm_priceCO2forMAC(ttot,regi,emiMacMagpieN2O) = pm_priceCO2forMAC(ttot,regi,emiMacMagpieN2O) * (298/s_gwpN2O);
pm_priceCO2forMAC(ttot,regi,emiMacMagpieCH4) = pm_priceCO2forMAC(ttot,regi,emiMacMagpieCH4) * (25/s_gwpCH4);

display p_priceCO2,pm_priceCO2forMAC;
***--------------------------------------
*** MAC baselines
***--------------------------------------
*** endogenous in equations.gms
*** econometric
vm_macBase.fx(ttot,regi,"ch4wsts")$(ttot.val ge 2005) = p_emineg_econometric(regi,"ch4wsts","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2");
vm_macBase.fx(ttot,regi,"ch4wstl")$(ttot.val ge 2005) = p_emineg_econometric(regi,"ch4wstl","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2");
vm_macBase.fx(ttot,regi,"n2owaste")$(ttot.val ge 2005) = p_emineg_econometric(regi,"n2owaste","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"n2owaste","p2");

vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 ) 
  = ( pm_pop(ttot,regi)
    * ( (1 - p_switch_cement(ttot,regi))
      * p_emineg_econometric(regi,"co2cement_process","p1")
      * ( (1000
          * p_inv_gdx(ttot,regi)
          / ( pm_pop(ttot,regi)
            * pm_shPPPMER(regi)
            )
          ) ** p_emineg_econometric(regi,"co2cement_process","p2")
         )
      + ( p_switch_cement(ttot,regi)
        * p_emineg_econometric(regi,"co2cement_process","p3")
        )
       )
    )$(p_inv_gdx(ttot,regi) ne 0)
;

vm_macBaseInd.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
= vm_macBase.lo(ttot,regi,"co2cement_process");

* *** Reduction of cement demand due to CO2 price markups *** *
if ( NOT (cm_IndCCSscen eq 1 AND cm_CCS_cement eq 1),
*** Cement (clinker) production causes process emissions of the order of
*** 0.5 t CO2/t Cement. As cement prices are of the magnitude of 100 $/t, CO2
*** pricing leads to significant price markups.

  pm_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = pm_priceCO2forMAC(ttot,regi,"co2cement") / sm_C_2_CO2;

  display "CO2 price for computing Cement Demand Reduction [$/tC]",
          pm_CementAbatementPrice;

  !! The demand reduction function a = 160 / (p + 200) + 0.2 assumes that demand 
  !!  for cement is reduced by 40% if the price doubles (CO2 price of $200) and
  !!  that demand reductions of 80% can be achieved in the limit.
  pm_ResidualCementDemand("2005",regi) = 1;
  pm_ResidualCementDemand(ttot,regi)$( ttot.val gt 2005 )
  = 160 / (pm_CementAbatementPrice(ttot,regi) + 200) + 0.2;

  display "Cement Demand Reduction as computed", pm_ResidualCementDemand;

  !! Demand can only be reduced by 1% p.a.
  loop (ttot$( ttot.val gt 2005 ),
    pm_ResidualCementDemand(ttot,regi)
    = max(pm_ResidualCementDemand(ttot,regi),
          ( pm_ResidualCementDemand(ttot-1,regi)
          - 0.01 * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
          )
      );
  );

  display "Cement Demand Reduction, limited to 1% p.a.",
          pm_ResidualCementDemand;

  pm_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = 160 / (pm_ResidualCementDemand(ttot,regi) - 0.2) - 200;

  display "Cement Demand Reduction, price of limited reduction",
          pm_CementAbatementPrice;

  !! Costs of cement demand reduction are the integral under the activity 
  !! reduction curve times baseline emissions.
  !! a = 160 / (p + 200) + 0.2
  !! A = 160 ln(p + 200) + 0.2p
  !! A_MAC(p*) = A(p*) - A(0) - a(p*)p*
  pm_CementDemandReductionCost(ttot,regi)$( ttot.val ge 2005 )
  = ( 160 * log(pm_CementAbatementPrice(ttot,regi) + 200)
    + 0.2 * pm_CementAbatementPrice(ttot,regi)
    - 160 * log(200)
    - pm_ResidualCementDemand(ttot,regi) * pm_CementAbatementPrice(ttot,regi)
    )$( pm_CementAbatementPrice(ttot,regi) gt 0 )
  / 1000
  * vm_macBase.lo(ttot,regi,"co2cement_process");

  display "Cement Demand Reduction cost", pm_CementDemandReductionCost;

  vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process")
  * pm_ResidualCementDemand(ttot,regi);

  vm_macBaseInd.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process");
);


*** exogenous
vm_macBase.fx(ttot,regi,enty)$emiMacMagpie(enty) = pm_macBaseMagpie(ttot,regi,enty);
vm_macBase.fx(ttot,regi,enty)$emiMacExo(enty) = p_macBaseExo(ttot,regi,enty);
vm_macBase.fx(ttot,regi,"co2luc") = pm_macBaseMagpie(ttot,regi,"co2luc")-p_macPolCO2luc(ttot,regi);
vm_macBase.up(ttot,regi,"n2ofertin") = Inf;
***scale exogenous baselines from van Vuuren to EDGAR v4.2 2005 data
vm_macBase.fx(ttot,regi,"n2otrans")$p_macBaseVanv("2005",regi,"n2otrans") = p_macBaseVanv(ttot,regi,"n2otrans") * (p_macBase2005(regi,"n2otrans") / p_macBaseVanv("2005",regi,"n2otrans"));
vm_macBase.fx(ttot,regi,"n2oadac")$p_macBaseVanv("2005",regi,"n2otrans")  = p_macBaseVanv(ttot,regi,"n2oadac")  * (p_macBase2005(regi,"n2oacid")  / (p_macBaseVanv("2005",regi,"n2oadac") + p_macBaseVanv("2005",regi,"n2onitac")));
vm_macBase.fx(ttot,regi,"n2onitac")$(p_macBaseVanv("2005",regi,"n2oadac") OR p_macBaseVanv("2005",regi,"n2onitac")) = p_macBaseVanv(ttot,regi,"n2onitac") * (p_macBase2005(regi,"n2oacid")  / (p_macBaseVanv("2005",regi,"n2oadac") + p_macBaseVanv("2005",regi,"n2onitac")));

*** baseline continuation after 2100
vm_macBase.fx(ttot,regi,enty)$((ttot.val gt 2100)$((NOT emiMacMagpie(enty)) AND (NOT emiFuEx(enty)) AND (NOT sameas(enty,"n2ofertin")) ))=vm_macBase.l("2100",regi,enty);
*DK: baseline continuation not necessary for magpie-emissions as the exogenous data reaches until 2150
* JeS: exclude endgenous baseline calculation, i.e. emiFuEx and n2ofertin


***--------------------------------------
*** MAC abatement
***--------------------------------------
pm_macAbat(ttot,regi,enty,steps)
  =  p_abatparam_N2O(ttot,regi,enty,steps)
  +  p_abatparam_CH4(ttot,regi,enty,steps)
  +  p_abatparam_CO2(ttot,enty,steps)
  + pm_abatparam_Ind(ttot,regi,enty,steps)
;
pm_macAbat(ttot,regi,enty,steps)$(ttot.val gt 2100) = pm_macAbat("2100",regi,enty,steps);

*** Abatement options are in steps of length sm_dmac; options at zero price are 
*** in the first step
pm_macStep(ttot,regi,enty)$(MacSector(enty))
  = min(801, ceil(pm_priceCO2forMAC(ttot,regi,enty) / sm_dmac) + 1);

*** If the gas price increase since 2005 is higher than the CO2 price, it will drive CH4 emission abatement.
*** Conversion: pm_priceCO2forMAC [$/tCeq]; T$/TWa = 1e6 M$/TWa * s_MtCH4_2_TWa * 1 MtCH4/s_gwpCH4 MtCO2eq * (44/12) MtCO2eq/MtCeq
p_priceGas(ttot,regi)=q_balPe.m(ttot,regi,"pegas")/(qm_budget.m(ttot,regi)+sm_eps) * 1000000 * s_MtCH4_2_TWa * (1/s_gwpCH4) * 44/12;

pm_macStep(ttot,regi,"ch4gas")
  = min(801, ceil(max(pm_priceCO2forMAC(ttot,regi,"ch4gas") * (25/s_gwpCH4), max(0,(p_priceGas(ttot,regi)-p_priceGas("2005",regi))) ) / sm_dmac) + 1);
pm_macStep(ttot,regi,"ch4coal")
  = min(801, ceil(max(pm_priceCO2forMAC(ttot,regi,"ch4coal") * (25/s_gwpCH4), 0.5 * max(0,(p_priceGas(ttot,regi)-p_priceGas("2005",regi))) ) / sm_dmac) + 1);    
  
*** limit yearly increase of MAC usage to s_macChange
p_macAbat_lim(ttot,regi,enty)
  = sum(steps$(ord(steps) eq pm_macStep(ttot-1,regi,enty)),
      pm_macAbat(ttot-1,regi,enty,steps)
    )
  + s_macChange * pm_ts(ttot)
;

*** if intended abatement pm_macAbat is higher than this limit, pm_macStep has to 
*** be set to the highest step number where pm_macAbat is still lower or equal to
*** this limit
loop ((ttot,regi,MacSector(enty))$(NOT sameas(enty,"co2luc")),
  if (p_macAbat_lim(ttot,regi,enty) lt sum(steps$(ord(steps) eq pm_macStep(ttot,regi,enty)), pm_macAbat(ttot,regi,enty,steps)),
        loop(steps$(ord(steps) lt pm_macStep(ttot,regi,enty)),
            if (pm_macAbat(ttot,regi,enty,steps) gt p_macAbat_lim(ttot,regi,enty),
	            pm_macStep(ttot,regi,enty) = min(801,steps.val-1);
            );
        );
  );
);

*** In USA, EUR and JPN, abatement measures for CH4 emissions from waste started 
*** in 1990. These levels of abatement are enforced as a minimum in all
*** scenarios including BAU.
p_macUse2005(regi,enty) = 0.0;
p_macUse2005(regi,"ch4wstl")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) ge 10) = 1 - p_macBase2005(regi,"ch4wstl")/vm_macBase.l("2005",regi,"ch4wstl");
p_macUse2005(regi,"ch4wsts")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) ge 10) = 1 - p_macBase2005(regi,"ch4wsts")/vm_macBase.l("2005",regi,"ch4wsts");

*** Set first grade of abatement options (it represents low- or no-cost abatement potentials) for land use
*** emissions to zero, because they are alredy included in the emissions baselines we get from MAgPIE.
*** This includes sum of sub-categories from MAgPIE (see mapping emiMac2mac).
pm_macAbat(ttot,regi,MacSectorMagpie(enty),"1") = 0;

*** phase in use of zero cost abatement options until 2040 if there is no 
*** carbon price
p_macLevFree(ttot,regi,enty)$( ttot.val gt 2005 )
  =
    max(
      pm_macAbat(ttot,regi,enty,"1")
    * (1 - ((2040 - ttot.val) / (2040 - 2010))),
    p_macUse2005(regi,enty)
    )$( ttot.val ge 2010 AND ttot.val le 2040 )
  + max(
      pm_macAbat(ttot,regi,enty,"1"),
      p_macUse2005(regi,enty)
    )$( (ttot.val gt 2040) )
;

$IFTHEN.scaleEmiHist %c_scaleEmiHistorical% == "on"

**p_macLevFree(ttot,regi,emiMacMagpie(enty))=0;
* Set minimum abatment levels based on historical emissions
p_macLevFree("2010",regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst"))) = max( 0, 1 - (p_histEmiSector("2010",regi,"ch4","agriculture","process")+p_histEmiSector("2010",regi,"ch4","lulucf","process"))/(p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")));
p_macLevFree(ttot,regi,enty)$((ttot.val ge 2015) AND p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst"))) = max( 0, 1 - (p_histEmiSector("2015",regi,"ch4","agriculture","process")+p_histEmiSector("2015",regi,"ch4","lulucf","process"))/(p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) );
p_macLevFree("2010",regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp"))) = max( 0, 1 - (p_histEmiSector("2010",regi,"n2o","agriculture","process")+p_histEmiSector("2010",regi,"n2o","lulucf","process"))/(p_histEmiSector("2005",regi,"n2o","agriculture","process")+p_histEmiSector("2005",regi,"n2o","lulucf","process")) );
p_macLevFree(ttot,regi,emiMacMagpie(enty))$((ttot.val ge 2015) AND p_histEmiSector("2005",regi,"n2o","agriculture","process") AND (sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp"))) = max( 0, 1 - (p_histEmiSector("2015",regi,"n2o","agriculture","process")+p_histEmiSector("2015",regi,"n2o","lulucf","process"))/(p_histEmiSector("2005",regi,"n2o","agriculture","process")+p_histEmiSector("2005",regi,"n2o","lulucf","process")) );

p_macLevFree("2010",regi,enty)$((p_histEmiMac("2010",regi,enty)) AND (sameas(enty,"ch4wstl") OR sameas(enty,"ch4wsts"))) = max( 0, 1 - (p_histEmiMac("2010",regi,enty)) /vm_macBase.l("2010",regi,enty) );
p_macLevFree(ttot,regi,enty)$((ttot.val ge 2015) AND (p_histEmiMac("2015",regi,enty)) AND (sameas(enty,"ch4wstl") OR sameas(enty,"ch4wsts"))) = max( 0, 1 - (p_histEmiMac("2015",regi,enty))/vm_macBase.l("2015",regi,enty) );

$ELSE.scaleEmiHist

p_macLevFree(ttot,regi,emiMacMagpie(enty))=0;

$ENDIF.scaleEmiHist

pm_macAbatLev(ttot,regi,enty) = 0.0;
pm_macAbatLev("2005",regi,enty) = p_macUse2005(regi,enty);
pm_macAbatLev("2010",regi,enty) = p_macLevFree("2010",regi,enty);
pm_macAbatLev("2015",regi,enty) = p_macLevFree("2015",regi,enty);
pm_macAbatLev(ttot,regi,enty)$( ttot.val gt 2015 )
  =
    max(
      sum(steps$(ord(steps) eq pm_macStep(ttot,regi,enty)),
        pm_macAbat(ttot,regi,enty,steps)
      ),
      p_macLevFree(ttot,regi,enty)
	);

pm_macAbatLev("2015",regi,"co2luc") = 0;
pm_macAbatLev("2020",regi,"co2luc") = 0;

*** Limit MAC abatement level increase to 5 % p.a., or 2 % p.a. for cement
*** before 2050
loop (ttot$( ttot.val ge 2015 ),
  pm_macAbatLev(ttot,regi,MACsector(enty))
    = min(
        pm_macAbatLev(ttot,regi,enty),

        ( pm_macAbatLev(ttot-1,regi,enty)
        + ( ( s_macChange$( NOT sameas(enty,"co2cement") OR  ttot.val gt 2050 )
            + 0.02$(            sameas(enty,"co2cement") AND ttot.val le 2050 )
  	    )
          * pm_ts(ttot)
          )
        )
      );
);

Display "computed abatement levels at carbon price", pm_macAbatLev;

    
***--------------------------------------
*** MAC costs
***--------------------------------------
*** Integral under MAC cost curve
*** costs = baseline emissions * price step * sum [over i to n] (q_n - q_i)
*** q_i = abatement [fraction] at step i
pm_macCost(ttot,regi,emiMacSector(enty))
  = 1e-3
  * pm_macCostSwitch(enty)
  * p_emi_quan_conv_ar4(enty)
  * vm_macBase.l(ttot,regi,enty)
  * sm_dmac
  * ( ( sum(emiMac2mac(enty,enty2),
          pm_macStep(ttot,regi,enty2)
        )
      * sum(steps$( ord(steps) eq sum(emiMac2mac(enty,enty2),
                                    pm_macStep(ttot,regi,enty2)) ),
          sum(emiMac2mac(enty,enty2), pm_macAbat(ttot,regi,enty2,steps))
        )
      )
    - sum(steps$( ord(steps) le sum(emiMac2mac(enty,enty2),
                                  pm_macStep(ttot,regi,enty2)) ),
        sum(emiMac2mac(enty,enty2), pm_macAbat(ttot,regi,enty2,steps))
      )
    );

*JeS* add 50% of abated CH4 from coal MACs to PEprod. CH4 from oil production is usually flared and not re-used. CH4 from gas production is mostly avoided losses from leakages.
*** These losses are not accounted for, so neither are the avoided losses.
*** conversion factor MtCH4 --> TWa: 1 MtCH4 = 1.23 * 10^6 toe * 42 GJ/toe * 10^-9 EJ/GJ * 1 TWa/31.536 EJ = 0.001638 (BP statistical review)
p_macPE(ttot,regi,enty) = 0.0;
p_macPE(ttot,regi,"pegas")$(ttot.val gt 2005) = s_MtCH4_2_TWa * 0.5 * (vm_macBase.l(ttot,regi,"ch4coal")-vm_emiMacSector.l(ttot,regi,"ch4coal"));


***------------ adjust adjustment costs for advanced vehicles according to CO2 price in the previous time step ----------------------
*** (same as in postsolve - if you change it here, also change in postsolve)
*** this represents the concept that with stringent climate policies (as represented by high CO2 prices), all market actors will have a clearer expectation that
*** transport shifts to low-carbon vehicles, thus companies will be more likely to invest into new zero-carbon vehicle models, charging infrastructure, etc.
*** Also, gov'ts will be more likely to implement additional support policies that overcome existing barriers & irrationalities and thereby facilitate deployment
*** of advanced vehicles, e.g. infrastructure for charging, setting phase-out dates that encourage car manufacturers to develop more advanced fuel models, etc.
*** Use the CO2 price from the previous time step to represent inertia

$iftheni.CO2priceDependent_AdjCosts %c_CO2priceDependent_AdjCosts% == "on"

loop(ttot$( (ttot.val > cm_startyear) AND (ttot.val > 2020) ),  !! only change values in the unfixed time steps of the current run, and not in the past
  loop(regi,
    if( pm_taxCO2eq(ttot-1,regi) le (40 * sm_DptCO2_2_TDpGtC) ,
	  p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.1;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 4;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (40 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (80 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.25;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 2.5;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (80 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (160 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 0.5;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 1.5;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (160 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (320 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 1;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 1;
    elseif ( ( pm_taxCO2eq(ttot-1,regi) gt (320 * sm_DptCO2_2_TDpGtC) ) AND ( pm_taxCO2eq(ttot-1,regi) le (640 * sm_DptCO2_2_TDpGtC) ) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 2;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 0.5;
	elseif ( pm_taxCO2eq(ttot-1,regi) gt (640 * sm_DptCO2_2_TDpGtC) ) ,
      p_varyAdj_mult_adjSeedTe(ttot,regi) = 4;
	  p_varyAdj_mult_adjCoeff(ttot,regi)  = 0.25;
    );
	p_adj_seed_te(ttot,regi,'apCarH2T')        = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarH2T');
    p_adj_seed_te(ttot,regi,'apCarElT')        = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarElT');
    p_adj_seed_te(ttot,regi,'apCarDiEffT')     = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarDiEffT');
    p_adj_seed_te(ttot,regi,'apCarDiEffH2T')   = p_varyAdj_mult_adjSeedTe(ttot,regi) * p_adj_seed_te_Orig(ttot,regi,'apCarDiEffH2T');
    p_adj_coeff(ttot,regi,'apCarH2T')         = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarH2T') ;
    p_adj_coeff(ttot,regi,'apCarElT')         = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarElT') ;
    p_adj_coeff(ttot,regi,'apCarDiEffT')      = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarDiEffT') ;
    p_adj_coeff(ttot,regi,'apCarDiEffH2T')    = p_varyAdj_mult_adjCoeff(ttot,regi) * p_adj_coeff_Orig(ttot,regi,'apCarDiEffH2T') ;
  );
);
display p_adj_seed_te, p_adj_coeff, p_varyAdj_mult_adjSeedTe, p_varyAdj_mult_adjCoeff;

$endif.CO2priceDependent_AdjCosts


*** EOF ./core/presolve.gms
