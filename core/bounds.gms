*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/bounds.gms
*** -----------------------------------------------------------
*** setting bounds
*** -----------------------------------------------------------

*RP 20160126 set vm_costTeCapital to pm_inco0_t for all technologies that are non-learning
vm_costTeCapital.fx(ttot,regi,teNoLearn)  = pm_inco0_t("2005",regi,teNoLearn);  !! use 2005 value for the past
vm_costTeCapital.fx(t,regi,teNoLearn)     = pm_inco0_t(t,regi,teNoLearn);

*** ----------------------------------------------------------------------------------------------------------------------------------------
*** CB 20120402 Set lower bounds on variables to prevent the problem that the conopt solver often doesn't see a benefit from changing variable value away from 0
*** These lower bounds are set so low that they do not restrict the results
*** ----------------------------------------------------------------------------------------------------------------------------------------

*' @title{extrapage: "00_model_assumptions"} Model Assumptions
*' @code{extrapage: "00_model_assumptions"}

*' ### Model Bounds and Assumptions: 

*' #### Model Bounds in Core
*' Lower limit on all P2SE technologies capacities to 100 kW of all technologies and all time steps
loop(pe2se(enty,enty2,te) $ (
    (not sameas(te,"biotr")) AND
    (not sameas(te,"biodiesel")) AND
    (not sameas(te,"bioeths")) AND
    (not sameas(te,"gasftcrec")) AND
    (not sameas(te,"gasftrec")) AND
    (not sameas(te,"tnrs"))
  ),
  vm_cap.lo(t,regi,te,"1")$(t.val gt 2026 AND t.val le 2070) = 1e-7;
  if( (NOT teCCS(te)), 
    vm_deltaCap.lo(t,regi,te,"1")$(t.val gt 2026 AND t.val le 2070) = 1e-8;
  );
);


*' Make sure that the model also sees the se2se technologies (seel <--> seh2)
loop(se2se(enty,enty2,te),
  vm_cap.lo(t,regi,te,"1")$(t.val gt 2025) = 1e-7;
);

*' Lower bound of 10 kW on each of the different grades for renewables with multiple resource grades
loop(regi,
  loop(teRe2rlfDetail(te,rlf),
    if( (pm_dataren(regi,"maxprod",rlf,te) gt 0),
        v_capDistr.lo(t,regi,te,rlf)$(t.val gt 2011) = 1e-8;
*cb* make sure that grade distribution in early time steps with capacity fixing is close to optimal one assumed for vm_capFac calibration, divide by p_aux_capacityFactorHistOverREMIND to correct for deviation of REMIND capacity factors from historic capacity factors
      v_capDistr.lo("2015",regi,te,rlf) = 0.90 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
      v_capDistr.lo("2020",regi,te,rlf) = 0.90 / max(1, p_aux_capacityFactorHistOverREMIND(regi,te)) * p_aux_capThisGrade(regi,te,rlf);
    );
  );
);

*' Make sure no grades > 9 are used. Only cosmetic to avoid entries in lst file
v_capDistr.fx(t,regi,te,rlf)$(rlf.val gt 9) = 0;

*' No battery storage in 2010:
vm_cap.up("2010",regi,teStor,"1") = 0;

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
  vm_cap.fx(t,regi,all_te,rlf)      = 0;
  vm_deltaCap.fx(t,regi,all_te,rlf) = 0;
);

vm_demPe.fx(t,regi,"pecoal","seel","pcc") = 0;
vm_demPe.fx(t,regi,"pecoal","seel","pco") = 0;
vm_prodSe.fx(t,regi,"pecoal","seel","pcc") = 0;
vm_prodSe.fx(t,regi,"pecoal","seel","pco") = 0;
*** windoffshore-todo: to remove when removing wind from all_te
vm_demPe.fx(t,regi,"pewin","seel","wind") = 0;
vm_prodSe.fx(t,regi,"pewin","seel","wind") = 0;

*' Switch off coal-h2 hydrogen investments after 2020, and gas-h2 investments after 2030. Our current seh2 hydrogen represents only additional (clean) hydrogen use cases to current ones.
*' However, as we have too high H2 demand in 2025 and 2030 from the input data, we need to allow grey hydrogen for these time periods to meet the hydrogen demand
*' which cannot be fully met by incoming low-carbon H2 techologies. This should be removed once FE H2 industry input data is adapted.
*' It is allowed before 2020 to not make the model infeasible for low demands of hydrogen in that year.
vm_deltaCap.fx(t,regi,"coalh2",rlf)$(t.val ge 2020) = 0;
vm_deltaCap.fx(t,regi,"gash2",rlf)$(t.val gt 2030)  = 0;
vm_cap.lo(t,regi,"coalh2",rlf)$(t.val ge 2020) = 0;
vm_cap.lo(t,regi,"gash2",rlf)$(t.val gt 2030)  = 0;


*' upper bound of 0.5 EJ/yr on grey hydrogen to prevent building too much grey H2 before 2020, distributed to regions via GDP share
vm_cap.up("2020",regi,"gash2","1") =  0.5 / 3.66 * 1e3 / 8760 * pm_gdp("2020",regi) / sum(regi2,pm_gdp("2020",regi2));


*' @stop

*** -----------------------------------------------------------------------------------------------------------------
*** Traditional biomass use is phased out on an exogeneous time path
*** -----------------------------------------------------------------------------------------------------------------
*** Note: make sure that this matches with the settings for residues in modules/05_initialCap/on/preloop.gms

*BS/DK* Developed regions phase out quickly (no new capacities)
vm_deltaCap.fx(t,regi,"biotr",rlf)$(t.val gt 2005) = 0;
*BS/DK* Developing regions (defined by GDP PPP threshold) phase out more slowly ( + varied by SSP)
loop(regi,
  if ( (pm_gdp("2005",regi)/pm_pop("2005",regi) / pm_shPPPMER(regi)) lt 4,
    vm_deltaCap.fx("2010",regi,"biotr","1") = 1.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2015",regi,"biotr","1") = 0.9  * vm_deltaCap.lo("2005",regi,"biotr","1");
    vm_deltaCap.fx("2020",regi,"biotr","1") = 0.7  * vm_deltaCap.lo("2005",regi,"biotr","1");
$ifthen NOT %cm_tradbio_phaseout% == "fast"   !! cm_tradbio_phaseout
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

*** quickest phaseout in SDP scenarios (no new capacities allowed), quick phaseout in SSP1 und SSP5
$if %cm_GDPpopScen% == "SDP" vm_deltaCap.up(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPpopScen% == "SDP_EI" vm_deltaCap.up(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPpopScen% == "SDP_MC" vm_deltaCap.up(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPpopScen% == "SDP_RC" vm_deltaCap.up(t,regi,"biotr","1")$(t.val gt 2020) = 0;
$if %cm_GDPpopScen% == "SSP1" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");
$if %cm_GDPpopScen% == "SSP5" vm_deltaCap.fx(t,regi,"biotr","1")$(t.val gt 2020) = 0.5 * vm_deltaCap.lo(t,regi,"biotr","1");

$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2025",regi,"biotr","1") = 0.6  * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2030",regi,"biotr","1") = 0.55 * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2035",regi,"biotr","1") = 0.5  * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2040",regi,"biotr","1") = 0.45 * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2045",regi,"biotr","1") = 0.4  * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2050",regi,"biotr","1") = 0.35 * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2055",regi,"biotr","1") = 0.3  * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2060",regi,"biotr","1") = 0.25 * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2070",regi,"biotr","1") = 0.15 * vm_deltaCap.lo("2005",regi,"biotr","1");
$if %cm_GDPscen% == "gdp_SSP3" vm_deltaCap.fx("2080",regi,"biotr","1") = 0.05 * vm_deltaCap.lo("2005",regi,"biotr","1");


*** ------------------------------------------------------------------------------------------
*LP* implement switch for scenarios with or without carbon sequestration:
*** ------------------------------------------------------------------------------------------

if ( c_ccsinjecratescen eq 0, !!no carbon sequestration at all
    vm_co2CCS.fx(t,regi_capturescen,"cco2","ico2","ccsinje","1") =0;
);

*' @code{extrapage: "00_model_assumptions"}

***------------------------------------------------------------------------------------------
*' #### implement switch for scenarios with different carbon capture assumptions:
*** ------------------------------------------------------------------------------------------
*'
*' carbon capture bounds
*'
if (cm_ccapturescen eq 2,  !! no carbon capture at all
  vm_cap.fx(t,regi_capturescen,"ngccc",rlf)        = 0;
  vm_cap.fx(t,regi_capturescen,"ccsinje",rlf)      = 0;
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
      vm_cap.fx(t,regi_capturescen,te,rlf)        = 0;
    );
  );
);

*' switching technologies off that produce liquids from lignocellulosic biomass
*'
if (c_bioliqscen eq 0, !! no bioliquids technologies
  vm_deltaCap.up(t,regi,"bioftrec",rlf)$(t.val gt 2005)    = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioftcrec",rlf)$(t.val gt 2005)   = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioethl",rlf)$(t.val gt 2005)     = 1.0e-6;
  vm_deltaCap.up(t,regi,"biopyrliq",rlf)$(t.val gt 2025) = 1.0e-6;
***  vm_cap.fx(t,regi,"bioftcrec",rlf)    = 0;
***  vm_cap.fx(t,regi,"bioftrec",rlf)     = 0;
***  vm_cap.fx(t,regi,"bioethl",rlf)      = 0;
);

*' switching technologies off that produce hydrogen from lignocellulosic biomass
*'
if (c_bioh2scen eq 0, !! no bioh2 technologies
  vm_deltaCap.up(t,regi,"bioh2",rlf)$(t.val gt 2005)       = 1.0e-6;
  vm_deltaCap.up(t,regi,"bioh2c",rlf)$(t.val gt 2005)      = 1.0e-6;
***  vm_cap.fx(t,regi,"bioh2c",rlf)       = 0;
***  vm_cap.fx(t,regi,"bioh2",rlf)       = 0;
);

*' set capacity for all biochar technologies to 0 until 2015 and biopyrLiq to 0 until 2025 as it does not exist yet commercially
 vm_cap.fx(t,regi,te,rlf)$(t.val le 2015 AND (sameAs(te,"biopyronly") OR  sameas(te,"biopyrhe") OR 
                                                sameas(te,"biopyrchp") OR sameas(te,"biopyrel"))) = 0;
 vm_cap.fx(t,regi,te,rlf)$(t.val le 2025 AND sameas(te,"biopyrliq")) = 0;

*' switch pyrolysis technologies off/on
if (cm_biopyrEstablished eq 0,
  vm_deltaCap.up(t,regi,te,rlf)$(t.val ge 2020 AND (sameAs(te, "biopyronly") OR sameAs(te,"biopyrhe") 
                                      OR sameAs(te,"biopyrel") OR sameAs(te,"biopyrchp"))) = 1.0e-6; 
  else
    vm_cap.up("2020",regi,te,rlf)$(sameAs(te,"biopyronly") OR sameAs(te,"biopyrhe") OR sameAs(te,"biopyrel") OR sameAs(te,"biopyrchp"))  
                                 = p_boundCapBiochar("2020",regi) * s_tBC_2_TWa / 4; 
    vm_cap.lo("2025",regi,te,rlf)$(sameAs(te, "biopyronly") OR sameAs(te,"biopyrhe") OR sameAs(te,"biopyrel") OR sameAs(te,"biopyrchp")) 
                                 = p_boundCapBiochar("2020",regi) * s_tBC_2_TWa / 4; 
    vm_cap.up("2025",regi,te,rlf)$(sameAs(te, "biopyronly") OR sameAs(te,"biopyrhe") OR  sameAs(te,"biopyrel") OR sameAs(te,"biopyrchp"))
                                  = (1.55/0.9)  * p_boundCapBiochar("2025",regi) * s_tBC_2_TWa / 4;                                
);

if (cm_biopyrliq eq 0,
   vm_deltaCap.up(t,regi,"biopyrliq",rlf)$(t.val gt 2025) = 1.0e-6; !! limit to negligible increase as of 2025 when turned off
  else 
   vm_deltaCap.lo(t,regi,"biopyrliq",rlf)$(t.val ge 2030) = 1.0e-6; !! initiate a negligible increase as of 2030 to help model find the technology
);

*' @stop

***--------------------------------------------------------------------
*RP no CCS should be used in a BAU run, and no CCS at all in 2010
***--------------------------------------------------------------------
vm_cap.fx("2010",regi,teCCS,rlf) = 0;

if(cm_emiscen = 1,
  vm_cap.fx(t,regi,teCCS,rlf) = 0;
);

*** ------------------------------------------------------------------------
*** Fix nuclear to historic values
*** ------------------------------------------------------------------------
if (cm_startyear le 2015,
  loop(regi,
    p_CapFixFromRWfix("2015",regi,"tnrs") = max( pm_aux_capLowerLimit("tnrs",regi,"2015") , pm_NuclearConstraint("2015",regi,"tnrs") );
    p_deltaCapFromRWfix("2015",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015")  )
                                      / 7.5;  !! this parameter is currently only for display and not further used to fix anything
    p_deltaCapFromRWfix("2010",regi,"tnrs") = ( p_CapFixFromRWfix("2015",regi,"tnrs") - pm_aux_capLowerLimit("tnrs",regi,"2015")  )
                                      / 7.5; !! this parameter is currently only for display and not further used to fix anything
    vm_cap.fx("2015",regi,"tnrs","1") = p_CapFixFromRWfix("2015",regi,"tnrs");
  );
);

if (cm_startyear le 2020,   !! require the realization of at least 70% of the plants that are currently under construction and thus might be finished until 2020 - should be updated with real-world 2020 numbers
   vm_deltaCap.lo("2020",regi,"tnrs","1") = 0.70 * pm_NuclearConstraint("2020",regi,"tnrs") / 5;
   vm_deltaCap.up("2020",regi,"tnrs","1") = pm_NuclearConstraint("2020",regi,"tnrs") / 5;
);
if (cm_startyear le 2025,   !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 30% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2025",regi,"tnrs","1") = pm_NuclearConstraint("2025",regi,"tnrs") / 5;
);
if (cm_startyear le 2030,   !! upper bound calculated in mrremind/R/calcCapacityNuclear.R: 50% of planned and 70% of proposed plants, plus extra for lifetime extension and newcomers
   vm_deltaCap.up("2030",regi,"tnrs","1") = pm_NuclearConstraint("2030",regi,"tnrs") / 5;
);

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
*** Exogenous values:
*** -------------------------------------------------------------------------

*** fix capacities for wind, spv and csp to real world historical values:
vm_cap.lo("2015",regi,teVRE,"1") = 0.95 * pm_histCap("2015",regi,teVRE)$(pm_histCap("2015",regi,teVRE) gt 1e-10);
vm_cap.up("2015",regi,teVRE,"1") = 1.05 * pm_histCap("2015",regi,teVRE)$(pm_histCap("2015",regi,teVRE) gt 1e-10);
vm_cap.lo("2020",regi,teVRE,"1") = 0.95 * pm_histCap("2020",regi,teVRE)$(pm_histCap("2020",regi,teVRE) gt 1e-10);
vm_cap.up("2020",regi,teVRE,"1") = 1.05 * pm_histCap("2020",regi,teVRE)$(pm_histCap("2020",regi,teVRE) gt 1e-10);
vm_cap.up("2025",regi,teVRE,"1")$(pm_histCap("2025",regi,teVRE) gt 1e-6) = 1.05 * pm_histCap("2025",regi,teVRE)$(pm_histCap("2025",regi,teVRE) gt 1e-10); !! only set a bound if values >1MW are in pm_histCap

*** lower bound on capacities for ngcc and ngt and gaschp for regions defined at the pm_histCap file
loop(te$(sameas(te,"ngcc") OR sameas(te,"ngt") OR sameas(te,"gaschp")),
  vm_cap.lo("2015",regi,te,"1")$pm_histCap("2015",regi,te) = 0.95 * pm_histCap("2015",regi,te);
  vm_cap.lo("2020",regi,te,"1")$pm_histCap("2020",regi,te) = 0.95 * pm_histCap("2020",regi,te);
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

*** lower bound on stored CO2
vm_emiTe.lo(ttot,regi,"cco2") = 0;

*** -------------------------------------------------------
*** Advanced technologies shouldn't be built prior to 2015/2020:
*** -------------------------------------------------------
loop(regi,
  loop(teNoLearn(te),
    if( ( pm_data(regi,"tech_stat",te) eq 2 ) ,
      vm_deltaCap.fx("2010",regi,te,rlf) = 0;
      vm_cap.lo("2010",regi,te,rlf)=0;
      vm_cap.lo("2015",regi,te,rlf)=0;
    elseif ( pm_data(regi,"tech_stat",te) eq 3 ),
      vm_deltaCap.fx("2010",regi,te,rlf) = 0;
      vm_deltaCap.fx("2015",regi,te,rlf) = 0;
      vm_cap.lo("2010",regi,te,rlf)=0;
      vm_cap.lo("2015",regi,te,rlf)=0;
      vm_cap.lo("2020",regi,te,rlf)=0;
    );
  );
);

*** no technologies with tech_stat 4 before 2025
vm_cap.fx(t,regi,te,rlf)$(t.val le 2020 AND pm_data(regi,"tech_stat",te) eq 4)=0;
*** initialize cumulative capacity of tech_stat 4 technologies at 0 
*** (not at ccap0 from generisdata_tech.prn which gives the cucmulative capacity
***  at the initial investment cost of the first year in which the technology can be built)
vm_capCum.fx(t0,regi,teLearn)$(pm_data(regi,"tech_stat",teLearn) eq 4) = 0;
*** tech_stat 4 technologies don't learn before 2025, so capital cost should be fixed
vm_costTeCapital.fx(t,regi,teLearn)$(t.val le 2020 AND pm_data(regi,"tech_stat",teLearn) eq 4)=fm_dataglob("inco0",teLearn);

*** no technologies with tech_stat 5 before 2030
vm_deltaCap.fx(t,regi,te,rlf)$(t.val le 2025 AND pm_data(regi,"tech_stat",te) eq 5)=0;


*CB 2012024 -----------------------------------------------------
*CB allow for early retirement at the start of free model time
*CB ------------------------------------------------------------
*** allow non zero early retirement for all technologies to avoid mathematical errors
vm_capEarlyReti.up(t,regi,te) = 1e-6;

***generally allow full early retiremnt for all fossil technologies without CCS
vm_capEarlyReti.up(t,regi,te)$(teFosNoCCS(te)) = 1;
*** allow nuclear early retirement
vm_capEarlyReti.up(t,regi,"tnrs") = 1;
*** allow early retirement of biomass used in electricity
vm_capEarlyReti.up(t,regi,"bioigcc") = 1;
*** allow early retirement of biomass used for heat and power
vm_capEarlyReti.up(t,regi,"biohp") = 1;
vm_capEarlyReti.up(t,regi,"biochp") = 1;

*** allow early retirement for techs added to the c_tech_earlyreti_rate switch
$ifthen.tech_earlyreti not "%c_tech_earlyreti_rate%" == "off"
loop((ext_regi,te)$p_techEarlyRetiRate(ext_regi,te),
  vm_capEarlyReti.up(t,regi,te)$(regi_group(ext_regi,regi))= 1;
);
$endif.tech_earlyreti

*** restrict early retirement to the modeling time frame (to reduce runtime, the early retirement equations are phased out after 2110)
vm_capEarlyReti.up(ttot,regi,te)$(ttot.val lt 2009 or ttot.val gt 2111) = 0;

*** lower bound of 0.01% to help the model to be aware of the early retirement option
vm_capEarlyReti.lo(t,regi,te)$((vm_capEarlyReti.up(t,regi,te) ge 1) and (t.val gt 2010) and (t.val le 2100)) = 1e-4;

*cb 20120301 no early retirement for dot, they are used despite their economic non-competitiveness for various reasons.
vm_capEarlyReti.fx(t,regi,"dot")=0;
*rp 20210118 no investment into oil turbines in Europe
vm_deltaCap.up(t,regi,"dot","1")$( (t.val gt 2005) AND regi_group("EUR_regi",regi) )  = 1e-6;

*' @code{extrapage: "00_model_assumptions"}
*** -----------------------------------------------------------------------------
*' #### Bound on maximum annual carbon storage by region
*** -----------------------------------------------------------------------------
*' DK 20100929: default value (pm_ccsinjecrate= 0.5%) is consistent with Interview Gerling (BGR)
*' (http://www.iz-klima.de/aktuelles/archiv/news-2010/mai/news-05052010-2/): 
*' 12 Gt storage potential in Germany, 50-75 Mt/a injection => 60 Mt/a => 60/12000=0.005
*** if c_ccsinjecratescen=0 --> no CCS at all and vm_co2CCS is fixed to 0 before, therefore the upper bound is only set if there should be CCS!
*** -----------------------------------------------------------------------------

if ( c_ccsinjecratescen gt 0,
    loop(regi,
       vm_co2CCS.up(t,regi,"cco2","ico2","ccsinje","1") = pm_dataccs(regi,"quan","1") * pm_ccsinjecrate(regi);
    );
);
*' @stop

*** strong reliance on coal-to-liquids is not consistent with SSP1 storyline, therefore limit their use in the SSP 1 and SSP2 policy scenarios
$ifthen %c_SSP_forcing_adjust% == "forcing_SSP1"
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftrec")$(t.val gt 2050) = 0.00001;
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec")$(t.val gt 2010) = 0.00001;
$endif
$ifthen %c_SSP_forcing_adjust% == "forcing_SSP2"
if(cm_emiscen gt 1,
  vm_prodSe.up(t,regi,"pecoal","seliqfos","coalftcrec")$(t.val gt 2010) = 0.00001;
);
$endif

*** -------------------------------------------------------------------------------------------------------------
*** Lower limit for 2020-2030 is capacities of all projects that are operational (2020-2030) from project data base
*** Upper limit for 2025 and 2030 additionally includes all projects under construction and 30% 
*** (default, or changed by c_fracRealfromAnnouncedCCScap2030) of announced/planned projects from project data base
*** See also corresponding code in input validation data preparation in mrremind/R/calcProjectPipeline.R.
*** In nash-mode regions cannot easily share ressources, therefore CCS potentials are redistributed in Europe in data preprocessing in mrremind:
*** Potential of EU27 regions is pooled and redistributed according to GDP (Only upper limit for 2030)
*** Norway and UK announced to store CO2 for EU27 countries. So 50% of Norway and UK potential in 2030 is attributed to EU27-Pool
*** if c_ccsinjecratescen=0 --> no CCS at all and vm_co2CCS is fixed to 0 before, therefore the upper bound is only set if there should be CCS!
*** -------------------------------------------------------------------------------------------------------------

if ( (c_ccsinjecratescen gt 0) AND (NOT cm_emiscen eq 1),
  vm_co2CCS.lo(t,regi,"cco2","ico2","ccsinje","1")$(t.val le 2030) = p_boundCapCCS(t,regi,"operational")$(t.val le 2030) * s_MtCO2_2_GtC;
  vm_co2CCS.up(t,regi,"cco2","ico2","ccsinje","1")$(t.val le 2030) = (p_boundCapCCS(t,regi,"operational")$(t.val le 2030) + p_boundCapCCS(t,regi,"construction")$(t.val le 2030) + p_boundCapCCS(t,regi,"planned")$(t.val le 2030) * c_fracRealfromAnnouncedCCScap2030) * s_MtCO2_2_GtC;
);

*** Fix capacities of technologies with carbon capture to zero if there are no CCS projects in the pipeline in that region
*** This is only reasonable, as long as we also don't expect any CCU projects in the early years.
loop(regi,
  loop(t$(t.val le 2030),
    if( ((p_boundCapCCS(t,regi,"operational") + p_boundCapCCS(t,regi,"construction") + p_boundCapCCS(t,regi,"planned")) eq 0),
      vm_cap.fx(t,regi,teCCS,rlf) = 0;
    );
  );
);

loop(regi,
  if( (p_boundCapCCSindicator(regi) eq 0),
    vm_cap.fx("2025",regi,teCCS,rlf) = 0;
    vm_cap.fx("2030",regi,teCCS,rlf) = 0;
  );
);

*** -------------------------------------------------------------------------------------------------------------
*** Limit REMINDs ability to vent captured CO2 to 1 MtCO2 per yr per region. This happens otherwise to a great extend in stringent climate 
*** policy scenarios if CCS and CCU capacities are limited in early years, to lower overall adjustment costs of capture technologies.
*** In reality, people don't have perfect foresight and without storage or usage capacities, no capture facilities will be built.
v_co2capturevalve.up(t,regi) = 1 * s_MtCO2_2_GtC;


*** fixing prodFE in 2005 to the value contained in pm_cesdata("2005",regi,in,"quantity"). This is done to ensure that the energy system will reproduce the 2005 calibration values.
*** Fixing will produce clearly attributable errors (good for debugging) when using inconsistent data, as the GAMS accuracy when comparing fixed results is very high (< 1e-8).
*** vm_prodFe.fx("2005",regi,se2fe(enty,enty2,te)) = sum(fe2ppfEn(enty2,in), pm_cesdata("2005",regi,in,"quantity") );

$if  %c_SSP_forcing_adjust% == "forcing_SSP1"    vm_deltaCap.up(t,regi,"coalgas",rlf)$(t.val gt 2010) = 0.00001;

*** -------------------------------------------------------------
*** H2 Curtailment
*** -------------------------------------------------------------
*** RLDC removal
*** Fixing h2curt value to zero to avoid the model to generate SE out of nothing.
*** Models that have additional se production channels should release this variable (eg. RLDC power module).
loop(prodSeOth2te(enty,te),
  v_prodSeOth.fx(t,regi,"seh2","h2curt") = 0;
);


***---------------------------------------------------------------------------
***                 Lower bounds on hydro
***---------------------------------------------------------------------------
*** as most of the costs for hydro are for the initial building, it is unlikely that existing hydro plants are not renovated, even if a completely new plant would not be economic
*** accordingly, set lower bound on hydro generation close to 2005 values

vm_prodSe.lo(t,regi,"pehyd","seel","hydro")$(t.val > 2005) = 0.99 * o_INI_DirProdSeTe(regi,"seel","hydro");


***---------------------------------------------------------------------------
***                 make sure the model doesn't use technologies beyond grade 1
***---------------------------------------------------------------------------
*** for pe2se, se2se and se2fe the other grades should not be used


vm_deltaCap.fx(t,regi,te,rlf)$( (NOT rlf.val eq 1)  AND ( teSe2rlf(te,"1") OR teFe2rlf(te,"1") ) ) = 0;
vm_cap.fx(ttot,regi,te,rlf)$((NOT rlf.val eq 1) AND ( teSe2rlf(te,"1") OR teFe2rlf(te,"1") ) )     = 0;


***----------------------------------------------------------------------------
*** fix F-gas emissions to inputdata (IMAGE)
***----------------------------------------------------------------------------

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
***  Controlling if active, dampening factor to align edge-t non-energy transportation costs with historical GDP data
***----------------------------------------------------------------------------
$IFTHEN.transpGDPscale not "%cm_transpGDPscale%" == "on" 
  vm_transpGDPscale.fx(t,regi) = 1;
$ENDIF.transpGDPscale

***----------------------------------------------------------------------------
*'  Limit slack variable and uncontrolled variable values for adj costs that limit changes to reference in cm_startyear
***----------------------------------------------------------------------------

v_changeProdStartyearSlack.up(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = + c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;
v_changeProdStartyearSlack.lo(t,regi,te)$( (t.val gt 2005) AND (t.val eq cm_startyear ) ) = - c_SlackMultiplier * p_adj_seed_reg(t,regi) * p_adj_seed_te(t,regi,te) ;

*** EOF ./core/bounds.gms
