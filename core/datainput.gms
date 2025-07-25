*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./core/datainput.gms

*** technical. initialize parameters so that they are read from gdx
vm_co2eq.l(ttot,regi) = 0;
vm_emiAll.l(ttot,regi,enty) = 0;
vm_emiCO2Sector.l(ttot,all_regi,emi_sectors) = 0;
pm_taxCO2eqSum(ttot,regi) = 0;

*** initialize parameter (avoid compilation errors)
*** do this at the start of datainput to prevent accidental overwriting
pm_SolNonInfes(regi) = 1; !! assume the starting point came from a feasible solution
pm_capCum0(ttot,regi,teLearn)$( (ttot.val ge 2005) and  (pm_SolNonInfes(regi) eq 1)) = 0;

pm_globalMeanTemperature(tall)              = 0;
pm_globalMeanTemperatureZeroed1900(tall)    = 0;
pm_temperatureImpulseResponseCO2(tall,tall) = 0;

*** Initialise to avoid compilation errors in presolve if variable not in input.gdx
vm_demFeForEs.L(t,regi,entyFe,esty,teEs) = 0;
vm_demFeForEs.L(t,regi,fe2es(entyFe,esty,teEs)) = 0.1;

*** -------- initial declaration of parameters for iterative target adjustment
pm_taxCO2eq_anchor_iterationdiff(t) = 0;

*------------------------------------------------------------------------------------
***                        calculations based on sets
*------------------------------------------------------------------------------------
pm_ttot_val(ttot) = ttot.val;
p_tall_val(tall) = tall.val;

pm_ts(ttot) = (pm_ttot_val(ttot+1)-(pm_ttot_val(ttot-1)))/2;
pm_ts("1900") = 2.5;
pm_ts(ttot)$(ord(ttot) eq card(ttot)) = 27;
pm_dt("1900") = 5;
pm_dt(ttot)$(ttot.val > 1900) = ttot.val - pm_ttot_val(ttot-1);
display pm_ts, pm_dt;

loop(ttot,
    loop(tall$((ttot.val le tall.val) AND (pm_ttot_val(ttot+1) ge tall.val)),
         pm_interpolWeight_ttot_tall(tall) = ( p_tall_val(tall) - pm_ttot_val(ttot) ) / ( pm_ttot_val(ttot+1) - pm_ttot_val(ttot) );
    );
);

pm_tall_2_ttot(tall, ttot)$((ttot.val lt tall.val) AND (pm_ttot_val(ttot+1) gt tall.val)) = Yes;
pm_ttot_2_tall(ttot,tall)$((ttot.val = tall.val) ) = Yes;

*** define pm_prtp according to cm_prtpScen:
if(cm_prtpScen eq 1, pm_prtp(regi) = 0.015);
if(cm_prtpScen eq 3, pm_prtp(regi) = 0.03);
pm_ies(regi) = 2./3.;

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                macro-economy
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
*** load population data
table f_pop(tall,all_regi,all_GDPpopScen)        "Population data"
$ondelim
$include "./core/input/f_pop.cs3r"
$offdelim
;
pm_pop(tall,all_regi) = f_pop(tall,all_regi,"%cm_GDPpopScen%") / 1000;  !! rescale unit from [million people] to [billion] people

*** load labour data
table f_lab(tall,all_regi,all_GDPpopScen)        "Labour data"
$ondelim
$include "./core/input/f_lab.cs3r"
$offdelim
;
pm_lab(tall,all_regi) = f_lab(tall,all_regi,"%cm_GDPpopScen%") / 1000; !! rescale unit from [million people] to [billion] people

display pm_pop, pm_lab;

*** load PPP-MER conversion factor data
parameter pm_shPPPMER(all_regi)        "PPP ratio for calculating GDP|PPP from GDP|MER"
/
$ondelim
$include "./core/input/pm_shPPPMER.cs4r"
$offdelim
/;

*** load GDP data
table f_gdp(tall,all_regi,all_GDPpopScen)        "GDP data"
$ondelim
$include "./core/input/f_gdp.cs3r"
$offdelim
;
pm_gdp(tall,all_regi) = f_gdp(tall,all_regi,"%cm_GDPpopScen%") * pm_shPPPMER(all_regi) / 1000000;  !! rescale from million US$ to trillion US$

*** load level of development based on GDP PPP per capita: 0 is low income, 1 is high income.
*** Values in 2020 SSP2: SSA=0.1745, IND=0.3686, OAS=0.5136, MEA=0.6568, REF=0.836, LAM=0.8763, NEU=0.9962, EUR=1, CAZ=1, CHA=1, JPN=1, USA=1
table f_developmentState(tall,all_regi,all_GDPpopScen) "level of development based on GDP PPP per capita"
$ondelim
$include "./core/input/f_developmentState.cs3r"
$offdelim
;
p_developmentState(tall,all_regi) = f_developmentState(tall,all_regi,"%cm_GDPpopScen%");

*** Load information from BAU run
Execute_Loadpoint 'input'      vm_cesIO, vm_invMacro;

pm_gdp_gdx(ttot,regi)    = vm_cesIO.l(ttot,regi,"inco");
p_inv_gdx(ttot,regi)     = vm_invMacro.l(ttot,regi,"kap");

*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                ESM
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------

*** default conversion for energy services
pm_fe2es(ttot,regi,teEs) = 1;
pm_shFeCes(ttot,regi,enty,in,teEs) = 0;

*** initialize upper and lower bound to FE share parameters as zero (this will leave any FE share bounds non-activated)
*** please set FE share bounds by modying this parameter in the sectormodules, e.g. 36_buildings and 37_industry datainput files
pm_shfe_up(ttot,regi,entyFe,sector)=0;
pm_shfe_lo(ttot,regi,entyFe,sector)=0;
pm_shGasLiq_fe_up(ttot,regi,sector)=0;
pm_shGasLiq_fe_lo(ttot,regi,sector)=0;

*** initializing energy service capital
pm_esCapCost(tall,all_regi,all_teEs) = 0;


*------------------------------------------------------------------------------------
***          Technology data input read-in and manipulation    START
*------------------------------------------------------------------------------------
*** In module 5 there are more cost manipulation after initial capacities are calculated,
*** be aware those can overwrite your technology values for policy runs if you set them here in the core
***---------------------------------------------------------------------------
*** Reading in and initializing global and regional data
***---------------------------------------------------------------------------

table fm_dataglob(char,all_te)  "Energy and CDR technology characteristics: investment costs, O&M costs, efficiency, learning rates ..."
$include "./core/input/generisdata_tech.prn"
$include "./core/input/generisdata_trade.prn"
;

*** TODO: merge all grid types into one
fm_dataglob(char,teGrid) = fm_dataglob(char,"gridwindon");


parameter p_inco0(ttot,all_regi,all_te)     "regionalized technology costs Unit: USD$/kW"
/
$ondelim
$include "./core/input/p_inco0.cs4r"
$offdelim
/;

***---------------------------------------------------------------------------
*** SSP-dependent technology assumptions
***---------------------------------------------------------------------------

$ifthen.c_techAssumptScen "%c_techAssumptScen%" == "SSP1"
*** hampers technologies with CCS or FT
*** TODO: add industry ccs technologies bfcc and idrcc
    loop(te $ (teCCS(te) or teFischerTropsch(te) or sameas(te,"ccsinje")),
        fm_dataglob("inco0",te) =        1.3 * fm_dataglob("inco0",te);
    );
*** hampers nuclear a lot
    fm_dataglob("inco0","tnrs") =        1.3 * fm_dataglob("inco0","tnrs");
*** favours transmission for non-ICE vehicules
    fm_dataglob("inco0",te) $ (sameas(te,"tdelt") or sameas(te,"tdh2t")) = 0.7 * fm_dataglob("inco0",te);
*** favours VRE and electricity storage
    fm_dataglob("learn",teVRE) =         1.1 * fm_dataglob("learn",teVRE);
    fm_dataglob("floorcost","spv") =     0.1 * fm_dataglob("floorcost","spv");
    fm_dataglob("floorcost","csp") =     0.8 * fm_dataglob("floorcost","csp");
*** RP: because of the interaction of learn rates with floor costs, it is not possible to simply apply multiplicative factors. These 
*** values need to be set by hand!
    fm_dataglob("learn","windon")     =  0.17;  !! these values make 2100 wind onshore costs ~0.8 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windon") =  200;
    fm_dataglob("learn","windoff")    =  0.16; !! these values make 2100 wind offshore costs ~0.8 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windoff") = 400; 
    fm_dataglob("inco0",teStor) =        0.7 * fm_dataglob("inco0",teStor); 
    fm_dataglob("floorcost",teStor) =    0.7 * fm_dataglob("floorcost",teStor);


$elseif.c_techAssumptScen "%c_techAssumptScen%" == "SSP3"
*** favours basic fossil technologies, reduce efficiency and maintenance costs
    loop(te(teFosNoCCS) $ (not teFischerTropsch(te)),
        fm_dataglob("inco0",te) =        0.8 * fm_dataglob("inco0",te);
        fm_dataglob("eta",te) =          0.9 * fm_dataglob("eta",te);
        fm_dataglob("omf",te) =          2/3 * fm_dataglob("omf",te);
    );
*** hampers nuclear
    fm_dataglob("inco0","tnrs") =        1.2 * fm_dataglob("inco0","tnrs");
    fm_dataglob("lifetime","tnrs") =     0.8 * fm_dataglob("lifetime","tnrs");
*** hampers transmission for non-ICE vehicules
    fm_dataglob("inco0",te) $ (sameas(te,"tdelt") or sameas(te,"tdh2t")) = 2 * fm_dataglob("inco0",te);
*** hampers VRE a lot, and electricity storage
    fm_dataglob("learn",teVRE) $ (not sameas(teVRE,"spv")) = 0.5 * fm_dataglob("learn",teVRE);
    fm_dataglob("learn","spv") =         0.8 * fm_dataglob("learn","spv");
    fm_dataglob("floorcost","spv") =     8   * fm_dataglob("floorcost","spv");
    fm_dataglob("floorcost","csp") =     1.6 * fm_dataglob("floorcost","csp");
*** RP: because of the interaction of learn rates with floor costs, it is not possible to simply apply multiplicative factors. These 
*** values need to be set by hand!
    fm_dataglob("learn","windon")     =  0.17;  !! these values make 2100 wind onshore costs ~2 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windon") =  1500;
    fm_dataglob("learn","windoff")    =  0.16; !! these values make 2100 wind offshore costs ~2 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windoff") = 2000; 

    fm_dataglob("inco0",teStor) =        2   * fm_dataglob("inco0",teStor); 
    fm_dataglob("floorcost",teStor) =    2   * fm_dataglob("floorcost",teStor); 


$elseif.c_techAssumptScen "%c_techAssumptScen%" == "SSP5"
*** favours technologies with CCS or FT
    loop(te $ (teCCS(te) or teFischerTropsch(te) or sameas(te,"ccsinje")),
        fm_dataglob("inco0",te) =        0.9 * fm_dataglob("inco0",te);
    );
*** hampers nuclear
    fm_dataglob("inco0","tnrs") =        1.3 * fm_dataglob("inco0","tnrs");
*** hampers VRE and electricity storage
    fm_dataglob("learn",teVRE) =         0.8 * fm_dataglob("learn",teVRE);
    fm_dataglob("floorcost","spv") =     3   * fm_dataglob("floorcost","spv");
    fm_dataglob("floorcost","csp") =     1.3 * fm_dataglob("floorcost","csp");
*** RP: because of the interaction of learn rates with floor costs, it is not possible to simply apply multiplicative factors. These 
*** values need to be set by hand!
    fm_dataglob("learn","windon")     =  0.17;  !! these values make 2100 wind onshore costs ~1.5 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windon") =  1000;
    fm_dataglob("learn","windoff")    =  0.16; !! these values make 2100 wind offshore costs ~1.5 times those seen in SSP2 at the same cumCap
    fm_dataglob("floorcost","windoff") = 1400; 
    fm_dataglob("inco0",teStor) =        2   * fm_dataglob("inco0",teStor); 
    fm_dataglob("floorcost",teStor) =    2   * fm_dataglob("floorcost",teStor); 


$endif.c_techAssumptScen



***---------------------------------------------------------------------------
*** Other technological assumptions (VRE, CCS...)
***---------------------------------------------------------------------------
*** cm_ccsinjeCost cost scenarios
*** Warning: it applies absolute values; only use it in combination with default c_techAssumptScen SSP2. 
*** low estimate: ccsinje cost prior to 03/2024; i.e. ~11 USD/tCO2 in 2025, decreasing to ~7.5USD/tCO2 as of 2035
$if "%cm_ccsinjeCost%" == "low" fm_dataglob("tech_stat","ccsinje") = 2;
$if "%cm_ccsinjeCost%" == "low" fm_dataglob("inco0","ccsinje") = 220;
$if "%cm_ccsinjeCost%" == "low" fm_dataglob("constrTme","ccsinje") = 0;
*** high estimate: ~20USD/tCO2 (constant), assuming upper end of storage cost and long transport distances
$if "%cm_ccsinjeCost%" == "high" fm_dataglob("inco0","ccsinje") = 550;


*** cm_VRE_supply_assumptions: Modify learning and floor costs for electricity storage and production of VRE
if (cm_VRE_supply_assumptions > 0,
    if (cm_VRE_supply_assumptions eq 1, p_VRE_assumption_factor = 0.9); !! optimistic assumptions
    if (cm_VRE_supply_assumptions eq 2, p_VRE_assumption_factor = 1.1); !! pessimistic assumptions
    if (cm_VRE_supply_assumptions eq 3, p_VRE_assumption_factor = 1.3); !! very pessimistic assumptions
    fm_dataglob("learn",teVRE) =  1 / p_VRE_assumption_factor * fm_dataglob("learn",teVRE);
    fm_dataglob("learn",teStor) = 1 / p_VRE_assumption_factor * fm_dataglob("learn",teStor);
    fm_dataglob("inco0",teStor) =     p_VRE_assumption_factor * fm_dataglob("inco0",teStor); 
    fm_dataglob("floorcost",teStor) = p_VRE_assumption_factor * fm_dataglob("floorcost",teStor);
);

*** Overwrite default technology cost parameter values based on specific scenario configs
$ifthen.cm_incolearn not "%cm_incolearn%" == "off"
    parameter p_new_incolearn(all_te) "value to overwrite incolearn parameters" / %cm_incolearn% /;
    fm_dataglob("floorcost",te) $ p_new_incolearn(te) = fm_dataglob("inco0",te) - p_new_incolearn(te);
$endif.cm_incolearn

$if not "%cm_inco0Factor%" == "off"     parameter p_new_inco0Factor(all_te) / %cm_inco0Factor% /;
$if not "%cm_inco0Factor%" == "off"               fm_dataglob("inco0",te)$p_new_inco0Factor(te) = p_new_inco0Factor(te) * fm_dataglob("inco0",te);
$if not "%cm_learnRate%" == "off"       parameter p_new_learnRate(all_te) / %cm_learnRate% /;
$if not "%cm_learnRate%" == "off"                 fm_dataglob("learn",te)$p_new_learnRate(te) = p_new_learnRate(te);
$if not "%cm_inco0RegiFactor%" == "off" parameter p_new_inco0RegiFactor(all_te) / %cm_inco0RegiFactor% /;
$if not "%cm_inco0RegiFactor%" == "off"           p_inco0(ttot,regi,te)$(p_inco0(ttot,regi,te) and p_new_inco0RegiFactor(te)) = p_new_inco0RegiFactor(te) * p_inco0(ttot,regi,te);


***---------------------------------------------------------------------------
*** Unit uniformisation
***---------------------------------------------------------------------------

*** generisdata_tech is in $2015. Needs to be converted to $2017
fm_dataglob("inco0",te)        = s_D2015_2_D2017 * fm_dataglob("inco0",te);
fm_dataglob("floorcost",te)    = s_D2015_2_D2017 * fm_dataglob("floorcost",te);
fm_dataglob("omv",te)          = s_D2015_2_D2017 * fm_dataglob("omv",te);

*** adjust costs for oae from USD/GtCaO to USD/GtC
fm_dataglob("inco0", "oae_ng") = fm_dataglob("inco0", "oae_ng") / (cm_33_OAE_eff / sm_c_2_co2);
fm_dataglob("inco0", "oae_el") = fm_dataglob("inco0", "oae_el") / (cm_33_OAE_eff / sm_c_2_co2);

*** convert inco0, floorcost and omv to REMIND units by applying a factor 0.001
***   category          energy technology   ccs technology    process-based industry 
***   input data unit   $/kW                $/(tC/a)          $/(t/a)
***   REMIND unit       T$/TW               T$/(GtC/a)        T$/(Gt/a)
fm_dataglob("inco0",te)        = s_DpKW_2_TDpTW   * fm_dataglob("inco0",te);
fm_dataglob("floorcost",te)    = s_DpKW_2_TDpTW   * fm_dataglob("floorcost",te);
fm_dataglob("omv",te)          = s_DpKWa_2_TDpTWa * fm_dataglob("omv",te);
p_inco0(ttot,regi,te)          = s_DpKW_2_TDpTW   * p_inco0(ttot,regi,te);


***---------------------------------------------------------------------------
*** Data checks
***---------------------------------------------------------------------------
file error_dataInput;

*** ensure that cost of energy technology is higher with CCS than without
loop(te2teCCS(te,teCCS) $ (fm_dataglob("inco0",teCCS) < fm_dataglob("inco0",te)),
    put error_dataInput te.tl, fm_dataglob("inco0",te) /;
    put error_dataInput teCCS.tl, fm_dataglob("inco0",teCCS) / /;

    display "Investment cost lower with CCS than without. See details in file error_dataInput.put";
    fm_dataglob("inco0",teCCS) = fm_dataglob("inco0",te) * 1.01; !! make CCS version at least 1% more expensive
***    abort "Error: Investment cost lower with CCS than without. See details in file error_dataInput.put", fm_dataglob;
);
putclose;

display fm_dataglob;


*** --------------------------------------------------------------------------------
*** Regionalize technology investment cost data
*** -------------------------------------------------------------------------------

*** initialize regionalized data using global data
pm_data(all_regi,char,te) = fm_dataglob(char,te);

*** -------------------------------------------------------------------------------
*** Regional risk premium during building time
*** -------------------------------------------------------------------------------

parameter p_risk_premium_constr(all_regi) "risk premium during construction time. Use same values as pm_risk_premium used in module 23_capital markets"
*RP* 2 parameters needed because pm_risk_premium is set to 0 in module 23 realization perfect".
/
$ondelim
$include "./core/input/pm_risk_premium.cs4r"
$offdelim
/;

*** calculate turnkey costs, which are the sum of the overnight costs and the "interest during construction” (IDC)
loop(te $ (fm_dataglob("constrTme",te) > 0),
  p_tkpremused(regi,te) = 1 / fm_dataglob("constrTme",te)
    * sum(integ $ (integ.val <= fm_dataglob("constrTme",te)),
                              (1
                                  + 0.02 / pm_ies(regi) !! intertemporal elasticity of substitution
                                  + pm_prtp(regi) !! pure rate of time preference
*** if technology costs are regionalised, also use regionalised financing costs
$if not "%cm_techcosts%" == "GLO" + p_risk_premium_constr(regi)
*** nuclear sees 3% higher interest rates during construction time due to higher construction time risk
*** see "The economic future of nuclear power - A study conducted at The University of Chicago" (2004)
                                  + 0.03 $ sameas(te,"tnrs")
                              ) ** (integ.val - 0.5) - 1
    );
);

display p_tkpremused;

*** modify regionalized cost data using cost premium during construction time
pm_data(regi,"inco0",te)     = (1 + p_tkpremused(regi,te) ) * pm_data(regi,"inco0",te);
pm_data(regi,"floorcost",te) = (1 + p_tkpremused(regi,te) ) * pm_data(regi,"floorcost",te);
p_inco0(ttot,regi,teRegTechCosts)  = (1 + p_tkpremused(regi,teRegTechCosts) ) * p_inco0(ttot,regi,teRegTechCosts);

*** take region average p_tkpremused for global convergence price
fm_dataglob("inco0",te)      = (1 + sum(regi, p_tkpremused(regi,te)) / card(regi)) * fm_dataglob("inco0",te);
fm_dataglob("floorcost",te)  = (1 + sum(regi, p_tkpremused(regi,te)) / card(regi)) * fm_dataglob("floorcost",te);

*** ====================== floor cost scenarios ===========================
*** report old floor costs pre manipulation in non-default scenario
$ifthen.floorscen not %cm_floorCostScen% == "default"
    p_oldFloorCostdata(regi,teLearn(te)) = pm_data(regi,"floorcost",te);
$endif.floorscen

*** calculate floor costs for learning technologies if historical price structure prevails
$ifthen.floorscen %cm_floorCostScen% == "pricestruc"
*** compute maximum tech cost in 2015 for a given tech among regions
    p_maxRegTechCost2015(teRegTechCosts) = SMax(regi, p_inco0("2015",regi,teRegTechCosts));
*** take the ratio of the tech cost in 2015 and the maximum cost, and multiply with the global floor to get new floorcost that preserves the price structure
    pm_data(regi,"floorcost",teLearn(te))$(p_maxRegTechCost2015(te) ne 0) = p_oldFloorCostdata(regi,te) * p_inco0("2015",regi,te) / p_maxRegTechCost2015(te);
*** for newer data than 2015, use these
    p_maxRegTechCost2020(teRegTechCosts) = SMax(regi, p_inco0("2020",regi,teRegTechCosts));
    pm_data(regi,"floorcost",teLearn(te))$(p_maxRegTechCost2020(te) ne 0) = p_oldFloorCostdata(regi,te) * p_inco0("2020",regi,te) / p_maxRegTechCost2020(te);
*** report the new floor cost data
    p_newFloorCostdata(regi,teLearn(te))$(p_maxRegTechCost2015(te) ne 0) = p_oldFloorCostdata(regi,te) * p_inco0("2015",regi,te) / p_maxRegTechCost2015(te);
    p_newFloorCostdata(regi,teLearn(te))$(p_maxRegTechCost2020(te) ne 0) = p_oldFloorCostdata(regi,te) * p_inco0("2020",regi,te) / p_maxRegTechCost2020(te);
$endif.floorscen


*** calculate floor costs for learning technologies if there is technology transfer
$ifthen.floorscen %cm_floorCostScen% == "techtrans"
*** compute maximum income GDP PPP per capita among regions in 2050
    p_gdppcap2050_PPP(regi) = pm_gdp("2050",regi) / pm_shPPPMER(regi) / pm_pop("2050",regi);
    p_maxPPP2050 = SMax(regi, p_gdppcap2050_PPP(regi));
*** take the ratio of the PPP income and the maximum income, and multiply with the global floor to get new floorcost that simulates tech transfer where costs are solely dependent on local wages, not on IP rent
    pm_data(regi,"floorcost",teLearn(te))$(p_maxPPP2050 ne 0) = p_oldFloorCostdata(regi,te) * p_gdppcap2050_PPP(regi) / p_maxPPP2050;
    p_newFloorCostdata(regi,teLearn(te))$(p_maxPPP2050 ne 0) = p_oldFloorCostdata(regi,te) * p_gdppcap2050_PPP(regi) / p_maxPPP2050;
$endif.floorscen

*** In case regionally differentiated investment costs should be used the corresponding entries are revised:
$ifthen.REG_techcosts not "%cm_techcosts%" == "GLO"   !! cm_techcosts is REG or REG2040
*** calculate regional floor costs for learning technologies from ratio of global values
*** take the ratio of the global floorcost to global initial cost, and multiply with the new regional cost to get new floorcost that should create reasonable learning paths around 2020
    pm_data(regi,"floorcost",teLearn(te))$(teRegTechCosts(te) ) = p_inco0("2015",regi,te) * fm_dataglob("floorcost",te) / fm_dataglob("inco0",te);
    pm_data(regi,"floorcost","spv") = p_inco0("2020",regi,"spv") * fm_dataglob("floorcost","spv") / fm_dataglob("inco0","spv") ; !! 2020 values are available for PV

    pm_data(regi,"inco0",teRegTechCosts) = p_inco0("2015",regi,teRegTechCosts);
    pm_data(regi,"inco0","spv")          = p_inco0("2020",regi,"spv");
$endif.REG_techcosts

*** -------------------------------------------------------------------------------
*** Calculate learning parameters
*** See equations.gms for documentation of learning equations and floor costs
*** -------------------------------------------------------------------------------
*** calculate default learnable costs for learning technologies
fm_dataglob("incolearn",teLearn(te))  = fm_dataglob("inco0",te)  - fm_dataglob("floorcost",te);
pm_data(regi,"incolearn",teLearn(te)) = pm_data(regi,"inco0",te) - pm_data(regi,"floorcost",te);

*** global parameters: calculation for global level, that regional values can gradually converge to
*** b' = \frac{I_0}{I_0 - F} b = \frac{I_0}{I_0 - F} \log_2(1-\lambda)
fm_dataglob("learnExp_wFC",teLearn(te)) = fm_dataglob("inco0",te) / fm_dataglob("incolearn",te) * log(1 - fm_dataglob("learn",te)) / log(2);
*** a' = \frac{I_0 - F}{C_0^{b'}}
fm_dataglob("learnMult_wFC",teLearn(te)) = fm_dataglob("incolearn",te) / (fm_dataglob("ccap0",te) ** fm_dataglob("learnExp_wFC", te));

*** regional parameters
pm_data(regi,"learnExp_wFC",teLearn(te)) = pm_data(regi,"inco0",te) / pm_data(regi,"incolearn",te) * log(1 - pm_data(regi,"learn",te)) / log(2);

$ifthen %cm_techcosts% == "GLO"
    pm_data(regi,"learnMult_wFC",teLearn(te)) = pm_data(regi,"incolearn",te) / (sum(regi2,pm_data(regi2,"ccap0",te)) ** pm_data(regi,"learnExp_wFC",te));

$else
!! cm_techcosts is REG or REG2040
*NB* read in vm_capCum(t0,regi,teLearn) from input.gdx to have info available for the recalibration of 2005 investment costs
  Execute_Loadpoint 'input' p_capCum = vm_capCum.l;
*** FS: in case technologies did not exist in gdx, set intial capacities to global initial value
  p_capCum(tall,regi,te)$(not p_capCum(tall,regi,te)) = fm_dataglob("ccap0",te) / card(regi);
*RP overwrite p_capCum by exogenous values for 2020
  p_capCum("2020",regi,"spv")  = 0.6 / card(regi2);  !! roughly 600GW in 2020 globally
*NB* this is the correction of the original parameter calibration
  pm_data(regi,"learnMult_wFC",teLearn(te))  = pm_data(regi,"incolearn",te)    / (sum(regi2,p_capCum("2015",regi2,te))    ** pm_data(regi,"learnExp_wFC",te));
*** initialize spv learning curve in 2020
  pm_data(regi,"learnMult_wFC","spv")        = pm_data(regi,"incolearn","spv") / (sum(regi2,p_capCum("2020",regi2,"spv")) ** pm_data(regi,"learnExp_wFC","spv"));
display p_capCum;
$endif

*FS* initialize learning curve for most advanced technologies as defined by tech_stat = 4 in generisdata_tech.prn (with very small real-world capacities in 2020)
*** equally for all regions based on global cumulative capacity of ccap0 and incolearn (difference between initial investment cost and floor cost)
pm_data(regi,"learnMult_wFC",te)$( pm_data(regi,"tech_stat",te) eq 4 )
  = pm_data(regi,"incolearn",te)
  / ( fm_dataglob("ccap0",te)
   ** pm_data(regi,"learnExp_wFC",te)
    );

display pm_data;
*** -------------------------------------------------------------------------------
*** end learning parameters
*** -------------------------------------------------------------------------------

*** Markup for advanced technologies
table p_costMarkupAdvTech(s_statusTe,tall)              "Multiplicative investment cost markup for early time periods (until 2030) on advanced technologies (CCS, Hydrogen) that are not modeled through endogenous learning"
$include "./core/input/p_costMarkupAdvTech.prn"
;

*** add mark-up cost for tech_stat 4 and 5 technologies as for tech_stat 3 technologies in first years
p_costMarkupAdvTech("4",ttot) = p_costMarkupAdvTech("3",ttot);
p_costMarkupAdvTech("5",ttot) = p_costMarkupAdvTech("3",ttot);

loop (teNoLearn(te),
  pm_inco0_t(ttot,regi,te) = pm_data(regi,"inco0",te);
  loop (ttot$( ttot.val ge 2005 AND ttot.val lt 2035 ),
    pm_inco0_t(ttot,regi,te)
    = sum(s_statusTe$( s_statusTe.val eq pm_data(regi,"tech_stat",te) ),
        p_costMarkupAdvTech(s_statusTe,ttot)
      * pm_inco0_t(ttot,regi,te)
      );
  );
);
display pm_inco0_t;

*** regional differentiation and convergence of non-learning technologies costs
$ifthen.REG2040_techcosts "%cm_techcosts%" == "REG2040"   !! cm_techcosts REG2040
*** for 2015-2040, use differentiated costs when available for a specific non-learning technology
    loop(te$( teNoLearn(te) AND teRegTechCosts(te) ),
      pm_inco0_t(ttot,regi,te)$( ttot.val ge 2015 AND ttot.val lt 2045)
      = p_inco0(ttot,regi,te);

*** after 2040, keep the same regionally differentiated costs
      pm_inco0_t(ttot,regi,te)$( ttot.val gt 2040 ) = p_inco0("2040",regi,te);
    );
$endif.REG2040_techcosts

$ifthen.REG_techcosts "%cm_techcosts%" == "REG"   !! cm_techcosts REG
*** for 2015-2020, use differentiated costs when available for a specific non-learning technology
    loop(te$( teNoLearn(te) AND teRegTechCosts(te) ),
      pm_inco0_t(ttot,regi,te)$( ttot.val ge 2015 AND ttot.val lt 2025)
      = p_inco0(ttot,regi,te);

*** from 2025 to c_teNoLearngConvEndYr, apply linear convergence of investment costs so that
*** all regions converge and stabilise at the technology cost data given in generisdata.prn
      loop(ttot$( ttot.val ge 2020 AND ttot.val le c_teNoLearngConvEndYr ),
        pm_inco0_t(ttot,regi,te)
        = (
            (pm_ttot_val(ttot) - 2020) * fm_dataglob("inco0",te)
            + (c_teNoLearngConvEndYr - pm_ttot_val(ttot)) * pm_inco0_t("2020",regi,te)
          )
          / (c_teNoLearngConvEndYr - 2020);
      );

      pm_inco0_t(ttot,regi,te)$( ttot.val gt c_teNoLearngConvEndYr ) = fm_dataglob("inco0",te);
    );

*** re-insert effect of costMarkupAdvTech for IGCC in the regionalized cost
*** data, as the IEA numbers have unrealistically low IGCC costs in 2005-2020
    loop (teNoLearn(te)$( sameas(te,"igcc") ),
      loop (ttot$( ttot.val ge 2005 AND ttot.val lt 2035 ),
        pm_inco0_t(ttot,regi,te)
        = sum(s_statusTe$( s_statusTe.val eq pm_data(regi,"tech_stat",te) ),
            p_costMarkupAdvTech(s_statusTe,ttot)
          * pm_inco0_t(ttot,regi,te)
          );
      );
    );
$endif.REG_techcosts

*------------------------------------------------------------------------------------
***          Technology data input read-in and manipulation    END
*------------------------------------------------------------------------------------
*** Note: in modules/05_initialCap/on/preloop.gms, there are additional adjustment to investment
*** cost in the near term due to calibration of historical energy conversion efficiencies based on
*** initial capacities
*------------------------------------------------------------------------------------

*** Determine CCS injection rates
*** for c_ccsinjecratescen =0 the storing variable vm_co2CCS will be fixed to 0 in bounds.gms, the sm_ccsinjecrate=0 will cause a division by 0 error in the 21_tax module
s_ccsinjecrate = 0.005
if (c_ccsinjecratescen eq 2, s_ccsinjecrate = s_ccsinjecrate *   0.50 ); !! Lower estimate
if (c_ccsinjecratescen eq 3, s_ccsinjecrate = s_ccsinjecrate *   1.50 ); !! Upper estimate
if (c_ccsinjecratescen eq 4, s_ccsinjecrate = s_ccsinjecrate * 200    ); !! remove flow constraint for DAC runs
if (c_ccsinjecratescen eq 5, s_ccsinjecrate = s_ccsinjecrate *   0.20 ); !! sustainable estimate
if (c_ccsinjecratescen eq 6, s_ccsinjecrate = s_ccsinjecrate *   0.44 ); !! Intermediate estimate
pm_ccsinjecrate(regi) = s_ccsinjecrate;

*** OR: overwrite with regional values of ccs injection rate
$ifthen.c_ccsinjecrateRegi not "%c_ccsinjecrateRegi%" == "off"
Parameter p_extRegiccsinjecrateRegi(ext_regi) "Regional CCS injection rate factor. 1/a. (extended regions)" / %c_ccsinjecrateRegi% /;
loop((ext_regi)$p_extRegiccsinjecrateRegi(ext_regi),
  pm_ccsinjecrate(regi)$(regi_groupExt(ext_regi,regi)) = p_extRegiccsinjecrateRegi(ext_regi);
);
;
$endif.c_ccsinjecrateRegi

table f_dataemiglob(all_enty,all_enty,all_te,all_enty)  "read-in of emissions factors co2,cco2"
$include "./core/input/generisdata_emi.prn"
;

parameter pm_share_ind_fesos(tall,all_regi)              "Share of coal solids (coaltr) used in the industry (rest is residential)"
/
$ondelim
$include "./core/input/p_share_ind_fesos.cs4r"
$offdelim
/;

parameter pm_share_ind_fesos_bio(tall,all_regi)           "Share of biomass solids (biotr) used in the industry (rest is residential)"
/
$ondelim
$include "./core/input/p_share_ind_fesos_bio.cs4r"
$offdelim
/;

*** initialize pm_share_trans with the global value, will be updated after each negishi/nash iteration
pm_share_trans("2005",regi) = 0.617;
pm_share_trans("2010",regi) = 0.625;
pm_share_trans("2015",regi) = 0.626;
pm_share_trans("2020",regi) = 0.642;
pm_share_trans("2025",regi) = 0.684;
pm_share_trans("2030",regi) = 0.710;
pm_share_trans("2035",regi) = 0.727;
pm_share_trans("2040",regi) = 0.735;
pm_share_trans("2045",regi) = 0.735;
pm_share_trans("2050",regi) = 0.742;
pm_share_trans("2055",regi) = 0.736;
pm_share_trans("2060",regi) = 0.751;
pm_share_trans("2070",regi) = 0.774;
pm_share_trans("2080",regi) = 0.829;
pm_share_trans("2090",regi) = 0.810;
pm_share_trans("2100",regi) = 0.829;
pm_share_trans("2110",regi) = 0.818;
pm_share_trans("2130",regi) = 0.865;
pm_share_trans("2150",regi) = 0.872;


$ifthen.tech_CO2capturerate not "%c_tech_CO2capturerate%" == "off"
p_PECarriers_CarbonContent(peFos)=pm_cintraw(peFos);
*** From conversation: 25 GtC/ZJ is the assumed carbon content of PE biomass (makes default bioh2c capture rate 90%)
*** Convert to GtC/TWa
p_PECarriers_CarbonContent("pebiolc")=25 / s_zj_2_twa;
loop(pe2se(entyPe,entySe,te)$(p_tech_co2capturerate(te)),
  if(p_tech_co2capturerate(te) gt 0,
    if(p_tech_co2capturerate(te) ge 1,
		  abort "Error: Inconsistent switch usage. A CO2 capture rate is greater than 1. Check c_tech_CO2capturerate.";
	  );
*** Alter CO2 capture rate in f_dataemiglob
*** f_dataemiglob is given in GtC/ZJ
    f_dataemiglob(entyPe,entySe,te,"cco2") = p_tech_co2capturerate(te) * p_PECarriers_CarbonContent(entyPe) * s_zj_2_twa;
    if(sameAs(entyPe,"pebiolc"),
      f_dataemiglob(entyPe,entySe,te,"co2") = -f_dataemiglob(entyPe,entySe,te,"cco2") ;
    else
      f_dataemiglob(entyPe,entySe,te,"co2") = p_PECarriers_CarbonContent(entyPe) - f_dataemiglob(entyPe,entySe,te,"cco2") ;
	);
  );
);
display f_dataemiglob;
$endif.tech_CO2capturerate

*** CO2 capture rate of CCS technologies (new SSP5 assumptions)
if (c_ccscapratescen eq 2,
  f_dataemiglob("pecoal","seel","igccc","co2")    = 0.2;
  f_dataemiglob("pecoal","seel","igccc","cco2")   = 25.9;
  f_dataemiglob("pecoal","seh2","coalh2c","co2")  = 0.2;
  f_dataemiglob("pecoal","seh2","coalh2c","cco2") = 25.9;
$ifthen "%c_SSP_forcing_adjust%" == "forcing_SSP5"
  f_dataemiglob("pegas","seel","ngccc","co2")  = 0.1;
  f_dataemiglob("pegas","seel","ngccc","cco2") = 15.2;
  f_dataemiglob("pegas","seh2","gash2c","co2")  = 0.1;
  f_dataemiglob("pegas","seh2","gash2c","cco2") = 15.2;
$endif
);
*nb* specific emissions of transformation technologies (co2 in gtc/zj -> conv. gtc/twyr):
f_dataemiglob(enty,enty2,te,"co2")$pe2se(enty,enty2,te)       = 1/s_zj_2_twa * f_dataemiglob(enty,enty2,te,"co2");
f_dataemiglob(enty,enty2,te,"cco2")                           = 1/s_zj_2_twa * f_dataemiglob(enty,enty2,te,"cco2");

table f_dataetaglob(tall,all_te)                      "global eta data"
$include "./core/input/generisdata_varying_eta.prn"
;

*** Read in mac historical emissions to calibrate MAC reference emissions
parameter p_histEmiMac(tall,all_regi,all_enty)    "historical emissions per MAC"
/
$ondelim
$include "./core/input/p_histEmiMac.cs4r"
$offdelim
/;
*** Read in historical emissions per sector to calibrate MAC reference emissions
parameter p_histEmiSector(tall,all_regi,all_enty,emi_sectors,sector_types)    "historical emissions per sector"
/
$ondelim
$include "./core/input/p_histEmiSector.cs4r"
$offdelim
/;

***---------------------------------------------------------------------------
*** Import and set regional data
***---------------------------------------------------------------------------

*** CO2-technologies don't have own emissions, but the pipeline leakage rate (s_co2pipe_leakage) is multiplied on the individual pe2se
s_co2pipe_leakage = 0.01;

loop(emi2te(enty,enty2,te,enty3)$teCCS(te),
    f_dataemiglob(enty,enty2,te,"co2")  = f_dataemiglob(enty,enty2,te,"co2") + f_dataemiglob(enty,enty2,te,"cco2") * s_co2pipe_leakage ;
    f_dataemiglob(enty,enty2,te,"cco2") = f_dataemiglob(enty,enty2,te,"cco2") * (1 - s_co2pipe_leakage );
);

*** Allocate emission factors to pm_emifac
option pm_emifac:3:3:1;
pm_emifac(ttot,regi,enty,enty2,te,"co2")$emi2te(enty,enty2,te,"co2")   = f_dataemiglob(enty,enty2,te,"co2");
pm_emifac(ttot,regi,enty,enty2,te,"cco2")$emi2te(enty,enty2,te,"cco2") = f_dataemiglob(enty,enty2,te,"cco2");
*JeS scale N2O energy emissions to EDGAR
pm_emifac(ttot,regi,enty,enty2,te,"n2o")$emi2te(enty,enty2,te,"n2o") = 0.905 * f_dataemiglob(enty,enty2,te,"n2o");

***JeS from IPCC http://www.ipcc-nggip.iges.or.jp/public/gp/bgp/2_2_Non-CO2_Stationary_Combustion.pdf:
***JeS CH4: 300 kg/TJ = 0.3 Mt/EJ * 31.536 EJ/TWa = 9.46 Mt /TWa
***JeS N2O: 1 kg/TJ = 0.001 Mt/EJ * 31.536 EJ/TWa = 0.031536 Mt / TWa
*** coal 1.4 kg/TJ = 0.04415 Mt/TWa
*** gas 0.1 kg/TJ = 0.00315 Mt/TWa
*** oil 0.6 kg/TJ = 0.01892 Mt/TWa
*** biomass 4 kg/TJ = 0.12614 Mt/TWa;
*** EF for N2O are in generisdata_emi.prn
pm_emifac(t,regi,"pecoal","sesofos","coaltr","ch4") = 9.46 * (1-pm_share_ind_fesos("2005",regi));
pm_emifac(t,regi,"pebiolc","sesobio","biotr","ch4") = 9.46 * (1-pm_share_ind_fesos_bio("2005",regi));

display pm_emifac;

*MLB* initialization needed as include file represents only parameters that are different from zero
p_boundtmp(ttot,all_regi,te,rlf)$(ttot.val ge 2005)       = 0;
p_bound_cap(ttot,all_regi,te,rlf)$(ttot.val ge 2005)       = 0;

*NB* include data and parameters for upper bounds on fossil fuel transport
parameter f_IO_trade(tall,all_regi,all_enty,char)        "Energy trade bounds based on IEA data"
/
$ondelim
$include "./core/input/f_IO_trade.cs4r"
$offdelim
/;
pm_IO_trade(ttot,regi,enty,char) = f_IO_trade(ttot,regi,enty,char) * sm_EJ_2_TWa;

*** use scaled data for export to guarantee net trade = 0 for each traded good
loop(tradePe,
    loop(ttot,
       if(sum(regi2, pm_IO_trade(ttot,regi2,tradePe,"Xport")) ne 0,
            pm_IO_trade(ttot,regi,tradePe,"Xport") = pm_IO_trade(ttot,regi,tradePe,"Xport") * sum(regi2, pm_IO_trade(ttot,regi2,tradePe,"Mport")) / sum(regi2, pm_IO_trade(ttot,regi2,tradePe,"Xport"));
       );
    );
);
display pm_IO_trade;

***nicolasb*DOT* FILE produced from D:\projekte\rose\resources\fossilGrades_nico.m; 2011,12,16;12:14:44
***nicolasb*DOT* original data from literature (Brandt 2009, Charpentier 2009)
***nicolasb*DOT* data files are available at RD3 drive roseBob_finSSP.xls
***nicolasb*DOT* tbd the script is available in the common script folder
***nicolasb*DOT* The parameter describes the extra CO2 emissions from fuel extraction on top of the PE combustion emissions
***nicolasb*DOT* the units are: GtC per TWa
***nicolasb*DOT* ATTENTION: the data given here must crrespond with the mapping emi2fuelMine(enty,enty2,rlf)
p_cint(regi,"co2","peoil","4")=0.0475647000;
p_cint(regi,"co2","peoil","5")=0.1078133200;
p_cint(regi,"co2","peoil","6")=0.1775748800;
p_cint(regi,"co2","peoil","7")=0.2283105600;
p_cint(regi,"co2","peoil","8")=0.4153983800;

*** historical installed capacity
$Offlisting
table   pm_histCap(tall,all_regi,all_te) "historical installed capacity (TW)"
$ondelim
$include "./core/input/pm_histCap.cs3r"
$offdelim
;
$Onlisting

*** renewable historical capacity should only increase as it cannot retire
pm_histCap("2020",regi,teReNoBio) = max(pm_histCap("2015",regi,teReNoBio), pm_histCap("2020",regi,teReNoBio));
pm_histCap("2025",regi,teReNoBio) = max(pm_histCap("2020",regi,teReNoBio), pm_histCap("2025",regi,teReNoBio));

*** calculate historic capacity additions
pm_delta_histCap(tall,regi,te) = pm_histCap(tall,regi,te) - pm_histCap(tall-1,regi,te);

*** historical PE installed capacity
table p_PE_histCap(tall,all_regi,all_enty,all_enty) "historical installed capacity (TW)"
$ondelim
$include "./core/input/p_PE_histCap.cs3r"
$offdelim
;

*** installed capacity availability
$Offlisting
table   f_cf(tall,all_regi,all_te) "installed capacity availability"
$ondelim
$include "./core/input/f_cf.cs3r"
$offdelim
;
$Onlisting

pm_cf(ttot,regi,te) =  f_cf(ttot,regi,te);
***pm_cf(ttot,regi,"h2turbVRE") = 0.15;
pm_cf(ttot,regi,"elh2VRE") = 0.6;
*** short-term fix for new synfuel td technologies
pm_cf(ttot,regi,"tdsyngas") = 0.65;
pm_cf(ttot,regi,"tdsynhos") = 0.6;
pm_cf(ttot,regi,"tdsynpet") = 0.7;
pm_cf(ttot,regi,"tdsyndie") = 0.7;
*** eternal short-term fix for process-based industry
pm_cf(ttot,regi,"bf") = 0.8;
pm_cf(ttot,regi,"eaf") = 0.8;
pm_cf(ttot,regi,"bof") = 0.8;
pm_cf(ttot,regi,"idr") = 0.8;
pm_cf(ttot,regi,"idrcc") = 1.0; !! capex is derived from numbers per ton of CO2, where cf = 1 is assumed in conversion
pm_cf(ttot,regi,"bfcc") = 1.0;   !! capex is derived from numbers per ton of CO2, where cf = 1 is assumed in conversion

*RP* phasing down the ngt cf to "peak load" cf of 5%
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2025) = 0.9 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2030) = 0.8 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val eq 2035) = 0.7 * pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"ngt")$(ttot.val ge 2040) = 0.6 * pm_cf(ttot,regi,"ngt");

*RP* set H2 turbines to the same CF values
pm_cf(ttot,regi,"h2turb")$(ttot.val ge 2025) = pm_cf(ttot,regi,"ngt");
pm_cf(ttot,regi,"h2turbVRE")$(ttot.val ge 2025) = pm_cf(ttot,regi,"ngt");

*** FS: set CF of additional t&d H2 for buildings and industry to t&d H2 stationary value
pm_cf(ttot,regi,"tdh2b") = pm_cf(ttot,regi,"tdh2s");
pm_cf(ttot,regi,"tdh2i") = pm_cf(ttot,regi,"tdh2s");


*** Region- and tech-specific early retirement rates
loop(ext_regi$pm_extRegiEarlyRetiRate(ext_regi),
  pm_regiEarlyRetiRate(t,regi,te)$(regi_group(ext_regi,regi)) = pm_extRegiEarlyRetiRate(ext_regi);
);
***Tech-specific*
*RP*: reduce early retirement for technologies with additional characteristics that are difficult to represent in REMIND, eg. industries built around heating/CHP plants, or flexibility from ngt plants
pm_regiEarlyRetiRate(t,regi,"ngt")     = 0.3 * pm_regiEarlyRetiRate(t,regi,"ngt");      !! ngt should only be phased out very slowly, as they provide flexibility - which REMIND is not too good at capturing endogeneously
pm_regiEarlyRetiRate(t,regi,"gaschp")  = 0.5 * pm_regiEarlyRetiRate(t,regi,"gaschp");   !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"coalchp") = 0.5 * pm_regiEarlyRetiRate(t,regi,"coalchp");  !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"gashp")   = 0.5 * pm_regiEarlyRetiRate(t,regi,"gashp");    !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"coalhp")  = 0.5 * pm_regiEarlyRetiRate(t,regi,"coalhp");   !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"biohp")   = 0.25 * pm_regiEarlyRetiRate(t,regi,"biohp");   !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"biochp")  = 0.25 * pm_regiEarlyRetiRate(t,regi,"biochp");  !! chp should only be phased out slowly, as district heating networks/ industry uses are designed to a specific heat input
pm_regiEarlyRetiRate(t,regi,"bioigcc") = 0.25 * pm_regiEarlyRetiRate(t,regi,"bioigcc"); !! reduce bio early retirement rate

$ifthen.tech_earlyreti not "%c_tech_earlyreti_rate%" == "off"
loop((ext_regi,te)$p_techEarlyRetiRate(ext_regi,te),
  pm_regiEarlyRetiRate(t,regi,te)$(regi_group(ext_regi,regi) and (t.val lt c_earlyRetiValidYr or sameas(ext_regi,"GLO"))) = p_techEarlyRetiRate(ext_regi,te);
);
$endif.tech_earlyreti

*** Time-dependent early retirement rates in Baseline scenarios
$ifthen.Base_Cprice %carbonprice% == "none"
$ifthen.Base_techpol %techpol% == "none"
*** CG: Allow no early retirement in future periods under baseline for developing countries
loop(regi,
if ( p_developmentState("2015",regi) < 1,
pm_regiEarlyRetiRate(t,regi,"pc")= 0;
);
);
$endif.Base_techpol
$endif.Base_Cprice

display pm_regiEarlyRetiRate;

***---------------------------------------------------------------------------
*** Calculate lifetime parameters (omeg and opTimeYr2te)
***---------------------------------------------------------------------------

*** FS: use lifetime of tdh2s for tdh2b and tdh2i technologies
*** which are only helper technologies for consistent H2 use in industry and buildings
pm_data(regi,"lifetime","tdh2i") = pm_data(regi,"lifetime","tdh2s");
pm_data(regi,"lifetime","tdh2b") = pm_data(regi,"lifetime","tdh2s");

*** Compute the depreciation of technologies over their lifetime
*' Technologies depreciate over their lifetime.
*' Their remaining capacity pm_omeg starts at 1 and decreases toward zero with a curve of exponent 4:
*' slow depreciation during the first half of the lifetime and faster during the second half.
*' The area under that curve (capacity * age) equals the average technical lifetime of the technology,
*' provided in generisdata_tech.prn.
*' There is still some non-zero capacity beyond the average lifetime, until the maximum lifetime p_lifetime_max
*' (calculated from an integral as 5/4 times the average lifetime).
p_lifetime_max(regi,te) = 5 / 4 * pm_data(regi,"lifetime",te);
pm_omeg(regi,opTimeYr,te) = max(0, 1 - ((opTimeYr.val - 0.5) / p_lifetime_max(regi,te))**4);

*** Map each technology with its possible age
opTimeYr2te(te,opTimeYr) $ sum(regi $ (pm_omeg(regi,opTimeYr,te) > 0), 1) = yes;
*** Map each model timestep with the possible age of technologies 
tsu2opTimeYr(ttot,"1") = yes;
loop((ttot,ttot2) $ (ord(ttot2) le ord(ttot)),
  loop(opTimeYr $ (opTimeYr.val = pm_ttot_val(ttot) - pm_ttot_val(ttot2) + 1),
    tsu2opTimeYr(ttot,opTimeYr) =  yes;
  );
);

display pm_omeg, opTimeYr2te, tsu2opTimeYr;

*** In year ttot, a technology of age opTimeYr has seen pm_tsu2opTimeYr model timesteps
pm_tsu2opTimeYr(ttot,opTimeYr) $ tsu2opTimeYr(ttot,opTimeYr) =
  sum(opTimeYr2 $ (    ord(opTimeYr2) le ord(opTimeYr)
                   AND tsu2opTimeYr(ttot, opTimeYr2)),
    1);

display pm_tsu2opTimeYr;


*** Safety checks raising an error if:
loop(regi,
  loop(te,
***   - technology has zero life time (if pm_omeg is zero for the first time step)
    if(pm_omeg(regi,"1",te) eq 0,
      abort "Technology has zero lifetime", pm_omeg);
***   - lifetime of technology is longer than allowed by opTimeYr
    if(p_lifetime_max(regi,te) > smax(opTimeYr, opTimeYr.val),
      abort "Technology has longer lifetime than allowed by opTimeYr", opTimeYr, p_lifetime_max);
***   - technology has remaining capacity beyond its lifetime
    if(
      sum(opTimeYr $ (opTimeYr.val > smax(opTimeYr2te(te,opTimeYr2), opTimeYr2.val)),
        pm_omeg(regi,opTimeYr,te)
      ) > 0,
        abort "Technology has remaining capacity beyond its lifetime", opTimeYr2te, pm_omeg);
  );
);


*RP* calculate annuity of a technology
p_discountedLifetime(te) = sum(opTimeYr, (sum(regi, pm_omeg(regi,opTimeYr,te))/sum(regi,1)) / 1.06**opTimeYr.val );
pm_teAnnuity(te) = 1/p_discountedLifetime(te) ;

display p_discountedLifetime, pm_teAnnuity;

*** read in data on Nuclear capacities used as bound on vm_cap.fx("2015",regi,"tnrs","1"), vm_deltaCap.fx("2020",regi,"tnrs","1") and vm_deltaCap.up("2025" and "2030")
parameter pm_NuclearConstraint(ttot,all_regi,all_te)       "parameter with the real-world capacities, construction and plans"
/
$ondelim
$include "./core/input/pm_NuclearConstraint.cs4r"
$offdelim
/;
*** avoid negative additions requiremnet for 2020
loop(regi,
if(pm_NuclearConstraint("2020",regi,"tnrs")<0,
    pm_NuclearConstraint("2020",regi,"tnrs")=0;
);
);

*** read in data on CCS capacities and announced projects used as upper and lower bound on vm_co2CCS in 2025 and 2030
parameter p_boundCapCCS(ttot,all_regi,project_status)        "installed and planned capacity of CCS"
/
$ondelim
$include "./core/input/p_boundCapCCS.cs4r"
$offdelim
/;

*** read in indicators on whether CCS is used in 2025 and 2030 (0 = no)
parameter p_boundCapCCSindicator(all_regi)        "CCS used in until 2030"
/
$ondelim
$include "./core/input/p_boundCapCCSindicator.cs4r"
$offdelim
/;

*** read in CO2 emisisons for 2010, used to fix vm_emiTe.up("2010",regi,"co2")
parameter p_boundEmi(tall,all_regi)        "domestic CO2 emissions that are allowed in 2010 Unit: GtC"
/
$ondelim
$include "./core/input/p_boundEmi.cs4r"
$offdelim
/;
*** read in F-Gas emissions
parameter f_emiFgas(tall,all_regi,all_SSP_forcing_adjust,all_rcp_scen,all_delayPolicy,all_enty)        "F-gas emissions by single gases from IMAGE"
/
$ondelim
$include "./core/input/f_emiFgas.cs4r"
$offdelim
/;


* GA Read choice of non-CO2 MACs version
* PBL_2007 is based on Lucas et al. (2007), and abatement is relative to that study's IMAGE baseline scenario emissions, asssumed relative to ours here
* PBL_2022 is based on van Harmsen et al. (2022), and abatement is relative to that study's IMAGE SSP2 baseline scenario emissions, asssumed relative to ours here
$IFTHEN.MaccVersion %c_nonco2_macc_version% == "PBL_2007"
* PBL_2007 MACs are discretized in steps of 5 $/tC
sm_dmac = 5 ;
parameter p_abatparam_CH4(tall,all_regi,all_enty,steps)        "MAC costs for CH4 by source"
/
$ondelim
$include "./core/input/p_abatparam_CH4.cs4r"
$offdelim
/;
parameter p_abatparam_N2O(tall,all_regi,all_enty,steps)        "MAC costs for N2O by source"
/
$ondelim
$include "./core/input/p_abatparam_N2O.cs4r"
$offdelim
/;
$ELSEIF.MaccVersion %c_nonco2_macc_version% == "PBL_2022"
*** PBL_2022 MACs are discretized in steps of 20 $/tC
*** PBL_2022 includes three scenarios, read the big file into p_all_abatparam_CH4 and subset based on c_nonco2_macc_scenario
*** Create the set here, as it's not really used anywhere else
set macc_scens "MAC scenarios for PBL_SSP2_2022 MACCs" /Default, Optimistic, Pessimistic/;
parameter p_all_abatparam_CH4(tall,all_regi,all_enty,macc_scens,steps)        "MAC costs for CH4 by source for different scenarios, c_nonco2_macc_scenario is chosen for p_abatparam_CH4"
/
$ondelim
$include "./core/input/p_abatparam_SSP22022_CH4.cs4r"
$offdelim
/;
parameter p_abatparam_CH4(tall,all_regi,all_enty,steps) "MAC costs for CH4 by source";
*** Pick MACC scenario
p_abatparam_CH4(tall,all_regi,all_enty,steps) = p_all_abatparam_CH4(tall,all_regi,all_enty,"%c_nonco2_macc_scenario%",steps)
parameter p_all_abatparam_N2O(tall,all_regi,all_enty,macc_scens,steps)        "MAC costs for N2O by source for different scenarios, c_nonco2_macc_scenario is chosen for p_abatparam_N2O"
/
$ondelim
$include "./core/input/p_abatparam_SSP22022_N2O.cs4r"
$offdelim
/;
parameter p_abatparam_N2O(tall,all_regi,all_enty,steps) "MAC costs for N2O by source";
*** Pick MACC scenario
p_abatparam_N2O(tall,all_regi,all_enty,steps) = p_all_abatparam_N2O(tall,all_regi,all_enty,"%c_nonco2_macc_scenario%",steps)
$ENDIF.MaccVersion
;

parameter p_abatparam_CO2(tall,all_enty,steps)    "MAC costs for CO2 by source"
/
$ondelim
$include "./core/input/p_abatparam_CO2.cs4r"
$offdelim
/;
p_abatparam_CH4(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p_abatparam_CH4(tall,all_regi,all_enty,"201");
p_abatparam_N2O(tall,all_regi,all_enty,steps)$(ord(steps) gt 201) = p_abatparam_N2O(tall,all_regi,all_enty,"201");

*** Read methane emissions from fossil fuel extraction for calculating emission factors. 
*** The base year determines whether the data comes from CEDS or EDGAR
$ifthen %cm_emifacs_baseyear% == "2005" 
parameter p_emiFossilFuelExtr(all_regi,all_enty)          "methane emissions in 2005 [Mt CH4], needed for the calculation of p_efFossilFuelExtr"
/
$ondelim
$include "./core/input/p_emiFossilFuelExtr.cs4r"
$offdelim
/;
$else
parameter p_emiFossilFuelExtr(all_regi,all_enty)          "methane emissions in 2020 [Mt CH4], needed for the calculation of p_efFossilFuelExtr"
/
$ondelim
$include "./core/input/p_emiFossilFuelExtr2020.cs4r"
$offdelim
/;
$endif

*** GA: These hardcoded values were probably assuming 2005 as base year, TODO: check and adjust for 2020 case
$if %cm_LU_emi_scen% == "SSP1"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0047/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP2"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0079/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP2_lowEn"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0079/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP3"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0079/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SSP5"   p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0066/sm_EJ_2_TWa;
$if %cm_LU_emi_scen% == "SDP"    p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0047/sm_EJ_2_TWa;

*DK* In case REMIND is coupled to MAgPIE emissions are obtained from the MAgPIE reporting. Thus, emission factors are set to zero
if (cm_MAgPIE_Nash eq 1,
  p_efFossilFuelExtr(regi,"pebiolc","n2obio") = 0.0;
);

display p_efFossilFuelExtr;

*** capacity factors (nur) are 1 by default
pm_dataren(regi,"nur",rlf,te)     = 1;

*** geothermal heatpumps (geohe) do not get maxprod and nur from f_maxProdGradeRegi files
***   we set regional maxprod to 200EJ = 6.342TWa to represent unlimited potential
pm_dataren(regi,"maxprod","1","geohe") = 6.342;

*RP* hydro, spv and csp get maxprod for all regions and grades from external file
table f_maxProdGradeRegiHydro(all_regi,char,rlf) "input of regionalized maximum from hydro [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiHydro.cs3r"
$offdelim
;

pm_dataren(all_regi,"maxprod",rlf,"hydro") = sm_EJ_2_TWa * f_maxProdGradeRegiHydro(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"hydro")     = f_maxProdGradeRegiHydro(all_regi,"nur",rlf);


table f_maxProdGradeRegiWindOn(all_regi,char,rlf) "input of regionalized maximum from wind onshore [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiWindOn.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"windon") = sm_EJ_2_TWa * f_maxProdGradeRegiWindOn(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"windon")     = f_maxProdGradeRegiWindOn(all_regi,"nur",rlf);


table f_maxProdGradeRegiWindOff(all_regi,char,rlf) "input of regionalized maximum from wind offshore [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGradeRegiWindOff.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"windoff") = sm_EJ_2_TWa * f_maxProdGradeRegiWindOff(all_regi,"maxprod",rlf);
pm_dataren(all_regi,"nur",rlf,"windoff")     = f_maxProdGradeRegiWindOff(all_regi,"nur",rlf);

pm_shareWindPotentialOff2On(regi) =
    sum(rlf $ (rlf.val le 8), pm_dataren(regi,"maxprod",rlf,"windoff"))
  /
    sum(rlf $ (rlf.val le 8), pm_dataren(regi,"maxprod",rlf,"windon"));

pm_shareWindOff(ttot,regi)$(ttot.val >= 2030) = 1;


table f_dataRegiSolar(all_regi,char,all_te,rlf) "input of regionalized data for solar [EJ/a]"
$ondelim
$include "./core/input/f_dataRegiSolar.cs3r"
$offdelim
;
pm_dataren(all_regi,"maxprod",rlf,"csp")      = sm_EJ_2_TWa * f_dataRegiSolar(all_regi,"maxprod","csp",rlf);
pm_dataren(all_regi,"maxprod",rlf,"spv")      = sm_EJ_2_TWa * f_dataRegiSolar(all_regi,"maxprod","spv",rlf);
pm_dataren(all_regi,"nur",rlf,"spv")          = f_dataRegiSolar(all_regi,"nur","spv",rlf);
p_datapot(all_regi,"limitGeopot",rlf,"pesol") = f_dataRegiSolar(all_regi,"limitGeopot","spv",rlf);
pm_data(all_regi,"luse","spv")                = 0.001 * f_dataRegiSolar(all_regi,"luse","spv","1");

*** RP: rescale CSP capacity factors in REMIND
*** In the DLR resource data input files, the numbers are based on a SM3/12h setup,
*** while the cost data from IEA seems rather based on a SM2/6h setup (with 40% average CF).
*** Accordingly, decrease CF in REMIND to 2/3 of the DLR values (no need to correct maxprod,
*** as here no miscalculation of total energy yield takes place, in contrast to wind)
pm_dataren(all_regi,"nur",rlf,"csp")          = 2/3 * f_dataRegiSolar(all_regi,"nur","csp",rlf);


table f_maxProdGeothermal(all_regi,char) "input of regionalized maximum from geothermal [EJ/a]"
$ondelim
$include "./core/input/f_maxProdGeothermal.cs3r"
$offdelim
;

*** Ensure that all regions have at least a minimum potential of 0.01 EJ to prevent infeasibilities.
pm_dataren(all_regi,"maxprod","1","geohdr") = sm_EJ_2_TWa * max(0.01 , f_maxProdGeothermal(all_regi,"maxprod") ) ;


display p_datapot, pm_dataren;

***---------------------------------------------------------------------------
*** calculate average capacity factors for renewables in 2015
*** --------------------------------------------------------------------------
loop(regi,
  loop(teReNoBio(te),
    p_aux_capToDistr(regi,te) = pm_histCap("2015",regi,te) $ (pm_histCap("2015",regi,te) gt 1e-10);

*** Knowing the historical capacity (pm_histCap) in 2015, let us estimate on which grades this capacity was distributed.
*** We assume that the best grades were filled first, but only up to 80% of their potential.
    s_aux_cap_remaining = p_aux_capToDistr(regi,te);
    loop(teRe2rlfDetail(te,rlf) $ (pm_dataren(regi,"nur",rlf,te) > 0),
      if(s_aux_cap_remaining > 0,
        p_aux_capThisGrade(regi,te,rlf) = min(
            s_aux_cap_remaining,
            0.8 * pm_dataren(regi,"maxprod",rlf,te) / pm_dataren(regi,"nur",rlf,te)); !! installedCapacity = maxprod / capacityFactor
        s_aux_cap_remaining = s_aux_cap_remaining - p_aux_capThisGrade(regi,te,rlf);
      );
    );  !! teRe2rlfDetail

*** With this estimated distribution of capacity across grades (p_aux_capThisGrade),
*** let us compute the average capacity factor of each technology in 2015 (p_avCapFac2015).
    p_avCapFac2015(regi,te) =
        sum(teRe2rlfDetail(te,rlf),
          p_aux_capThisGrade(regi,te,rlf) * pm_dataren(regi,"nur",rlf,te))
      /
        (sum(teRe2rlfDetail(te,rlf), p_aux_capThisGrade(regi,te,rlf))
        + 1e-10)
  );    !! teReNoBio
);      !! regi


display p_aux_capToDistr, s_aux_cap_remaining, p_aux_capThisGrade, p_avCapFac2015, p_inco0;


parameter p_histCapFac(tall,all_regi,all_te)     "Capacity factor (fraction of the year that a plant is running) of installed capacity in 2015"
/
$ondelim
$include "./core/input/p_histCapFac.cs4r"
$offdelim
/;

*** Capacity factor for wind and solar
*** Effective capacity factor pm_dataren("nur") * pm_cf scales from historical values in 2015 to grade-based values in 2030
***   pm_dataren("nur",rlf) is the capacity factor of a given rlf grade
***   pm_cf is a multiplier that scales linearly from p_aux_capacityFactorHistOverREMIND in 2015 to 1 in 2030
*** This scaling accounts for lag effects, for instance turbines in the 2000s were much smaller hence yielding lower capacity factors
p_aux_capacityFactorHistOverREMIND(regi,teVRE) = 1;
p_aux_capacityFactorHistOverREMIND(regi,teVRE) $ (p_histCapFac("2015",regi,teVRE) and p_avCapFac2015(regi,teVRE)) =
  p_histCapFac("2015",regi,teVRE) / p_avCapFac2015(regi,teVRE);

loop(t $ (t.val ge 2015 AND t.val lt 2030),
  pm_cf(t,regi,teVRE) =
    pm_cf(t,regi,teVRE) !! always 1 for VRE in f_cf, but could be modified by modules
    * ( (2030 - pm_ttot_val(t)) * p_aux_capacityFactorHistOverREMIND(regi,teVRE)
      + (pm_ttot_val(t) - 2015)
    ) / (2030 - 2015)
);

*CG* set storage and grid of windoff to be the same as windon
pm_cf(t,regi,"storwindoff") = pm_cf(t,regi,"storwindon");
pm_cf(t,regi,"gridwindoff") = pm_cf(t,regi,"gridwindon");



display p_aux_capacityFactorHistOverREMIND, pm_dataren, pm_cf;


*** FS: sensitivity scenarios for renewable potentials
$ifthen.VREPot_Factor not "%c_VREPot_Factor%" == "off"
  loop(te$(p_VREPot_Factor(te)),
    pm_dataren(regi,"maxprod",rlf,te)$( NOT( p_aux_capThisGrade(regi,te,rlf))) = pm_dataren(regi,"maxprod",rlf,te) * p_VREPot_Factor(te);
  );
$endif.VREPot_Factor


*** -----------------------------------------------------------------

pm_dataeta(tall,regi,te) = f_dataetaglob(tall,te);

*** adjust which technologies have time-varying etas
display f_dataetaglob;
display teEtaIncr;
loop(te,
        teEtaIncr(te) = no;
        teEtaIncr(te) = yes$(f_dataetaglob('1900',te) > 0);
);
teEtaConst(te) = not teEtaIncr(te);
display teEtaIncr;

*** import regionalized CCS constraints:
table pm_dataccs(all_regi,char,rlf)                       "maximum CO2 storage capacity using CCS technology. Unit: GtC"
$ondelim
$include "./core/input/pm_dataccs.cs3r"
$offdelim
;

***-----------------------------------------------------------------------------
*** adjustment cost parameter
***-----------------------------------------------------------------------------
*** import regional offset for adjustment cost calculations
parameter p_adj_deltacapoffset(tall,all_regi,all_te)     "adjustment cost offset to prevent delay of capacity addition"
/
$ondelim
$include "./core/input/p_adj_deltacapoffset.cs4r"
$offdelim
/;
p_adj_deltacapoffset("2015",regi,"tnrs") = 1;
p_adj_deltacapoffset("2015",regi,"windoff") = p_adj_deltacapoffset("2010",regi,"windon");
p_adj_deltacapoffset("2020",regi,"windoff") = p_adj_deltacapoffset("2010",regi,"windon");




*** share of PE2SE capacities in 2005 depends on GDP-MER
p_adj_seed_reg(t,regi) = pm_gdp(t,regi) * 1e-4;


*** set global seed value of adjustment costs parameterization
*** lower seed values let adjustment cost start to have influence already at lower growth rates
loop(ttot$(ttot.val ge 2005),
*** standard setting
  p_adj_seed_te(ttot,regi,te)           = 1.00;
*** standard setting for carbon capture technologies with lower seed value
  p_adj_seed_te(ttot,regi,teCCS)        = 0.25;
*** fossil technologies
  p_adj_seed_te(ttot,regi,"gasftrec")   = 0.25;
  p_adj_seed_te(ttot,regi,"gasftcrec")  = 0.25;
  p_adj_seed_te(ttot,regi,"igcc")       = 0.50;
  p_adj_seed_te(ttot,regi,"coaltr")     = 4.00;
  p_adj_seed_te(ttot,regi,"coalftrec")  = 0.25;
  p_adj_seed_te(ttot,regi,"coalftcrec") = 0.25;
*** renewables and nuclear  
  p_adj_seed_te(ttot,regi,"geohdr")     = 0.1;
  p_adj_seed_te(ttot,regi,"hydro")      = 0.25;
  p_adj_seed_te(ttot,regi,"windoff")    = 0.5;
  p_adj_seed_te(ttot,regi,"spv")        = 2.00;
  p_adj_seed_te(ttot,regi,"csp")        = 0.25;
  p_adj_seed_te(ttot,regi,"tnrs")       = 0.25;
*** green hydrogen and synthetic fuels
  p_adj_seed_te(ttot,regi,"elh2")       = 0.5;
  p_adj_seed_te(ttot,regi,"MeOH")       = 0.5;
  p_adj_seed_te(ttot,regi,"h22ch4")     = 0.5;
*** CDR technologies  
  p_adj_seed_te(ttot,regi,'dac')        = 0.25;
  p_adj_seed_te(ttot,regi,'oae_ng')     = 0.25;
  p_adj_seed_te(ttot,regi,'oae_el')     = 0.25;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
*** steel technologies
  p_adj_seed_te(ttot,regi,"bfcc")       = 0.05;
  p_adj_seed_te(ttot,regi,"idrcc")      = 0.05;
$endif.cm_subsec_model_steel

*RP: for comparison of different technologies:
*** pm_conv_cap_2_MioLDV <- 650  # The world has slightly below 800million cars in 2005 (IEA TECO2), so with a global vm_cap of 1.2, this gives ~650
*** ==> 1TW power plant ~ 650 million LDV

*** set adjustment cost coefficients, higher values increase adjustment costs
*** standard setting
  p_adj_coeff(ttot,regi,te)             = 0.25;
*** standard setting for carbon capture technologies with higher adjustment costs
  p_adj_coeff(ttot,regi,teCCS)          = 1.0;
*** fossil technologies
  p_adj_coeff(ttot,regi,"ngcc")         = 0.4;
  p_adj_coeff(ttot,regi,"gaschp")       = 0.4;
  p_adj_coeff(ttot,regi,"gash2")        = 0.35;
  p_adj_coeff(ttot,regi,"gasftrec")     = 0.4;
  p_adj_coeff(ttot,regi,"igcc")         = 0.5;
  p_adj_coeff(ttot,regi,"pc")           = 0.5;
  p_adj_coeff(ttot,regi,"coalchp")      = 0.5;
  p_adj_coeff(ttot,regi,"coaltr")       = 0.1;
  p_adj_coeff(ttot,regi,"coalftrec")    = 0.6;
  p_adj_coeff(ttot,regi,"coalh2")       = 0.55;
*** biomass technologies
  p_adj_coeff(ttot,regi,"biochp")       = 0.55;
  p_adj_coeff(ttot,regi,"bioigcc")      = 0.55;
  p_adj_coeff(ttot,regi,"bioftrec")     = 0.65;
  p_adj_coeff(ttot,regi,"bioh2")        = 0.6;
*** renewables and nuclear
  p_adj_coeff(ttot,regi,"geohdr")       = 2.0;
  p_adj_coeff(ttot,regi,"hydro")        = 1.0;
  p_adj_coeff(ttot,regi,"windon")       = 0.25;
  p_adj_coeff(ttot,regi,"windoff")      = 0.35;
  p_adj_coeff(ttot,regi,"spv")          = 0.15;
  p_adj_coeff(ttot,regi,"tnrs")         = 1.0;
*** VRE storage and grid
  p_adj_coeff(ttot,regi,teGrid)         = 0.3;
  p_adj_coeff(ttot,regi,teStor)         = 0.05;
*** green hydrogen and synthetic fuels
  p_adj_coeff(ttot,regi,"elh2")         = 0.5;
  p_adj_coeff(ttot,regi,"MeOH")         = 0.5;
  p_adj_coeff(ttot,regi,"h22ch4")       = 0.5;
*** CO2 storage and CDR technologies
  p_adj_coeff(ttot,regi,"ccsinje")      = 1.0;
  p_adj_coeff(ttot,regi,"dac")          = 0.8;
  p_adj_coeff(ttot,regi,'oae_ng')       = 0.8;
  p_adj_coeff(ttot,regi,'oae_el')       = 0.8;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
*** steel technologies
  p_adj_coeff(ttot,regi,"bfcc")         = 1.0;
  p_adj_coeff(ttot,regi,"idrcc")        = 1.0;
$endif.cm_subsec_model_steel
);

***Rescaling adj seed and coeff if adj cost multiplier switches are on
$ifthen not "%cm_adj_seed_multiplier%" == "off"
   p_adj_seed_te(ttot,regi,te)$(p_adj_seed_multiplier(te)) = p_adj_seed_multiplier(te) * p_adj_seed_te(ttot,regi,te);
$endif

$ifthen not "%cm_adj_coeff_multiplier%" == "off"
  p_adj_coeff(ttot,regi,te)$(p_adj_coeff_multiplier(te)) = p_adj_coeff_multiplier(te) * p_adj_coeff(ttot,regi,te);
$endif

***Overwritting adj seed and coeff if adj cost overwrite switches are on
$ifthen not "%cm_adj_seed_cont%" == "off"
  p_adj_seed_te(ttot,regi,te)$p_new_adj_seed(te) = p_new_adj_seed(te);
$elseIf not "%cm_adj_seed%" == "off"
  p_adj_seed_te(ttot,regi,te)$p_new_adj_seed(te) = p_new_adj_seed(te);
$endif

$ifthen not "%cm_adj_coeff_cont%" == "off"
  p_adj_coeff(t,regi,te)$p_new_adj_coeff(te) = p_new_adj_coeff(te);
$elseIf not "%cm_adj_coeff%" == "off"
  p_adj_coeff(t,regi,te)$p_new_adj_coeff(te) = p_new_adj_coeff(te);
$endif

p_adj_coeff(ttot,regi,te)            = 32 * p_adj_coeff(ttot,regi,te);  !! Rescaling all adjustment cost coefficients

p_adj_coeff_Orig(ttot,regi,te)    = p_adj_coeff(ttot,regi,te);
p_adj_seed_te_Orig(ttot,regi,te)  = p_adj_seed_te(ttot,regi,te);

p_adj_coeff_glob(te)        = 0.0;
p_adj_coeff_glob('tnrs')    = 0.0;

*** Unit conversions
p_emi_quan_conv_ar4(enty) = 1;
p_emi_quan_conv_ar4(enty)$(emiMacMagpieCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);  !! need to use old GWP for MAC cost conversion as it only reverts what has been done in the calculation of the MACs
p_emi_quan_conv_ar4(enty)$(emiMacMagpieN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4(enty)$(emiMacExoCH4(enty)) = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4(enty)$(emiMacExoN2O(enty)) = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("ch4coal")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4gas")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4oil")     = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4wstl")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("ch4wsts")    = sm_tgch4_2_pgc * (25/s_gwpCH4);
p_emi_quan_conv_ar4("n2otrans")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2oadac")    = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2onitac")   = sm_tgn_2_pgc * (298/s_gwpN2O);
p_emi_quan_conv_ar4("n2owaste")   = sm_tgn_2_pgc * (298/s_gwpN2O);


*RP* Distribute ccap0 for all regions
pm_data(regi,"ccap0",te) = 1/card(regi)*fm_dataglob("ccap0",te);


*** -----------------------------------------------------------------------------
*** ------------ emission budgets and their time periods ------------------------
*** -----------------------------------------------------------------------------

*** definition of budgets on energy emissions in GtC and associated time period
s_t_start        = 2005;
sm_endBudgetCO2eq      = 2110;
*cb single budget should cover the full modeling time, as otherwise CO2 prices show strange behaviour around 2100 (and rest of behaviour is also biased by foresight of cap-free post 2100)
if (cm_emiscen eq 6,
sm_endBudgetCO2eq      = 2150;
);

sm_budgetCO2eqGlob = 20000.0000;

*JeS values for multigasscen = 1 are only estimates which may not meet the forcing target, only those for multigasscen = 2 have already been tested.
if(cm_emiscen eq 6,
  if(cm_multigasscen eq 1,
$if  "%cm_rcp_scen%" == "rcp20"   sm_budgetCO2eqGlob = 250.0000;
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 273.0000;
$if  "%cm_rcp_scen%" == "rcp37"   sm_budgetCO2eqGlob = 350.0000;
$if  "%cm_rcp_scen%" == "rcp45"   sm_budgetCO2eqGlob = 420.0000;
$if  "%cm_rcp_scen%" == "rcp60"   sm_budgetCO2eqGlob = 1000.0000;
$if  "%cm_rcp_scen%" == "rcp85"   sm_budgetCO2eqGlob = 20000.0000;
$if  "%cm_rcp_scen%" == "none"    sm_budgetCO2eqGlob = 20000.0000;
  );
  if(cm_multigasscen eq 2,
$if  "%cm_rcp_scen%" == "rcp20"   sm_budgetCO2eqGlob = 500.0000;
     if(cm_ccapturescen eq 1,
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 530.0000;
     );
     if(cm_ccapturescen gt 1,
$if  "%cm_rcp_scen%" == "rcp26"   sm_budgetCO2eqGlob = 700.0000;
     );
$if  "%cm_rcp_scen%" == "rcp37"   sm_budgetCO2eqGlob = 1000.0000;
$if  "%cm_rcp_scen%" == "rcp45"   sm_budgetCO2eqGlob = 1273.0000;
$if  "%cm_rcp_scen%" == "rcp60"   sm_budgetCO2eqGlob = 2700.0000;
$if  "%cm_rcp_scen%" == "rcp85"   sm_budgetCO2eqGlob = 20000.0000;
$if  "%cm_rcp_scen%" == "none"    sm_budgetCO2eqGlob = 20000.0000;
  );
);

display sm_budgetCO2eqGlob;
***-----------------------------------------------------------------------------

p_datacs(regi,"peoil") = 0;   !! RP: 0 turn off the explicit calculation of non-energy use, as it is included in the oil total. Emission correction happens through rescaling of f_dataemiglob

***------------------------------------------------------------------------------------
***                                ESM  MAC data
***------------------------------------------------------------------------------------
if(c_macscen eq 2,
  pm_macSwitch(ttot,regi,emiMacSector)  = 0;
);
  pm_macSwitch(ttot,regi,"ch4wstl") = 1;
  pm_macSwitch(ttot,regi,"ch4wsts") = 1;
if(c_macscen eq 1,
  pm_macSwitch(ttot,regi,emiMacSector) = 1;
);

*** for NDC and NPi switch off landuse MACs
$if %carbonprice% == "off"      pm_macSwitch(ttot,regi,emiMacMagpie) = 0;
$if %carbonprice% == "NDC"      pm_macSwitch(ttot,regi,emiMacMagpie) = 0;
$if %carbonprice% == "NPi"      pm_macSwitch(ttot,regi,emiMacMagpie) = 0;

*** Load historical carbon prices defined in $/t CO2, need to be rescaled to right unit
pm_taxCO2eq(ttot,regi)$(ttot.val le 2020) = 0;
parameter fm_taxCO2eqHist(ttot,all_regi)       "historic CO2 prices [$/tCO2]"
/
$ondelim
$include "./core/input/pm_taxCO2eqHist.cs4r"
$offdelim
/;
pm_taxCO2eq(ttot,regi)$(ttot.val le 2020) = fm_taxCO2eqHist(ttot,regi) * sm_DptCO2_2_TDpGtC;

*DK* In coupling mode LU emissions are abated in MAgPIE
*** An alternative to the approach below could be to introduce a new value for c_macswitch that only deactivates the LU MACs
if (cm_MAgPIE_Nash eq 1,
  pm_macSwitch(ttot,regi,enty)$emiMacMagpie(enty) = 0;
else 
*** As long as there is hardly any CO2 LUC reduction in MAgPIE we dont need MACs in REMIND
  pm_macSwitch(ttot,regi,"co2luc") = 0;
*** The tiny fraction n2ofertsom of total land use n2o can get slightly negative in some cases. Ignore MAC for n2ofertsom by default.
  pm_macSwitch(ttot,regi,"n2ofertsom") = 0;
);


* GA: Deactivate MAC abatement for historical periods, assuming no abatement
* happens until 2030. 
pm_macSwitch(ttot,regi,enty)$(ttot.val le 2025) = 0;


* GA: Use long term (2050) pm_macSwitch to set p_macCostSwitch, as some MACCs
* are turned off in the short term 
p_macCostSwitch(enty)=pm_macSwitch("2050","USA",enty);
pm_macSwitch(ttot,regi,"co2cement_process") =0 ;
p_macCostSwitch("co2cement_process") =0 ;


*** load econometric emission data
*** read in p3 and p4
parameter p_emineg_econometric(all_regi,all_enty,p)        "parameters for ch4 and n2o emissions from waste baseline and co2 emissions from cement production"
;
p_emineg_econometric(regi,enty,"p1") = 0;
p_emineg_econometric(regi,enty,"p2") = 0;
*** p2 is calculated in presolve

parameter p_macBase2005(all_regi,all_enty)        "baseline emissions of mac options in 2005"
/
$ondelim
$include "./core/input/p_macBase2005.cs4r"
$offdelim
/;
parameter p_macBase1990(all_regi,all_enty)     "baseline emissions of mac options in 1990"
/
$ondelim
$include "./core/input/p_macBase1990.cs4r"
$offdelim
/;
parameter p_macBaseCEDS2005(all_regi,all_enty)        "baseline emissions of mac options in 2005 from CEDS"
/
$ondelim
$include "./core/input/p_macBaseCEDS2005.cs4r"
$offdelim
/;
parameter p_macBaseCEDS2020(all_regi,all_enty)        "baseline emissions of mac options in 2020"
/
$ondelim
$include "./core/input/p_macBaseCEDS2020.cs4r"
$offdelim
/;
parameter p_macBaseIMAGE(tall,all_regi,all_enty)        "baseline emissions of N2O from transport, adipic acid production, and nitric acid production based on data from van Vuuren"
/
$ondelim
$ifthen %cm_emifacs_baseyear% == "2005" 
$include "./core/input/p_macBaseVanv.cs4r"
$else
$include "./core/input/p_macBaseHarmsen2022.cs4r"
$endif
$offdelim
/;

parameter f_macBaseExo(tall,all_regi,all_enty,all_LU_emi_scen)        "baseline emissions of N2O and CH4 from landuse based on exogenous data"
/
$ondelim
$include "./core/input/f_macBaseExo.cs4r"
$offdelim
/;
p_macBaseExo(ttot,regi,emiMacExo(enty))$(ttot.val ge 2005) = f_macBaseExo(ttot,regi,emiMacExo,"%cm_LU_emi_scen%");


parameter f_macBaseMagpie(tall,all_regi,all_enty,all_LU_emi_scen,all_rcp_scen)    "baseline emissions of N2O and CH4 from landuse based on data from Magpie"
/
$ondelim
$include "./core/input/f_macBaseMagpie.cs4r"
$offdelim
/;
pm_macBaseMagpie(ttot,regi,emiMacMagpie(enty))$(ttot.val ge 2005) = f_macBaseMagpie(ttot,regi,emiMacMagpie,"%cm_LU_emi_scen%","%cm_rcp_scen%");

*** pm_macBaseMagpie gets updated in core/presolve.gms when coupling to MAgPIE is active

*** p_macPolCO2luc defines the lower limit for abatement of CO2 landuse change emissions in REMIND
*** The values are derived from MAgPIE runs with very strong mitigation
parameter p_macPolCO2luc(tall,all_regi)                "co2 emissions from landuse change with strong mitigation in MAgPIE"
/
$ondelim
$include "./core/input/p_macPolCO2luc.cs4r"
$offdelim
/;

*** ----- Emission factor of final energy carriers -----------------------------------
*** demand side emission factor of final energy carriers in MtCO2/EJ
*** www.eia.gov/oiaf/1605/excel/Fuel%20EFs_2.xls
p_ef_dem(regi,entyFe) = 0;
p_ef_dem(regi,"fedie") = 69.3;
p_ef_dem(regi,"fehos") = 69.3;
p_ef_dem(regi,"fepet") = 68.5;
p_ef_dem(regi,"fegas") = 50.3;
p_ef_dem(regi,"fegat") = 50.3;
p_ef_dem(regi,"fesos") = 90.5;

$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off"
*** demand side emission factor of final energy carriers in MtCO2/EJ
*** https://www.umweltbundesamt.de/sites/default/files/medien/1968/publikationen/co2_emission_factors_for_fossil_fuels_correction.pdf
  loop(ext_regi$altFeEmiFac_regi(ext_regi),
    p_ef_dem(regi,entyFe)$(regi_group(ext_regi,regi)) = 0;
    p_ef_dem(regi,"fedie")$(regi_group(ext_regi,regi)) = 74;
    p_ef_dem(regi,"fehos")$(regi_group(ext_regi,regi)) = 73;
    p_ef_dem(regi,"fepet")$(regi_group(ext_regi,regi)) = 73;
    p_ef_dem(regi,"fegas")$(regi_group(ext_regi,regi)) = 55;
    p_ef_dem(regi,"fesos")$(regi_group(ext_regi,regi)) = 96;
  );

$endif.altFeEmiFac

pm_emifac(ttot,regi,"segafos","fegas","tdfosgas","co2") = p_ef_dem(regi,"fegas") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"sesofos","fesos","tdfossos","co2") = p_ef_dem(regi,"fesos") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fehos","tdfoshos","co2") = p_ef_dem(regi,"fehos") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fepet","tdfospet","co2") = p_ef_dem(regi,"fepet") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"seliqfos","fedie","tdfosdie","co2") = p_ef_dem(regi,"fedie") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa
pm_emifac(ttot,regi,"segafos","fegat","tdfosgat","co2") = p_ef_dem(regi,"fegas") / (sm_c_2_co2*1000*sm_EJ_2_TWa); !! GtC/TWa

$ifthen.altFeEmiFac not "%cm_altFeEmiFac%" == "off"
*** Changing refineries emission factors in regions that belong to cm_altFeEmiFac to avoid negative emissions on pe2se 
*** (changing from 18.4 to 20 zeta joule = 20/31.7098 = 0.630719841 Twa = 0.630719841 * 3.66666666666666 * 1000 * 0.03171  GtC/TWa = 73.33 GtC/TWa)
loop(ext_regi$altFeEmiFac_regi(ext_regi),
  pm_emifac(ttot,regi,"peoil","seliqfos","refliq","co2")$(regi_group(ext_regi,regi)) = 0.630719841;
);
*** Changing Germany and UKI solids emissions factors to be in line with CRF numbers
*** (changing from 26.1 to 29.27 zeta joule = 0.922937989 TWa = 107.31 GtC/TWa)
pm_emifac(ttot,regi,"pecoal","sesofos","coaltr","co2")$(sameas(regi,"DEU") OR sameas(regi,"UKI")) = 0.922937989;
$endif.altFeEmiFac


***------ Read in emission factors for process emissions in chemicals sector---
*** calculated using IEA data on feedstocks flows and UNFCCC data on chem sector process emissions
*** these emission factors are for the chemical industry only
parameter f_nechem_emissionFactors(ttot,all_regi,*)  "non-energy emission factors [GtC per ZJ]"
/
$ondelim
$include "./core/input/f_nechem_emissionFactors.cs4r"
$offdelim
/;

pm_emifacNonEnergy(ttot,regi,"sesofos", "fesos","indst","co2") = f_nechem_emissionFactors(ttot,regi,"solids")  / s_zj_2_twa;
pm_emifacNonEnergy(ttot,regi,"seliqfos","fehos","indst","co2") = f_nechem_emissionFactors(ttot,regi,"liquids") / s_zj_2_twa;
pm_emifacNonEnergy(ttot,regi,"segafos", "fegas","indst","co2") = f_nechem_emissionFactors(ttot,regi,"gases")   / s_zj_2_twa;

***------ Read in projections for incineration rates of plastic waste---
*** "incineration rates [fraction]"
parameter f_incinerationShares(ttot,all_regi)         "incineration rate of plastic waste"
/
$ondelim
$include "./core/input/f_incinerationShares.cs4r"
$offdelim
/;
pm_incinerationRate(ttot,all_regi)=f_incinerationShares(ttot,all_regi);

*** some balances are not matching by small amounts;
*** the differences are cancelled out here!!!
pm_cesdata(ttot,regi,in,"offset_quantity")$(ttot.val ge 2005)       = 0;

***-----------------------------------------------------------------
*RP* vintages
***-----------------------------------------------------------------
table p_vintage_glob_in(opTimeYr,all_te)         "read-in of global historical vintage structure. Unit: arbitrary (automatic rescaling to 1 in REMIND)"
$include "./core/input/generisdata_vintages.prn"
;

pm_vintage_in(regi,opTimeYr,te) = p_vintage_glob_in(opTimeYr,te);

*RP* 2015-12-09: make sure that all technologies have a pm_vintage_in value > 0 in 2005. If a technology should not be built, this is modeled by
*** setting mix0 = 0, but NOT by setting the vintage value to 0!
*** Setting the vintage value to 0 is error-prone, because it would create an inconsistency between initialcap2 and the calculation of initial 2005 capacities in preloop.
loop(te,
  loop(regi,
    if(pm_vintage_in(regi,"1",te) = 0, pm_vintage_in(regi,"1",te) = 1 )
  );
);



*** ---- FE demand trajectories for calibration -------------------------------
*** also used for limiting secondary steel demand in baseline and policy
*** scenarios
Parameter
f_fedemand(tall,all_regi,all_demScen,all_in)   "final energy demand"
/
$ondelim
$include "./core/input/f_fedemand.cs4r"
$offdelim
/;

*** use cm_demScen for Industry and Buildings
*** cm_GDPpopScen will be used for Transport (EDGE-T) (see p29_trpdemand)
pm_fedemand(tall,all_regi,in) = f_fedemand(tall,all_regi,"%cm_demScen%",in);
*** data input for industry FE that is no part of the CES tree
pm_fedemand(tall,all_regi,ppfen_no_ces_use) = f_fedemand(tall,all_regi,"%cm_demScen%",ppfen_no_ces_use);

*** RCP-dependent demands in buildings (climate impact)
$ifthen.cm_rcp_scen_build not "%cm_rcp_scen_build%" == "none"
Parameter f_fedemand_build(tall,all_regi,all_demScen,all_rcp_scen,all_in) "RCP-dependent final energy demand in buildings"
/
$ondelim
$include "./core/input/f_fedemand_build.cs4r"
$offdelim
/;


pm_fedemand(t,regi,cal_ppf_buildings_dyn36) = f_fedemand_build(t,regi,"%cm_demScen%","%cm_rcp_scen_build%",cal_ppf_buildings_dyn36);
$endif.cm_rcp_scen_build


*** Scale FE demand across industry and building sectors
$ifthen.scaleDemand not "%cm_scaleDemand%" == "off"
  loop((tall,tall2,all_regi) $ pm_scaleDemand(tall,tall2,all_regi),
*FL*  rescaled demand                = normal demand                  * [ scaling factor                      + (1-scaling factor)                      * remaining phase-in, between zero and one               ]
      pm_fedemand(t,all_regi,all_in) = pm_fedemand(t,all_regi,all_in) * ( pm_scaleDemand(tall,tall2,all_regi) + (1-pm_scaleDemand(tall,tall2,all_regi)) * min(1, max(0, tall2.val-t.val) / (tall2.val-tall.val)) );
  );
$endif.scaleDemand


*** initialize absolute deviation of global cumulated CO2 emissions budget from target budget
sm_globalBudget_absDev = 0;


if (cm_startyear gt 2005,
*' load production values from reference gdx to allow penalizing changes vs reference run in the first time step via q_changeProdStartyearCost/q21_taxrevChProdStartYear
execute_load "input_ref.gdx", p_prodSeReference = vm_prodSe.l;
execute_load "input_ref.gdx", pm_prodFEReference = vm_prodFe.l;
execute_load "input_ref.gdx", p_prodUeReference = v_prodUe.l;
execute_load "input_ref.gdx", p_co2CCSReference = vm_co2CCS.l;
*' load MAC costs from reference gdx. Values for t (i.e. after cm_start_year) will be overwritten in core/presolve.gms 
execute_load "input_ref.gdx" pm_macCost;
);

p_prodAllReference(t,regi,te) =
    sum(pe2se(enty,enty2,te),  p_prodSeReference(t,regi,enty,enty2,te) )
  + sum(se2se(enty,enty2,te),  p_prodSeReference(t,regi,enty,enty2,te) )
  + sum(se2fe(enty,enty2,te),  pm_prodFEReference(t,regi,enty,enty2,te) )
  + sum(fe2ue(enty,enty2,te),  p_prodUeReference(t,regi,enty,enty2,te) )
  + sum(ccs2te(enty,enty2,te), sum(teCCS2rlf(te,rlf), p_co2CCSReference(t,regi,enty,enty2,te,rlf) ) )
;

*' initialize vm_changeProdStartyearCost for tax calculation
vm_changeProdStartyearCost.l(t,regi,te) = 0;

*** EOF ./core/datainput.gms
