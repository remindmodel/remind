*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/bounds.gms

*' @title{extrapage: "00_model_assumptions"} Model Assumptions
*' @code{extrapage: "00_model_assumptions"}

*' ### Model Bounds and Assumptions

*** The bounds file follows the following structure:
***   1. Conopt optimisation bounds
***   2. Historical and near-term capacities
***   3. Assumptions on biomass
***   4. Assumptions on carbon management
***   5. Early retirement and phase-out of technologies
***   6. Energy demand sectors and final energy
***   7. Assumptions for emissions
***   8. Other bounds (not fitting into the above categories or need to overwrite previous bounds)
*** Please take this structure into account when adding new parameters, variables or equations.

*** ==================================================================
*' #### 1. Conopt optimisation bounds
*** ==================================================================

*' Set lower bounds on variables otherwise the conopt solver doesn't see a benefit from changing variable value away from 0
*' These lower bounds are set so low that they do not restrict the results

*' Lower limit on all P2SE technologies capacities to 100 kW of all technologies and all time steps
loop(pe2se(enty,enty2,te) $ (
    (not sameas(te,"biotr")) and
    (not sameas(te,"biodiesel")) and
    (not sameas(te,"bioeths")) and
    (not sameas(te,"gasftcrec")) and
    (not sameas(te,"gasftrec")) and
    (not sameas(te,"tnrs")) and
    (not teBiopyr(te))
  ),
  vm_cap.lo(t,regi,te,"1") $ (t.val >= 2030 and t.val <= 2070) = 1e-7;
  if(not teCCS(te), 
    vm_deltaCap.lo(t,regi,te,"1") $ (t.val >= 2030 and t.val <= 2070) = 1e-8;
  );
);

*' Make sure that the model also sees the se2se technologies (seel <--> seh2)
loop(se2se(enty,enty2,te),
  vm_cap.lo(t,regi,te,"1") $ (t.val >= 2030) = 1e-7;
);

*' Lower bound of 10 kW on each of the different grades for renewables with multiple resource grades
loop(teRe2rlfDetail(te,rlf),
  loop(regi $ (pm_dataren(regi,"maxprod",rlf,te) > 0),
    v_capDistr.lo(t,regi,te,rlf) $ (t.val >= 2015) = 1e-8;
*** CB: make sure that grade distribution in early time steps with capacity fixing is close to optimal one assumed for vm_capFac calibration,
***     divide by p_aux_capacityFactorHistOverREMIND to correct for deviation of REMIND capacity factors from historic capacity factors
    v_capDistr.lo("2015",regi,te,rlf) = 0.9 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
    v_capDistr.lo("2020",regi,te,rlf) = 0.9 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
  );
);


*** ==================================================================
*' #### 2. Historical and near-term capacities
*** ==================================================================
*' ##### Capacity for fossils and renewables
*** ------------------------------------------------------------------
loop(t $ (t.val >= 2015 and t.val <= 2025),
*** fix renewable capacities to real world historical values if available
  vm_cap.lo(t,regi,teVRE(te),"1") $ pm_histCap(t,regi,te) = 0.95 * pm_histCap(t,regi,te);
  if(t.val <= 2020, !! TODO: activate 2025 upper-bound when consolidated data available
    vm_cap.up(t,regi,teVRE(te),"1") $ pm_histCap(t,regi,te) = 1.05 * pm_histCap(t,regi,te);
  );
*** broader bounds for renewables with lower data quality
  loop(te $ (sameas(te, "hydro") or sameas(te, "geohdr")),
    vm_cap.lo(t,regi,te,"1") $ pm_histCap(t,regi,te) = 0.7 * pm_histCap(t,regi,te);
    vm_cap.up(t,regi,te,"1") $ pm_histCap(t,regi,te) = 1.4 * pm_histCap(t,regi,te);
  );

*** lower bound on capacities for ngcc and ngt and gaschp for regions defined at the pm_histCap file
  loop(te $ (sameas(te,"ngcc") or sameas(te,"ngt") or sameas(te,"gaschp")),
    vm_cap.lo(t,regi,te,"1") $ pm_histCap(t,regi,te) = 0.95 * pm_histCap(t,regi,te);
  );
=======
*' completely switching off technologies that are not used in the current version of REMIND, although their parameters are declared:
loop(all_te $ (
    sameas(all_te, "solhe") OR
    sameas(all_te, "fnrs") OR
    sameas(all_te, "pcc") OR
    sameas(all_te, "pco") OR
    sameas(all_te, "wind") OR
    sameas(all_te, "storwind") OR
    sameas(all_te, "gridwind")
  ),
  vm_cap.fx(t,regi,all_te,rlf) = 0;
  vm_deltaCap.fx(t,regi,all_te,rlf) = 0;
>>>>>>> 2077ea43 (Update WACC branch with latest changes)
);

loop(regi $ regi_group("EUR_regi",regi),
*' bounds on 2025 variable renewables generation in Europe based on historical growth rates
*** the bound takes the maximum annual growth rate for any year between 2019 and 2024, 
*** increases it by 30% to allow for growth acceleration, and applies it for the two years from 2023 to 2025
  vm_prodSe.up("2025",regi,"pewin","seel","windon") = p_histProdSe("2023",regi,"seel","windon") * power((p_maxhistProdSeGrowthRate(regi,"seel","windon") * 1.3 + 1), 2);
  vm_prodSe.up("2025",regi,"pesol","seel","spv")    = p_histProdSe("2023",regi,"seel","spv")    * power((p_maxhistProdSeGrowthRate(regi,"seel","spv")    * 1.3 + 1), 2);

*' no investment into oil turbines in Europe
  vm_deltaCap.up(t,regi,"dot","1") $ (t.val > 2005) = 1e-6;
);

*** RP: add lower bound on 2020 coal chp and upper bound on gas chp based on IEA data to have a more realistic starting point
vm_prodSe.lo("2020",regi,"pecoal","seel","coalchp") = 0.8 * pm_IO_output("2020",regi,"pecoal","seel","coalchp") ;
vm_prodSe.up("2020",regi,"pegas","seel","gaschp") = 1e-4 + 1.3 * pm_IO_output("2020",regi,"pegas","seel","gaschp") ;


*** ------------------------------------------------------------------
*' ##### Near-term capacity for electrolysis and hydrogen 
*** ------------------------------------------------------------------
*' set lower and upper bounds for 2025 and 2030 based on projects annoucements from IEA Hydryogen project database:
*' https://www.iea.org/data-and-statistics/data-product/hydrogen-production-and-infrastructure-projects-database
*' distribute to regions via GDP share of 2025 (we do not use later time steps as they may have different GDPs depending on the scenario)
*' in future this should be differentiated by region based on regionalized input data of project announcements
*' 2 GW(el) at least globally in 2025, about operational capacity as of 2023
vm_cap.lo("2025",regi,"elh2","1") =   2e-3 * pm_eta_conv("2025",regi,"elh2") * pm_gdp("2025",regi) / sum(regi2,pm_gdp("2025",regi2));
*' 20 GW(el) at maximum globally in 2025 (be more generous to not overconstrain regions which scale-up fastest)
vm_cap.up("2025",regi,"elh2","1") =  20e-3 * pm_eta_conv("2025",regi,"elh2") * pm_gdp("2025",regi) / sum(regi2,pm_gdp("2025",regi2));
*' 100 GW(el) at maximum globally in 2030 (upper end of feasibility range in Odenweller et al. 2022, https://doi.org/10.1038/s41560-022-01097-4, Fig. 4)
vm_cap.up("2030",regi,"elh2","1") = 100e-3 * pm_eta_conv("2025",regi,"elh2") * pm_gdp("2025",regi) / sum(regi2,pm_gdp("2025",regi2));

*' upper bound of 0.5 EJ/yr to prevent building too much grey hydrogen before 2020, distributed to regions via GDP share
vm_cap.up("2020",regi,"gash2","1")  = 0.5 * sm_EJ_2_TWa * pm_gdp("2020",regi) / sum(regi2, pm_gdp("2020",regi2));
*' Set upper bounds on biomass gasification for hydrogen production, which is not deployed as of 2025
*' allow for small production of at most 0.1 EJ/yr by 2030 for each technology globally, distributed to regions by GDP share in 2025
vm_cap.up("2030",regi,"bioh2","1")  = 0.1 * sm_EJ_2_TWa * pm_gdp("2025",regi) / sum(regi2, pm_gdp("2025",regi2));
vm_cap.up("2030",regi,"bioh2c","1") = 0.1 * sm_EJ_2_TWa * pm_gdp("2025",regi) / sum(regi2, pm_gdp("2025",regi2));
*' allow zero vm_deltaCap for bio-hydrogen up to 2030 to be consistent with above bounds
vm_deltaCap.lo(t,regi,"bioh2","1")  $ (t.val <= 2030) = 0;
vm_deltaCap.lo(t,regi,"bioh2c","1") $ (t.val <= 2030) = 0;


*** ------------------------------------------------------------------
*' ##### Technologies depending on learning and tech_stat
*** ------------------------------------------------------------------
*** RP 20160126: set vm_costTeCapital to pm_inco0_t for all technologies that are non-learning
vm_costTeCapital.fx(ttot,regi,teNoLearn) = pm_inco0_t("2005",regi,teNoLearn); !! use 2005 value for the past
vm_costTeCapital.fx(t,   regi,teNoLearn) = pm_inco0_t(t,regi,teNoLearn);

*** RP: theoretically, floor costs represent the lower bound of investment costs for learnTe. However, with regional 
*** variations of 2015 costs and long-term costs being high in SSP3/SSP5, this can be different -> set lower bound to 0.2
vm_costTeCapital.lo(t,regi,teLearn) = 0.2 * pm_data(regi,"floorcost",teLearn);

*' No battery storage in 2010
vm_cap.up("2010",regi,teStor,"1") = 0;

*** NR: cumulated capacity never falls below initial cumulated capacity:
vm_capCum.lo(ttot,regi,teLearn) $ (ttot.val >= cm_startyear) = pm_data(regi,"ccap0",teLearn);
*** exception for tech_stat 4 technologies whose ccap0 refers to 2025 as these technologies don't exist in 2005
vm_capCum.lo(ttot,regi,teLearn) $ (pm_data(regi,"tech_stat",teLearn) = 4 and ttot.val <= 2020) = 0;


*' Advanced technologies shouldn't be built prior to 2015/2020
loop(regi,
  loop(teNoLearn(te) $ (pm_data(regi,"tech_stat",te) = 2),
    vm_deltaCap.fx("2010",regi,te,rlf) = 0;
    vm_cap.lo("2010",regi,te,rlf) = 0;
    vm_cap.lo("2015",regi,te,rlf) = 0;
  );
  loop(teNoLearn(te) $ (pm_data(regi,"tech_stat",te) = 3),
    vm_deltaCap.fx("2010",regi,te,rlf) = 0;
    vm_deltaCap.fx("2015",regi,te,rlf) = 0;
    vm_cap.lo("2010",regi,te,rlf) = 0;
    vm_cap.lo("2015",regi,te,rlf) = 0;
    vm_cap.lo("2020",regi,te,rlf) = 0;
  );
);

*' no technologies with tech_stat 4 before 2025
vm_cap.fx(t,regi,te,rlf) $ (t.val <= 2020 and pm_data(regi,"tech_stat",te) = 4) = 0;
*** initialize cumulative capacity of tech_stat 4 technologies at 0 
*** (not at ccap0 from generisdata_tech.prn which gives the cucmulative capacity
***  at the initial investment cost of the first year in which the technology can be built)
vm_capCum.fx(t0,regi,teLearn) $ (pm_data(regi,"tech_stat",teLearn) = 4) = 0;
*** tech_stat 4 technologies don't learn before 2025, so capital cost should be fixed
vm_costTeCapital.fx(t,regi,teLearn) $ (t.val <= 2020 and pm_data(regi,"tech_stat",teLearn) = 4) = fm_dataglob("inco0",teLearn);

*** no technologies with tech_stat 5 before 2030
vm_deltaCap.fx(t,regi,te,rlf) $ (t.val <= 2025 and pm_data(regi,"tech_stat",te) = 5) = 0;


*** ------------------------------------------------------------------
*' ##### Capacity for nuclear energy
*** TODO: data update ------------------------------------------------
if(cm_startyear <= 2015,
  p_CapFixFromRWfix("2015",regi,"tnrs") = max( pm_aux_capLowerLimit("tnrs",regi,"2015") , pm_NuclearConstraint("2015",regi,"tnrs") );
  p_deltaCapFromRWfix("2015",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015") )
                                    / 7.5;  !! this parameter is currently only for display and not further used to fix anything
  p_deltaCapFromRWfix("2010",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015") )
                                    / 7.5; !! this parameter is currently only for display and not further used to fix anything
  vm_cap.fx("2015",regi,"tnrs","1") = p_CapFixFromRWfix("2015",regi,"tnrs");
);

if(cm_startyear <= 2020, !! require the realization of at least 70% of the plants that are currently under construction and thus might be finished until 2020 - should be updated with real-world 2020 numbers
   vm_deltaCap.lo("2020",regi,"tnrs","1") = 0.70 * pm_NuclearConstraint("2020",regi,"tnrs") / 5;
   vm_deltaCap.up("2020",regi,"tnrs","1") = pm_NuclearConstraint("2020",regi,"tnrs") / 5;
);
if(cm_startyear <= 2025, !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 30% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2025",regi,"tnrs","1") = pm_NuclearConstraint("2025",regi,"tnrs") / 5;
);
if(cm_startyear <= 2030, !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 70% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2030",regi,"tnrs","1") = pm_NuclearConstraint("2030",regi,"tnrs") / 5;
);

display p_CapFixFromRWfix, p_deltaCapFromRWfix;


*' switch to prevent new nuclear capacities after 2020, until then all currently planned plants are built
if(cm_nucscen = 5,
  vm_deltaCap.up(t,regi_nucscen,"tnrs",rlf) $ (t.val > 2020) = 1e-6;
  vm_cap.lo(t,regi_nucscen,"tnrs",rlf) $ (t.val > 2015) = 0;
);


*** ==================================================================
*' #### 3. Assumptions on biomass
*** (move to biomass module?) ========================================

*' Traditional biomass use is phased out on an exogeneous time path
*** Note: make sure that this matches with the settings for residues in modules/05_initialCap/on/preloop.gms

*** BS/DK:
*' Developed regions phase out quickly (no new capacities)
vm_deltaCap.fx(t,regi,"biotr",rlf) $ (t.val > 2005) = 0;
*' Developing regions (defined by GDP PPP threshold) phase out more slowly (+ varied by SSP)
loop(regi,
  if( (pm_gdp("2005",regi) / pm_pop("2005",regi) / pm_shPPPMER(regi)) < 4,
    vm_deltaCap.fx("2010",regi,"biotr","1") = 1.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2015",regi,"biotr","1") = 0.9  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2020",regi,"biotr","1") = 0.7  * vm_deltaCap.lo("2005",regi,"biotr","1");
$ifthen not %cm_tradbio_phaseout% == "fast" !! cm_tradbio_phaseout
    vm_deltaCap.fx("2025",regi,"biotr","1") = 0.5  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2030",regi,"biotr","1") = 0.4  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2035",regi,"biotr","1") = 0.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2040",regi,"biotr","1") = 0.2  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2045",regi,"biotr","1") = 0.15 * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2050",regi,"biotr","1") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2055",regi,"biotr","1") = 0.1  * vm_deltaCap.lo("2005",regi,"biotr","1");
$endif
  );
);

*' Quick phaseout in SSP1 and SSP5
$if %cm_GDPpopScen% == "SSP1"   vm_deltaCap.fx(t,regi,"biotr","1") $ (t.val > 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");
$if %cm_GDPpopScen% == "SSP5"   vm_deltaCap.fx(t,regi,"biotr","1") $ (t.val > 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");

*' Quickest phaseout in SDP scenarios (no new capacities allowed)
$if %cm_GDPpopScen% == "SDP"    vm_deltaCap.up(t,regi,"biotr","1") $ (t.val > 2020) = 0;
$if %cm_GDPpopScen% == "SDP_EI" vm_deltaCap.up(t,regi,"biotr","1") $ (t.val > 2020) = 0;
$if %cm_GDPpopScen% == "SDP_MC" vm_deltaCap.up(t,regi,"biotr","1") $ (t.val > 2020) = 0;
$if %cm_GDPpopScen% == "SDP_RC" vm_deltaCap.up(t,regi,"biotr","1") $ (t.val > 2020) = 0;


*' Switch to deactivate technologies that produce liquids from lignocellulosic biomass
if(c_bioliqscen = 0, !! no bioliquids technologies
  vm_deltaCap.up(t,regi,"bioftrec",rlf)  $ (t.val > 2005) = 1e-6;
  vm_deltaCap.up(t,regi,"bioftcrec",rlf) $ (t.val > 2005) = 1e-6;
  vm_deltaCap.up(t,regi,"bioethl",rlf)   $ (t.val > 2005) = 1e-6;
  vm_deltaCap.up(t,regi,"biopyrliq",rlf) $ (t.val > 2025) = 1e-8;
);

*' Switch to prevent new capacities of 1st generation biofuel technologies after 2030, allowing more cost-efficient
*' and more sustainable new generation of biofuel technologies free entrance to the market
if(cm_1stgen_phaseout = 1,
   vm_deltaCap.up(t,regi,"bioeths",rlf)   $ (t.val > 2030) = 0;
   vm_deltaCap.up(t,regi,"biodiesel",rlf) $ (t.val > 2030) = 0;
);

*' Switch to deactivate technologies that produce hydrogen from lignocellulosic biomass
if(c_bioh2scen = 0, !! no bioh2 technologies
  vm_deltaCap.up(t,regi,"bioh2",rlf)  $ (t.val > 2005) = 1e-6;
  vm_deltaCap.up(t,regi,"bioh2c",rlf) $ (t.val > 2005) = 1e-6;
);


*' Switches to activate pyrolysis technologies
loop(teBiopyr(te) $ (not sameas(te, "biopyrliq")), !! established industrial technologies
  vm_cap.fx(t,regi,te,rlf) $ (t.val <= 2015) = 0; 
  if(c_biopyrEstablished = 0,
    vm_deltaCap.fx(t,regi,te,rlf) $ (t.val >= cm_startyear) = 0; 
  else
    vm_cap.up("2020",regi,te,rlf) = p_boundCapBiochar("2020",regi) * sm_tBC_2_TWa / 3; 
    vm_cap.lo("2025",regi,te,rlf) = p_boundCapBiochar("2025",regi) * sm_tBC_2_TWa / 3; 
    !! set upper bound to 70% above the lower bound which is based on 2024 values    
    vm_cap.up("2025",regi,te,rlf) = 1.7 * p_boundCapBiochar("2025",regi) * sm_tBC_2_TWa / 3;                      
  );
);

loop(te $ sameas(te, "biopyrliq"), !! does not yet exist commercially
  vm_cap.fx(t,regi,"biopyrliq",rlf)  $ (t.val <= 2025) = 0;
  vm_deltaCap.lo(t,regi,"biopyrliq",rlf) $ (t.val > cm_startyear) = 1e-8; !! initiate a negligible increase to help model find the technology
  vm_deltaCap.up(t,regi,"biopyrliq",rlf) $ (t.val > cm_startyear) = inf; !! revert fixing to small values above
  if(c_biopyrliq = 0,
    vm_deltaCap.fx(t,regi,"biopyrliq",rlf) $ (t.val >= cm_startyear) = 0; 
  );
);


*** ==================================================================
*' #### 4. Assumptions on carbon management
*** ==================================================================

*** EOF ./core/bounds.gms
