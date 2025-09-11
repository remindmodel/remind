*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/presolve.gms

* defining the CO2 price parameter that sums up the 3 CO2eq tax components
pm_taxCO2eqSum(ttot,regi) = pm_taxCO2eq(ttot,regi) + pm_taxCO2eqRegi(ttot,regi) + pm_taxCO2eqSCC(ttot,regi);

*JeS* calculate share of transport fuels in liquids
pm_share_trans(ttot,regi)$(ttot.val ge 2005) = sum(se2fe(entySe,entyFe,te)$(seAgg2se("all_seliq",entySe) AND ( sameas(entyFe,"fepet") OR sameas(entyFe,"fedie"))), vm_prodFe.l(ttot,regi,entySe,entyFe,te)) / (sum(se2fe(entySe,entyFe,te)$seAgg2se("all_seliq",entySe), vm_prodFe.l(ttot,regi,entySe,entyFe,te)) + 0.0000001);

*AJS* we need those in nash
pm_capCum0(ttot,regi,teLearn)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_capCum.l(ttot,regi,teLearn);
pm_co2eq0(ttot,regi)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_co2eq.l(ttot,regi);
pm_emissions0(ttot,regi,enty)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = vm_emiAll.l(ttot,regi,enty);

*LB* moved here from datainput to be updated based on the gdp-path
*** calculate econometric emission data: p2
p_emineg_econometric(regi,"ch4wstl","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)   = 0.5702590;
p_emineg_econometric(regi,"ch4wstl","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)   = 0.2057304;
p_emineg_econometric(regi,"ch4wsts","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)   = 0.5702590;
p_emineg_econometric(regi,"ch4wsts","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)   = 0.2057304;
p_emineg_econometric(regi,"n2owaste","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10)  = 0.3813973;
p_emineg_econometric(regi,"n2owaste","p2")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10)  = 0.1686718;

*** calculate p1
*** GA: p1 is based on GDP per capita. The older implementation assumes that
*** richer countries (GPDpc > 10K USD) effectively have an older emission factor.
*** The newer implementation, based on 2020 CEDS, assumes the same base year
*** for both, with p2 only creating a distinction between the groups.
*** The choice between implementations is controlled by setting the 
*** the base year in cm_emifacs_baseyear, but we need an if condition
*** here to account for the 1990 quirk. Choosing 2005 keeps the old version,
*** and any other choice assumes 2020. 
$ifthen %cm_emifacs_baseyear% == "2005"
p_emineg_econometric(regi,"n2owaste","p1") = p_macBase2005(regi,"n2owaste") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"n2owaste","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10) = p_macBase2005(regi,"ch4wstl") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) le 10) = p_macBase2005(regi,"ch4wsts") / (pm_pop("2005",regi) * (1000*pm_gdp("2005",regi) / (pm_pop("2005",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10) = p_macBase1990(regi,"ch4wstl") / (pm_pop("1990",regi) * (1000*pm_gdp("1990",regi) / (pm_pop("1990",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) gt 10) = p_macBase1990(regi,"ch4wsts") / (pm_pop("1990",regi) * (1000*pm_gdp("1990",regi) / (pm_pop("1990",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));
$else
p_emineg_econometric(regi,"n2owaste","p1") = p_macBase2005(regi,"n2owaste") / (pm_pop("%cm_emifacs_baseyear%",regi) * (1000*pm_gdp("%cm_emifacs_baseyear%",regi) / (pm_pop("%cm_emifacs_baseyear%",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"n2owaste","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("%cm_emifacs_baseyear%",regi)/pm_pop("%cm_emifacs_baseyear%",regi) le 10) = p_macBaseCEDS2020(regi,"ch4wstl") / (pm_pop("%cm_emifacs_baseyear%",regi) * (1000*pm_gdp("%cm_emifacs_baseyear%",regi) / (pm_pop("%cm_emifacs_baseyear%",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("%cm_emifacs_baseyear%",regi)/pm_pop("%cm_emifacs_baseyear%",regi) le 10) = p_macBaseCEDS2020(regi,"ch4wsts") / (pm_pop("%cm_emifacs_baseyear%",regi) * (1000*pm_gdp("%cm_emifacs_baseyear%",regi) / (pm_pop("%cm_emifacs_baseyear%",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));
p_emineg_econometric(regi,"ch4wstl","p1")$(pm_gdp_gdx("%cm_emifacs_baseyear%",regi)/pm_pop("%cm_emifacs_baseyear%",regi) gt 10) = p_macBaseCEDS2020(regi,"ch4wstl") / (pm_pop("%cm_emifacs_baseyear%",regi) * (1000*pm_gdp("%cm_emifacs_baseyear%",regi) / (pm_pop("%cm_emifacs_baseyear%",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2"));
p_emineg_econometric(regi,"ch4wsts","p1")$(pm_gdp_gdx("%cm_emifacs_baseyear%",regi)/pm_pop("%cm_emifacs_baseyear%",regi) gt 10) = p_macBaseCEDS2020(regi,"ch4wsts") / (pm_pop("%cm_emifacs_baseyear%",regi) * (1000*pm_gdp("%cm_emifacs_baseyear%",regi) / (pm_pop("%cm_emifacs_baseyear%",regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2"));
$endif

display p_emineg_econometric;

*** Calculate total FE demand of previous iteration or input gdx.
*** Required as a weight for penalty terms
p_demFeSector0(ttot,regi,entySe,entyFe,sector,emiMkt) = vm_demFeSector.l(ttot,regi,entySe,entyFe,sector,emiMkt);

pm_demFeTotal0(ttot, regi)
  = sum((entySe,entyFe,sector,emiMkt)$( sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt) ),
  p_demFeSector0(ttot,regi,entySe,entyFe,sector,emiMkt))
;

***--------------------------------------
*** calculate some emission factors
***--------------------------------------
*** calculate global emission factor
loop (emi2fuel(entyPe,enty),
  p_efFossilFuelExtrGlo(entyPe,enty)
  = sum(regi, p_emiFossilFuelExtr(regi,entyPe))
  / sum((rlf,regi), vm_fuExtr.l("%cm_emifacs_baseyear%",regi,entyPe,rlf));

  loop (regi,
    sm_tmp =  sum(rlf, vm_fuExtr.l("%cm_emifacs_baseyear%",regi,entyPe,rlf));

    p_efFossilFuelExtr(regi,entyPe,enty)$( sm_tmp )
      = p_emiFossilFuelExtr(regi,entyPe) / sm_tmp;

    p_efFossilFuelExtr(regi,entyPe,enty)$( NOT sm_tmp )
      = p_efFossilFuelExtrGlo(entyPe,enty);
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
***    MAgPIE coupling: run MAgPIE
***--------------------------------------

*** Update pm_macBase when Magpie coupling is active, otherwise set it back 
*** to input-data values. Since it has been overwritten in the previous Nash  
*** iteration by calculations that follow further down, it must be set back to 
*** initial values before these calculations are repeated in the current Nash iteration.

if (cm_MAgPIE_Nash eq 1,
  sm_tmp  = logfile.nr;
  sm_tmp2 = logfile.nd;
  logfile.nr = 1;
  logfile.nd = 0;
  s_magIter = s_magIter + 1;
  put_utility  "exec" / "Rscript mag2rem.R " s_magIter;
  logfile.nr = sm_tmp;
  logfile.nd = sm_tmp2;
*** MAgPIE coupling active: update pm_macBaseMagpie
  Execute_Loadpoint 'magpieData.gdx' f_macBaseMagpie_coupling;
  pm_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f_macBaseMagpie_coupling(ttot,regi,emiMacMagpie);
*** In coupled runs overwrite pebiolc production from look-up table with actual MAgPIE values
*** Read production of 2nd gen. purpose grown bioenergy from MAgPIE (given to MAgPIE from previous Remind run)
  Execute_Loadpoint 'magpieData.gdx' pm_pebiolc_demandmag;
else 
*** No MAgPIE coupling active: set pm_macBaseMagpie back to initial values, since it gets changed by calculations further down in each Nash iteration
  pm_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f_macBaseMagpie(ttot,regi,emiMacMagpie,"%cm_LU_emi_scen%","%cm_rcp_scen%");
);

*** DK: xxx code moved here from core/preloop.gms
*** The N2O emissions generated during biomass production in agriculture (in MAgPIE)
*** are represented in REMIND by applying the n2obio emission factor (zero in coupled runs)
*** in q_macBase. In standaolne runs the resulting emissions need to be subtracted (see below)
*** from the exogenous emission baseline read from MAgPIE, since the baseline already implicitly 
*** includes the N2O emissions from biomass. In q_macBase in core/equations.gms the N2O 
*** emissions resulting from the actual biomass demand in REMIND are then added again. 
*** In case some inconsistencies between pm_pebiolc_demandmag and pm_macBaseMagpie lead to
*** negative values, set the value to 0 instead, since negative values may lead to 
*** infeasibilities.
display pm_macBaseMagpie;
pm_macBaseMagpie(t,regi,"n2ofertin") = max(0, pm_macBaseMagpie(t,regi,"n2ofertin") - (p_efFossilFuelExtr(regi,"pebiolc","n2obio") * pm_pebiolc_demandmag(t,regi)));
display pm_macBaseMagpie;

$IFTHEN.scaleEmiHist %c_scaleEmiHistorical% == "on"
*** Re-scale MAgPie reference CH4 and N2O emissions to be inline with eurostat
*** data (depending on the region MAgPIE non-CO2 GHG emissions can be up to 
*** twice as high as historic emissions). This involves different emission variables in
*** pm_macBaseMagpie and additionall agwaste variables from p_macBaseExo
display p_macBaseExo;

*** Define rescale factor for MAgPIE CH4 emissions
p_aux_scaleEmiHistorical_ch4(regi)$p_histEmiSector("2005",regi,"ch4","agriculture","process") =
  (p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) !!no rescaling needed - REMIND-internal unit is Mt CH4
    /
  (sum(enty$emiMacMagpieCH4(enty), pm_macBaseMagpie("2005",regi,enty)) + p_macBaseExo("2005",regi,"ch4agwaste"));
*** Rescale CH4 emissions so that all subtypes add up to the historic values
*** pm_macBaseMagpie
pm_macBaseMagpie(ttot,regi,enty)$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_ch4(regi) AND emiMacMagpieCH4(enty)) =
  pm_macBaseMagpie(ttot,regi,enty) * p_aux_scaleEmiHistorical_ch4(regi);
*** p_macBaseExo
p_macBaseExo(ttot,regi,"ch4agwaste")$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_ch4(regi)) =
  p_macBaseExo(ttot,regi,"ch4agwaste") * p_aux_scaleEmiHistorical_ch4(regi);

*** Define rescale factor for MAgPIE N2O emissions
p_aux_scaleEmiHistorical_n2o(regi)$p_histEmiSector("2005",regi,"n2o","agriculture","process") =
  p_histEmiSector("2005",regi,"n2o","agriculture","process")/( 44 / 28) !! rescaling to Mt N (internal unit for N2O emissions), since eurostat uses 298 to convert N2O to CO2eq
    /
  (sum(enty$emiMacMagpieN2O(enty), pm_macBaseMagpie("2005",regi,enty)) + p_macBaseExo("2005",regi,"n2oagwaste"));
*** Rescale N2O emissions so that all subtypes add up to the historic values
*** pm_macBaseMagpie
pm_macBaseMagpie(ttot,regi,enty)$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_n2o(regi) AND emiMacMagpieN2O(enty)) =
  pm_macBaseMagpie(ttot,regi,enty) * p_aux_scaleEmiHistorical_n2o(regi);
*** p_macBaseExo
p_macBaseExo(ttot,regi,"n2oagwaste")$((ttot.val ge 2005) AND p_aux_scaleEmiHistorical_n2o(regi)) =
  p_macBaseExo(ttot,regi,"n2oagwaste") * p_aux_scaleEmiHistorical_n2o(regi);

display pm_macBaseMagpie;
$ENDIF.scaleEmiHist

!! all net negative co2luc
p_macBaseMagpieNegCo2(t,regi) = pm_macBaseMagpie(t,regi,"co2luc")$(pm_macBaseMagpie(t,regi,"co2luc") < 0);

*** Rescale agricultural emissions baseline if c_agricult_base_shift switch is activated
$IFTHEN.agricult_base_shift not "%c_agricult_base_shift%" == "off"

p_macBaseMagpie_beforeShift(t,regi,enty)=pm_macBaseMagpie(t,regi,enty);
*** gradual phase-in of rescaling until 2040
p_agricult_shift_phasein(t) = 0;
p_agricult_shift_phasein("2025") = 0.25;
p_agricult_shift_phasein("2030") = 0.5;
p_agricult_shift_phasein("2035") = 0.75;
p_agricult_shift_phasein(t)$(t.val ge 2040) = 1;

*** rescaling all ext_regi provided by c_agricult_base_shift
loop((ext_regi)$(p_agricult_base_shift(ext_regi)), 
 loop(regi$regi_groupExt(ext_regi,regi),

    pm_macBaseMagpie(t,regi,enty)$( emiMac2sector(enty,"agriculture","process","ch4") 
                                    OR emiMac2sector(enty,"agriculture","process","n2o"))
    = p_macBaseMagpie_beforeShift(t,regi,enty)
      * (1 + p_agricult_shift_phasein(t)
           * p_agricult_base_shift(ext_regi));

  );
);


display pm_macBaseMagpie;
$ENDIF.agricult_base_shift  

***--------------------------------------
*** Non-energy emissions reductions (MAC)
***--------------------------------------

*** make sure that minimum CO2 luc emissions given in p_macPolCO2luc do not exceed the baseline
loop(regi,
     loop(ttot,
          if( (p_macPolCO2luc(ttot,regi) > pm_macBaseMagpie(ttot,regi,"co2luc")),
                    p_macPolCO2luc(ttot,regi) = pm_macBaseMagpie(ttot,regi,"co2luc")
             );
          );
    );

p_priceCO2(ttot,regi) = pm_taxCO2eqSum(ttot,regi) * 1000;

*** Define co2 price for entities that are used in MAC.
loop((enty,enty2)$emiMac2mac(enty,enty2), !! make sure that both mac sectors and mac curves have prices asigned as both sets are used in calculations below
  p_priceCO2forMAC(ttot,regi,enty) = p_priceCO2(ttot,regi);
  p_priceCO2forMAC(ttot,regi,enty2) = p_priceCO2(ttot,regi);
);

*** Redefine the MAC price for regions with emission tax defined by the regipol module
$IFTHEN.emiMkt not "%cm_emiMktTarget%" == "off"
 loop(ext_regi$regiEmiMktTarget(ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
*** average CO2 price aggregated by FE
    p_priceCO2(t,regi) = ( (sum(emiMkt, pm_taxemiMkt(t,regi,emiMkt) * sum((entySe,entyFe,sector)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt)))) / (sum((entySe,entyFe,sector,emiMkt)$(sefe(entySe,entyFe) AND entyFe2Sector(entyFe,sector) AND sector2emiMkt(sector,emiMkt)),vm_demFeSector.l(t,regi,entySe,entyFe,sector,emiMkt))) )*1000;
    loop((enty,emiMkt)$(macSector2emiMkt(enty,emiMkt)),
      loop(enty2$emiMac2mac(enty,enty2), !! make sure that both mac sectors and mac curves have prices asigned as both sets are used in calculations below
        p_priceCO2forMAC(t,regi,enty) = pm_taxemiMkt(t,regi,emiMkt)* 1000;
        p_priceCO2forMAC(t,regi,enty2) = pm_taxemiMkt(t,regi,emiMkt)* 1000;
        p_priceCO2forMAC(t,regi,"co2chemicals") = pm_taxemiMkt(t,regi,"ETS")* 1000;
        p_priceCO2forMAC(t,regi,"co2steel") = pm_taxemiMkt(t,regi,"ETS")* 1000;
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
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val lt cm_startyear)    = 0;
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear)    = 0.1 * p_priceCO2forMAC(ttot,regi,MacSectorMagpie);
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+5)  = 0.2 * p_priceCO2forMAC(ttot,regi,MacSectorMagpie);
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+10) = 0.4 * p_priceCO2forMAC(ttot,regi,MacSectorMagpie);
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val eq cm_startyear+15) = 0.8 * p_priceCO2forMAC(ttot,regi,MacSectorMagpie);
p_priceCO2forMAC(ttot,regi,MacSectorMagpie)$(ttot.val ge cm_startyear+20) = p_priceCO2forMAC(ttot,regi,MacSectorMagpie);
*** 3. Reduce co2 price for land-use entities by level of development (uses the same data from MOINPUT as MAgPIE for im_development_state)
p_priceCO2forMAC(ttot,regi,MacSectorMagpie) = p_priceCO2forMAC(ttot,regi,MacSectorMagpie) * p_developmentState(ttot,regi);
*** 4. Price for MACs was calculated with AR4 GWPs --> convert CO2 price with old GWPs here as well
p_priceCO2forMAC(ttot,regi,emiMacMagpieN2O) = p_priceCO2forMAC(ttot,regi,emiMacMagpieN2O) * (s_gwpN2O_AR4/s_gwpN2O);
p_priceCO2forMAC(ttot,regi,emiMacMagpieCH4) = p_priceCO2forMAC(ttot,regi,emiMacMagpieCH4) * (s_gwpCH4_AR4/s_gwpCH4);

display p_priceCO2,p_priceCO2forMAC;
***--------------------------------------
*** MAC baselines
***--------------------------------------
*** endogenous in equations.gms
*** econometric
v_macBase.fx(ttot,regi,"ch4wsts")$(ttot.val ge 2005) = p_emineg_econometric(regi,"ch4wsts","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wsts","p2");
v_macBase.fx(ttot,regi,"ch4wstl")$(ttot.val ge 2005) = p_emineg_econometric(regi,"ch4wstl","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"ch4wstl","p2");
v_macBase.fx(ttot,regi,"n2owaste")$(ttot.val ge 2005) = p_emineg_econometric(regi,"n2owaste","p1") * pm_pop(ttot,regi) * (1000*pm_gdp(ttot,regi) / (pm_pop(ttot,regi)*pm_shPPPMER(regi)))**p_emineg_econometric(regi,"n2owaste","p2");

v_macBase.lo(ttot,regi,"co2cement_process")$( ttot.val ge 2005 ) = 0;

*** exogenous
v_macBase.fx(ttot,regi,enty)$emiMacMagpie(enty) = pm_macBaseMagpie(ttot,regi,enty);
v_macBase.fx(ttot,regi,enty)$emiMacExo(enty) = p_macBaseExo(ttot,regi,enty);
v_macBase.fx(ttot,regi,"co2luc") = pm_macBaseMagpie(ttot,regi,"co2luc")-p_macPolCO2luc(ttot,regi);
v_macBase.up(ttot,regi,"n2ofertin") = Inf;
***scale exogenous baselines from van Vuuren to EDGAR v4.2 2005 data or CEDS2024 2020 data
***Since they are exogenous anyway, it's OK to scale to after cm_startyear, but something to watch out for
$ifthen %cm_emifacs_baseyear% == "2005" 
v_macBase.fx(ttot,regi,"n2otrans")$p_macBaseIMAGE("2005",regi,"n2otrans") = p_macBaseIMAGE(ttot,regi,"n2otrans") * (p_macBase2005(regi,"n2otrans") / p_macBaseIMAGE("2005",regi,"n2otrans"));
v_macBase.fx(ttot,regi,"n2oadac")$p_macBaseIMAGE("2005",regi,"n2oadac")  = p_macBaseIMAGE(ttot,regi,"n2oadac")  * (p_macBase2005(regi,"n2oacid")  / (p_macBaseIMAGE("2005",regi,"n2oadac") + p_macBaseIMAGE("2005",regi,"n2onitac")));
v_macBase.fx(ttot,regi,"n2onitac")$(p_macBaseIMAGE("2005",regi,"n2oadac") OR p_macBaseIMAGE("2005",regi,"n2onitac")) = p_macBaseIMAGE(ttot,regi,"n2onitac") * (p_macBase2005(regi,"n2oacid")  / (p_macBaseIMAGE("2005",regi,"n2oadac") + p_macBaseIMAGE("2005",regi,"n2onitac")));
$else
v_macBase.fx(ttot,regi,"n2otrans")$p_macBaseIMAGE("2020",regi,"n2otrans") = p_macBaseIMAGE(ttot,regi,"n2otrans") * (p_macBaseCEDS2020(regi,"n2otrans") / p_macBaseIMAGE("2020",regi,"n2otrans"));
v_macBase.fx(ttot,regi,"n2oadac")$p_macBaseIMAGE("2020",regi,"n2oadac")  = p_macBaseIMAGE(ttot,regi,"n2oadac")  * (p_macBaseCEDS2020(regi,"n2oacid")  / (p_macBaseIMAGE("2020",regi,"n2oadac") + p_macBaseIMAGE("2020",regi,"n2onitac")));
v_macBase.fx(ttot,regi,"n2onitac")$(p_macBaseIMAGE("2020",regi,"n2oadac") OR p_macBaseIMAGE("2020",regi,"n2onitac")) = p_macBaseIMAGE(ttot,regi,"n2onitac") * (p_macBaseCEDS2020(regi,"n2oacid")  / (p_macBaseIMAGE("2020",regi,"n2oadac") + p_macBaseIMAGE("2020",regi,"n2onitac")));
$endif
*** baseline continuation after 2100
v_macBase.fx(ttot,regi,enty)$((ttot.val gt 2100)$((NOT emiMacMagpie(enty)) AND (NOT emiFuEx(enty)) AND (NOT sameas(enty,"n2ofertin")) ))=v_macBase.l("2100",regi,enty);
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
  = min(801, ceil(p_priceCO2forMAC(ttot,regi,enty) / sm_dmac) + 1);

*** If the gas price increase since 2005 is higher than the CO2 price, it will drive CH4 emission abatement.
*** Conversion: p_priceCO2forMAC [$/tCeq]; T$/TWa = 1e6 M$/TWa * s_MtCH4_2_TWa * 1 MtCH4/s_gwpCH4 MtCO2eq * (44/12) MtCO2eq/MtCeq
p_priceGas(ttot,regi)=q_balPe.m(ttot,regi,"pegas")/(qm_budget.m(ttot,regi)+sm_eps) * 1000000 * s_MtCH4_2_TWa * (1/s_gwpCH4) * 44/12;

pm_macStep(ttot,regi,"ch4gas")
  = min(801, ceil(max(p_priceCO2forMAC(ttot,regi,"ch4gas") * (25/s_gwpCH4), max(0,(p_priceGas(ttot,regi)-p_priceGas("2005",regi))) ) / sm_dmac) + 1);
pm_macStep(ttot,regi,"ch4coal")
  = min(801, ceil(max(p_priceCO2forMAC(ttot,regi,"ch4coal") * (25/s_gwpCH4), 0.5 * max(0,(p_priceGas(ttot,regi)-p_priceGas("2005",regi))) ) / sm_dmac) + 1);

*** limit yearly increase of MAC usage to sm_macChange
p_macAbat_lim(ttot,regi,enty)
  = sum(steps$(ord(steps) eq pm_macStep(ttot-1,regi,enty)),
      pm_macAbat(ttot-1,regi,enty,steps)
    )
  + sm_macChange * pm_ts(ttot)
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
p_macUse2005(regi,"ch4wstl")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) ge 10) = 1 - p_macBase2005(regi,"ch4wstl")/v_macBase.l("2005",regi,"ch4wstl");
p_macUse2005(regi,"ch4wsts")$(pm_gdp_gdx("2005",regi)/pm_pop("2005",regi) ge 10) = 1 - p_macBase2005(regi,"ch4wsts")/v_macBase.l("2005",regi,"ch4wsts");

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

*** p_macLevFree(ttot,regi,emiMacMagpie(enty))=0;
*** Set minimum abatment levels based on historical emissions
p_macLevFree("2010",regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst"))) = max( 0, 1 - (p_histEmiSector("2010",regi,"ch4","agriculture","process")+p_histEmiSector("2010",regi,"ch4","lulucf","process"))/(p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")));
p_macLevFree(ttot,regi,enty)$((ttot.val ge 2015) AND p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"ch4rice") OR sameas(enty,"ch4animals") OR sameas(enty,"ch4anmlwst"))) = max( 0, 1 - (p_histEmiSector("2015",regi,"ch4","agriculture","process")+p_histEmiSector("2015",regi,"ch4","lulucf","process"))/(p_histEmiSector("2005",regi,"ch4","agriculture","process")+p_histEmiSector("2005",regi,"ch4","lulucf","process")) );
p_macLevFree("2010",regi,enty)$(p_histEmiSector("2005",regi,"ch4","agriculture","process") AND (sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp"))) = max( 0, 1 - (p_histEmiSector("2010",regi,"n2o","agriculture","process")+p_histEmiSector("2010",regi,"n2o","lulucf","process"))/(p_histEmiSector("2005",regi,"n2o","agriculture","process")+p_histEmiSector("2005",regi,"n2o","lulucf","process")) );
p_macLevFree(ttot,regi,emiMacMagpie(enty))$((ttot.val ge 2015) AND p_histEmiSector("2005",regi,"n2o","agriculture","process") AND (sameas(enty,"n2ofertin") OR sameas(enty,"n2ofertcr") OR sameas(enty,"n2oanwstc") OR sameas(enty,"n2oanwstm") OR sameas(enty,"n2oanwstp"))) = max( 0, 1 - (p_histEmiSector("2015",regi,"n2o","agriculture","process")+p_histEmiSector("2015",regi,"n2o","lulucf","process"))/(p_histEmiSector("2005",regi,"n2o","agriculture","process")+p_histEmiSector("2005",regi,"n2o","lulucf","process")) );

p_macLevFree("2010",regi,enty)$((p_histEmiMac("2010",regi,enty)) AND (sameas(enty,"ch4wstl") OR sameas(enty,"ch4wsts"))) = max( 0, 1 - (p_histEmiMac("2010",regi,enty)) /v_macBase.l("2010",regi,enty) );
p_macLevFree(ttot,regi,enty)$((ttot.val ge 2015) AND (p_histEmiMac("2015",regi,enty)) AND (sameas(enty,"ch4wstl") OR sameas(enty,"ch4wsts"))) = max( 0, 1 - (p_histEmiMac("2015",regi,enty))/v_macBase.l("2015",regi,enty) );

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

*** Limit MAC abatement level increase to sm_macChange (default: 5 % p.a.)
loop (ttot$( ttot.val ge 2015 ),
  pm_macAbatLev(ttot,regi,MacSector(enty))
    = min(
        pm_macAbatLev(ttot,regi,enty),

          pm_macAbatLev(ttot-1,regi,enty)
        + (sm_macChange * pm_ts(ttot))
      );
);

Display "computed abatement levels at carbon price", pm_macAbatLev;


***--------------------------------------
*** MAC costs
***--------------------------------------
*** Integral under MAC cost curve
*** costs = baseline emissions * price step * sum [over i to n] (q_n - q_i)
*** q_i = abatement [fraction] at step i
pm_macCost(t,regi,emiMacSector(enty))
  = 1e-3
  * p_macCostSwitch(enty)
  * p_emi_quan_conv_ar4(enty)
  * v_macBase.l(t,regi,enty)
  * sm_dmac
  * ( ( sum(emiMac2mac(enty,enty2),
          pm_macStep(t,regi,enty2)
        )
      * sum(steps$( ord(steps) eq sum(emiMac2mac(enty,enty2),
                                    pm_macStep(t,regi,enty2)) ),
          sum(emiMac2mac(enty,enty2), pm_macAbat(t,regi,enty2,steps))
        )
      )
    - sum(steps$( ord(steps) le sum(emiMac2mac(enty,enty2),
                                  pm_macStep(t,regi,enty2)) ),
        sum(emiMac2mac(enty,enty2), pm_macAbat(t,regi,enty2,steps))
      )
    );

*JeS* add 50% of abated CH4 from coal MACs to PEprod. CH4 from oil production is usually flared and not re-used. CH4 from gas production is mostly avoided losses from leakages.
*** These losses are not accounted for, so neither are the avoided losses.
*** conversion factor MtCH4 --> TWa: 1 MtCH4 = 1.23 * 10^6 toe * 42 GJ/toe * 10^-9 EJ/GJ * 1 TWa/31.536 EJ = 0.001638 (BP statistical review)
p_macPE(ttot,regi,enty) = 0.0;
p_macPE(ttot,regi,"pegas")$(ttot.val gt 2005) = s_MtCH4_2_TWa * 0.5 * (v_macBase.l(ttot,regi,"ch4coal")-vm_emiMacSector.l(ttot,regi,"ch4coal"));

*** ACM initialise se-fe shares in CDR sector (from CDR module: dac, OAE, EW) from other sector se-fe shares
*** This is necessary as hydrocarbon FE demand for CDR sector may be zero or small and then leads to solver issues
v_shSeFeSector.l(ttot,regi,entySe,"fedie","CDR","ETS") =  v_shSeFeSector.l(ttot,regi,entySe,"fedie","trans","ES");
v_shSeFeSector.l(ttot,regi,entySe,"fegas","CDR","ETS") =  v_shSeFeSector.l(ttot,regi,entySe,"fegas","indst","ETS");

*** EOF ./core/presolve.gms
