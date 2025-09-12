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

<<<<<<< HEAD
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

<<<<<<< HEAD
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
=======
***------------------------------------------------------------------------------------------
*' #### implement switch for scenarios with different carbon capture assumptions:
*** ------------------------------------------------------------------------------------------
*'
*' carbon capture bounds
*'
if (cm_ccapturescen eq 2,  !! no carbon capture at all
  vm_cap.fx(t,regi_capturescen,"ngccc",rlf)        = 0;
  vm_cap.fx(t,regi_capturescen,"ccsinje",rlf) = 0;
  vm_cap.fx(t,regi_capturescen,"gash2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"igccc",rlf)        = 0;
  vm_cap.fx(t,regi_capturescen,"coalftcrec",rlf)   = 0;
  vm_cap.fx(t,regi_capturescen,"coalh2c",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"biogasc",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"bioftcrec",rlf)    = 0;
  vm_cap.fx(t,regi_capturescen,"bioh2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"bioigccc",rlf)     = 0;
elseif (cm_ccapturescen eq 3),  !! no bio carbon capture:
  vm_cap.fx(t,regi_capturescen,"biogasc",rlf)      = 0;
  vm_cap.fx(t,regi_capturescen,"bioftcrec",rlf)    = 0;
  vm_cap.fx(t,regi_capturescen,"bioh2c",rlf)       = 0;
  vm_cap.fx(t,regi_capturescen,"bioigccc",rlf)     = 0;
elseif (cm_ccapturescen eq 4), !! no carbon capture in the electricity sector
  loop(emi2te(enty,"seel",te,"cco2")$( sum(regi_capturescen,pm_emifac("2020",regi_capturescen,enty,"seel",te,"cco2")) > 0 ),
    loop(te2rlf(te,rlf),
      vm_cap.fx(t,regi_capturescen,te,rlf) = 0;
    );
>>>>>>> 2077ea43 (Update WACC branch with latest changes)
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


<<<<<<< HEAD
*** ==================================================================
*' #### 4. Assumptions on carbon management
*** ==================================================================
=======
display p_CapFixFromRWfix, p_deltaCapFromRWfix;

*** ------------------------------------------------------------------------------------------
*RP* implement switch for scenarios with different nuclear assumptions:
*** ------------------------------------------------------------------------------------------
vm_deltaCap.up(t,regi,"fnrs",rlf)$(t.val ge 2010)= 0;
vm_cap.fx(t,regi,"fnrs",rlf)$(t.val ge 2010) = 0;

*** no new nuclear investments after 2020, until then all currently planned plants are built
if (cm_nucscen eq 5,
  vm_deltaCap.up(t,regi_nucscen,"tnrs",rlf)$(t.val gt 2020)= 1e-6;
  vm_cap.lo(t,regi_nucscen,"tnrs",rlf)$(t.val gt 2015)  = 0;
);

*'  -------------------------------------------------------------
*'  Force no new capacities of 1st generation biofuel technologies to be
*'  installed after 2030, allowing more cost-efficient and more sustainable new
*'  generation of biofuel technologies free entrance to the market
*'  -------------------------------------------------------------
if(cm_1stgen_phaseout=1,
   vm_deltaCap.up(t,regi,"bioeths",rlf)$(t.val gt 2030)   = 0;
   vm_deltaCap.up(t,regi,"biodiesel",rlf)$(t.val gt 2030) = 0;
);

*** -----------------------------------------------------------
*mh bounds that narrow the solution space to help the conopt solver:
*** -----------------------------------------------------------

*nr* cumulated capacity never falls below initial cumulated capacity:
vm_capCum.lo(ttot,regi,teLearn)$(ttot.val ge cm_startyear) = pm_data(regi,"ccap0",teLearn);
*** exception for tech_stat 4 technologies whose ccap0 refers to 2025 as these technologies don't exist in 2005
vm_capCum.lo(ttot,regi,teLearn)$(pm_data(regi,"tech_stat",teLearn) eq 4 AND ttot.val le 2020) = 0;

*nr: floor costs represent the lower bound of learning technologies investment costs
vm_costTeCapital.lo(t,regi,teLearn) = pm_data(regi,"floorcost",teLearn);

*cb 20120319 avoid negative adjustment costs in 2005 (they would allow the model to artificially save money)
v_adjFactor.fx("2005",regi,te)=0;



vm_emiMacSector.lo(t,regi,enty)    =  0;
vm_emiMacSector.lo(t,regi,"co2luc")= -5.0;  !! afforestation can lead to negative emissions
vm_emiMacSector.lo(t,regi,"n2ofertsom") =  -1; !! small negative emissions can result from human activity
vm_emiMac.fx(t,regi,"so2") = 0;
vm_emiMac.fx(t,regi,"bc") = 0;
vm_emiMac.fx(t,regi,"oc") = 0;

*** -------------------------------------------------------------------------
*** Exogenous capacities:
*** -------------------------------------------------------------------------
loop(t $ (t.val >= 2015 and t.val <= 2025),
  loop(regi,
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
  );
);


*** bounds on near-term electrolysis capacities
*' set lower and upper bounds for 2025 based on projects annoucements
*' from IEA Hydryogen project database:
*' https://www.iea.org/data-and-statistics/data-product/hydrogen-production-and-infrastructure-projects-database
*' distribute to regions via GDP share of 2025 (we do not use later time steps as they may have different GDPs depending on the scenario)
*' in future this should be differentiated by region based on regionalized input data of project announcements
*' 2 GW(el) at least globally in 2025, about operational capacity as of 2023
vm_cap.lo("2025",regi,"elh2","1")= 2 * pm_eta_conv("2025",regi,"elh2")*pm_gdp("2025",regi)
                                         / sum(regi2,pm_gdp("2025",regi2)) * 1e-3;
*' 20 GW(el) at maximum globally in 2025 (be more generous to not overconstrain regions which scale-up fastest)
vm_cap.up("2025",regi,"elh2","1")= 20 * pm_eta_conv("2025",regi,"elh2")*pm_gdp("2025",regi)
                                         / sum(regi2,pm_gdp("2025",regi2)) * 1e-3;

*** bounds on biomass technologies
*' set upper bounds on biomass gasification for h2 production, which is not deployed as of 2025
*' allow for small production of 0.1 EJ/yr at by 2030 for each technology globally, distributed to regions by GDP share in 2025
vm_cap.up("2030",regi,"bioh2","1")= 0.1 / 3.66 * 1e3 / 8760 * pm_gdp("2025",regi) / sum(regi2,pm_gdp("2025",regi2));
vm_cap.up("2030",regi,"bioh2c","1")= 0.1 / 3.66 * 1e3 / 8760 * pm_gdp("2025",regi) / sum(regi2,pm_gdp("2025",regi2));
*' allow zero vm_deltaCap for bio-H2 up to 2030 to be consistent with above bounds
vm_deltaCap.lo(t,regi,"bioh2","1")$(t.val le 2030) = 0;
vm_deltaCap.lo(t,regi,"bioh2c","1")$(t.val le 2030) = 0;

*** fix capacities for advanced bio carbon capture technologies to zero in 2020 (i.e. no BECCS in 2020)
vm_cap.fx("2020",regi,te,rlf)$(teBio(te) AND teCCS(te)) = 0;

*** fix emissions to historical emissions in 2010
*** RP: turned off in March 2018, as it produces substantial negative side-effects (requiring strong early retirement in 2010, which influences the future investments even in Reference scenarios)
*** vm_emiTe.up("2010",regi,"co2") = p_boundEmi("2010",regi) ;
>>>>>>> 2077ea43 (Update WACC branch with latest changes)

*** lower bound on stored CO2
vm_emiTe.lo(ttot,regi,"cco2") = 0;

*' no CCS at all in 2010
vm_cap.fx("2010",regi,teCCS,rlf) = 0;

*' no BECCS in 2020
vm_cap.fx("2020",regi,te,rlf) $ (teBio(te) and teCCS(te)) = 0;

*' switch to deactivate carbon sequestration
if(c_ccsinjecratescen = 0,
  vm_co2CCS.fx(t,regi_capturescen,"cco2","ico2","ccsinje","1") = 0;
);

*' bound on maximum annual carbon storage by region
*** if c_ccsinjecratescen=0 --> no CCS at all and vm_co2CCS is fixed to 0 before, therefore the upper bound is only set if there should be CCS!
if(c_ccsinjecratescen > 0,
*' DK 20100929: default value (pm_ccsinjecrate= 0.5%) is consistent with Interview Gerling (BGR)
*' (http://www.iz-klima.de/aktuelles/archiv/news-2010/mai/news-05052010-2/): 
*' 12 Gt storage potential in Germany, 50-75 Mt/a injection => 60 Mt/a => 60/12000=0.005
  vm_co2CCS.up(t,regi,"cco2","ico2","ccsinje","1") = pm_dataccs(regi,"quan","1") * pm_ccsinjecrate(regi);

*** Lower limit for 2020-2030 is capacities of all projects that are operational (2020-2030) from project data base
*** Upper limit for 2025 and 2030 additionally includes all projects under construction and 30% 
*** (default, or changed by c_fracRealfromAnnouncedCCScap2030) of announced/planned projects from project data base
*** See also corresponding code in input validation data preparation in mrremind/R/calcProjectPipeline.R.
*** In nash-mode regions cannot easily share ressources, therefore CCS potentials are redistributed in Europe in data preprocessing in mrremind:
*** Potential of EU27 regions is pooled and redistributed according to GDP (Only upper limit for 2030)
*** Norway and UK announced to store CO2 for EU27 countries. So 50% of Norway and UK potential in 2030 is attributed to EU27-Pool
  if(not cm_emiscen = 1, !! cm_emiscen 1 = BAU
    vm_co2CCS.lo(t,regi,"cco2","ico2","ccsinje","1") $ (t.val <= 2030) = s_MtCO2_2_GtC * p_boundCapCCS(t,regi,"operational") $ (t.val <= 2030);
    vm_co2CCS.up(t,regi,"cco2","ico2","ccsinje","1") $ (t.val <= 2030) = s_MtCO2_2_GtC * (
        p_boundCapCCS(t,regi,"operational") $ (t.val <= 2030)
      + p_boundCapCCS(t,regi,"construction") $ (t.val <= 2030)
      + p_boundCapCCS(t,regi,"planned") $ (t.val <= 2030) * c_fracRealfromAnnouncedCCScap2030);
  );
);

*' switch to deactivate carbon capture technologies
if(cm_emiscen = 1,
  vm_cap.fx(t,regi,teCCS,rlf) = 0;
);


if(cm_ccapturescen = 2, !! no carbon capture at all
  vm_cap.fx(t,regi_capturescen,teCCS,rlf) = 0;
  vm_cap.fx(t,regi_capturescen,"ccsinje",rlf) = 0;
elseif(cm_ccapturescen = 3), !! no bio carbon capture:
  vm_cap.fx(t,regi_capturescen,te,rlf) $ (teCCS(te) and teBio(te)) = 0;
elseif(cm_ccapturescen = 4), !! no carbon capture in the electricity sector
  loop(emi2te(enty,"seel",te,"cco2") $ ( sum(regi_capturescen, pm_emifac("2020",regi_capturescen,enty,"seel",te,"cco2")) > 0 ),
    loop(te2rlf(te,rlf),
      vm_cap.fx(t,regi_capturescen,te,rlf) = 0;
    );
  );
);


*' Fix capacities of technologies with carbon capture to zero if there are no CCS projects in the pipeline in that region
*** This is only reasonable, as long as we also don't expect any CCU projects in the early years.
loop(regi,
  loop(t $ (t.val <= 2030),
    if( ((p_boundCapCCS(t,regi,"operational") + p_boundCapCCS(t,regi,"construction") + p_boundCapCCS(t,regi,"planned")) = 0),
      vm_cap.fx(t,regi,teCCS,rlf) = 0;
    );
  );
);

loop(regi $ (p_boundCapCCSindicator(regi) = 0),
  vm_cap.fx("2025",regi,teCCS,rlf) = 0;
  vm_cap.fx("2030",regi,teCCS,rlf) = 0;
);

*** Limit REMINDs ability to vent captured CO2 to 1 MtCO2 per yr per region. This happens otherwise to a great extend in stringent climate 
*** policy scenarios if CCS and CCU capacities are limited in early years, to lower overall adjustment costs of capture technologies.
*** In reality, people don't have perfect foresight and without storage or usage capacities, no capture facilities will be built.
v_co2capturevalve.up(t,regi) = 1 * s_MtCO2_2_GtC;


*** ==================================================================
*' #### 5. Early retirement and phase-out of technologies
*** ==================================================================

*' Switch off coal-h2 hydrogen investments after 2020, and gas-h2 investments after 2030. Our current seh2 hydrogen represents
*' only additional (clean) hydrogen use cases to current ones. However, as we have too high H2 demand in 2025 and 2030 from the
*' input data, we need to allow grey hydrogen for these time periods to meet the hydrogen demand which cannot be fully met by
*' incoming low-carbon H2 techologies. This should be removed once FE H2 industry input data is adapted.
*' It is allowed before 2020 to not make the model infeasible for low demands of hydrogen in that year.
vm_deltaCap.fx(t,regi,"coalh2",rlf) $ (t.val >= 2020) = 0;
vm_deltaCap.fx(t,regi,"gash2",rlf) $ (t.val > 2030) = 0;
vm_cap.lo(t,regi,"coalh2",rlf) $ (t.val >= 2020) = 0;
vm_cap.lo(t,regi,"gash2",rlf) $ (t.val > 2030) = 0;


*** CB: allow for early retirement at the start of free model time
*** allow non zero early retirement for all technologies to avoid mathematical errors
vm_capEarlyReti.up(t,regi,te) = 1e-6;
*** generally allow full early retiremnt for all fossil technologies without CCS
vm_capEarlyReti.up(t,regi,teFosNoCCS(te)) = 1;
*** allow nuclear early retirement
vm_capEarlyReti.up(t,regi,"tnrs") = 1;
*** allow early retirement of biomass used in electricity
vm_capEarlyReti.up(t,regi,"bioigcc") = 1;
*** allow early retirement of biomass used for heat and power
vm_capEarlyReti.up(t,regi,"biohp") = 1;
vm_capEarlyReti.up(t,regi,"biochp") = 1;

*** allow early retirement for techs added to the c_tech_earlyreti_rate switch
$ifthen.tech_earlyreti not "%c_tech_earlyreti_rate%" == "off"
loop((ext_regi,te) $ p_techEarlyRetiRate(ext_regi,te),
  vm_capEarlyReti.up(t,regi,te) $ (regi_group(ext_regi,regi)) = 1;
);
$endif.tech_earlyreti

*** restrict early retirement to the modeling time frame (to reduce runtime, the early retirement equations are phased out after 2110)
vm_capEarlyReti.up(ttot,regi,te) $ (ttot.val < 2010 or ttot.val > 2110) = 0;

*** lower bound of 0.01% to help the model to be aware of the early retirement option
vm_capEarlyReti.lo(t,regi,te) $ (vm_capEarlyReti.up(t,regi,te) >= 1 and t.val > 2010 and t.val <= 2100) = 1e-4;

*** CB 20120301: no early retirement for diesel oil turbines, they are used despite their economic non-competitiveness for various reasons.
vm_capEarlyReti.fx(t,regi,"dot") = 0;


*** strong reliance on coal-to-liquids is not consistent with SSP1 storyline, therefore limit their use in the SSP1 and SSP2 policy scenarios
$ifthen %c_SSP_forcing_adjust% == "forcing_SSP1"
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftrec")  $ (t.val > 2050) = 1e-5;
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec") $ (t.val > 2010) = 1e-5;
  
*** fixing prodFE in 2005 to the value contained in pm_cesdata("2005",regi,in,"quantity"). This is done to ensure that the energy system will reproduce the 2005 calibration values.
*** Fixing will produce clearly attributable errors (good for debugging) when using inconsistent data, as the GAMS accuracy when comparing fixed results is very high (< 1e-8).
*** vm_prodFe.fx("2005",regi,se2fe(enty,enty2,te)) = sum(fe2ppfEn(enty2,in), pm_cesdata("2005",regi,in,"quantity") );
  vm_deltaCap.up(t,regi,"coalgas",rlf) $ (t.val > 2010) = 1e-5;
$endif

$ifthen %c_SSP_forcing_adjust% == "forcing_SSP2"
if(cm_emiscen > 1,
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec") $ (t.val > 2010) = 1e-5;
);
$endif


*** ==================================================================
*' #### 6. Energy demand sectors and final energy
*** ==================================================================

*** bounds on final energy use (relevant in case some switches are acitvated that make pm_shfe_up and pm_shfe_lo non-zero)
*' upper and lower bounds on FE carrier shares
v_shfe.up(t,regi,entyFe,sector) $ pm_shfe_up(t,regi,entyFe,sector) = pm_shfe_up(t,regi,entyFe,sector);
v_shfe.lo(t,regi,entyFe,sector) $ pm_shfe_lo(t,regi,entyFe,sector) = pm_shfe_lo(t,regi,entyFe,sector);
*' upper and lower bounds on gases+liquids share in FE
v_shGasLiq_fe.up(t,regi,sector) $ pm_shGasLiq_fe_up(t,regi,sector) = pm_shGasLiq_fe_up(t,regi,sector);
v_shGasLiq_fe.lo(t,regi,sector) $ pm_shGasLiq_fe_lo(t,regi,sector) = pm_shGasLiq_fe_lo(t,regi,sector);

*' Set H2 upper bound in buildings for years defined at cm_H2InBuildOnlyAfter
vm_demFeSector.up(t,regi,"seh2","feh2s","build",emiMkt) $ (t.val <= cm_H2InBuildOnlyAfter) = 1e-6;

*' upper bound on bioliquids as a share of transport liquids
v_shBioTrans.up(t,regi) $ (t.val > 2020) = c_shBioTrans;


*** ==================================================================
*' #### 7. Assumptions for emissions
*** (move to a module?) ==============================================

vm_emiMacSector.lo(t,regi,enty) = 0;
vm_emiMacSector.lo(t,regi,"co2luc") = -5.0; !! afforestation can lead to negative emissions
vm_emiMacSector.lo(t,regi,"n2ofertsom") = -1; !! small negative emissions can result from human activity
vm_emiMac.fx(t,regi,"so2") = 0;
vm_emiMac.fx(t,regi,"bc") = 0;
vm_emiMac.fx(t,regi,"oc") = 0;

*** fix F-gas emissions to inputdata (IMAGE)
vm_emiFgas.fx(ttot,all_regi,all_enty) = f_emiFgas(ttot,all_regi,"%c_SSP_forcing_adjust%","%cm_rcp_scen%","SPA0",all_enty);
display vm_emiFgas.L;


*** ==================================================================
*' #### Other bounds 
*** ==================================================================
*' @stop

*** completely switching off technologies that are not used in the current version of REMIND, although their parameters are declared
loop(all_te $ (
    sameas(all_te, "solhe") or
    sameas(all_te, "fnrs") or
    sameas(all_te, "pcc") or
    sameas(all_te, "pco") or
*** windoffshore-todo: to remove when removing wind from all_te
    sameas(all_te, "wind") or
    sameas(all_te, "storwind") or
    sameas(all_te, "gridwind")
  ),
  vm_cap.fx(t,regi,all_te,rlf) = 0;
  vm_deltaCap.fx(t,regi,all_te,rlf) = 0;

  loop(pe2se(entyPe,entySe,all_te),
    vm_demPe.fx(t,regi,entyPe,entySe,all_te) = 0;
    vm_prodSe.fx(t,regi,entyPe,entySe,all_te) = 0;
  );
);


*** H2 Curtailment (TODO: RLDC removal)
*** Fixing h2curt value to zero to avoid the model to generate SE out of nothing.
*** Models that have additional se production channels should release this variable (eg. RLDC power module).
loop(prodSeOth2te(enty,te),
  v_prodSeOth.fx(t,regi,"seh2","h2curt") = 0;
);


<<<<<<< HEAD
*** Make sure no grades > 9 are used. Only cosmetic to avoid entries in lst file
v_capDistr.fx(t,regi,te,rlf) $ (rlf.val > 9) = 0;
*** Make sure the model doesn't use technologies beyond grade 1 for pe2se, se2se and se2fe
loop(te $ (teSe2rlf(te,"1") or teFe2rlf(te,"1")),
  vm_deltaCap.fx(t,regi,te,rlf) $ (rlf.val > 1) = 0;
  vm_cap.fx(ttot,regi,te,rlf) $ (rlf.val > 1) = 0;
);


*** lower bound on share of green hydrogen starting from 2030 (switch c_shGreenH2 has default value zero)
v_shGreenH2.lo(t,regi) $ (t.val = 2025) = c_shGreenH2 * 2/3;
v_shGreenH2.lo(t,regi) $ (t.val > 2025) = c_shGreenH2;
=======
***---------------------------------------------------------------------------
***                 make sure the model doesn't use technologies beyond grade 1
***---------------------------------------------------------------------------
*** for pe2se, se2se and se2fe the other grades should not be used
>>>>>>> 2077ea43 (Update WACC branch with latest changes)


*** Limit slack variable and uncontrolled variable values for adj costs that limit changes to reference in cm_startyear
v_changeProdStartyearSlack.up(t,regi,te) $ ( (t.val > 2005) and (t.val = cm_startyear) ) = + c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;
v_changeProdStartyearSlack.lo(t,regi,te) $ ( (t.val > 2005) and (t.val = cm_startyear) ) = - c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;


*** CB 20120319: avoid negative adjustment costs in 2005 (they would allow the model to artificially save money)
v_adjFactor.fx("2005",regi,te) = 0;

<<<<<<< HEAD
=======
vm_emiFgas.fx(ttot,all_regi,all_enty) = f_emiFgas(ttot,all_regi,"%c_SSP_forcing_adjust%","%cm_rcp_scen%","SPA0",all_enty);
display vm_emiFgas.L;


***----------------------------------------------------------------------------
*** lower bound on share of green hydrogen starting from 2030 (c_greenH2)
***----------------------------------------------------------------------------

v_shGreenH2.lo(t,regi)$(t.val eq 2025) = c_shGreenH2 * 2/3;
v_shGreenH2.lo(t,regi)$(t.val gt 2025) = c_shGreenH2;

***----------------------------------------------------------------------------
*** upper bound on bioliquids as a share of transport liquids
***----------------------------------------------------------------------------

v_shBioTrans.up(t,regi)$(t.val > 2020) = c_shBioTrans;

***----------------------------------------------------------------------------
*** bounds on final energy use (relevant in case some switches are acitvated that make pm_shfe_up and pm_shfe_lo non-zero)
***----------------------------------------------------------------------------

*** upper and lower bounds on FE carrier shares
v_shfe.up(t,regi,entyFe,sector)$pm_shfe_up(t,regi,entyFe,sector) = pm_shfe_up(t,regi,entyFe,sector);
v_shfe.lo(t,regi,entyFe,sector)$pm_shfe_lo(t,regi,entyFe,sector) = pm_shfe_lo(t,regi,entyFe,sector);

*** upper and lower bounds on gases+liquids share in FE
v_shGasLiq_fe.up(t,regi,sector)$pm_shGasLiq_fe_up(t,regi,sector) = pm_shGasLiq_fe_up(t,regi,sector);
v_shGasLiq_fe.lo(t,regi,sector)$pm_shGasLiq_fe_lo(t,regi,sector) = pm_shGasLiq_fe_lo(t,regi,sector);

*** Set H2 upper bound in buildings for years defined at cm_H2InBuildOnlyAfter
vm_demFeSector.up(t,regi,"seh2","feh2s","build",emiMkt)$(t.val le cm_H2InBuildOnlyAfter) = 1e-6;

***----------------------------------------------------------------------------
*'  Limit slack variable and uncontrolled variable values for adj costs that limit changes to reference in cm_startyear
***----------------------------------------------------------------------------

v_changeProdStartyearSlack.up(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = + c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;
v_changeProdStartyearSlack.lo(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = - c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;

*RP: add lower bound on 2020 coal chp and upper bound on gas chp based on IEA data to have a more realistic starting point
vm_prodSe.lo("2020",regi,"pecoal","seel","coalchp") = 0.8 * pm_IO_output("2020",regi,"pecoal","seel","coalchp") ;
vm_prodSe.up("2020",regi,"pegas","seel","gaschp") = 1e-4 + 1.3 * pm_IO_output("2020",regi,"pegas","seel","gaschp") ;
>>>>>>> 2077ea43 (Update WACC branch with latest changes)

*** EOF ./core/bounds.gms
