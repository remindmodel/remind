*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/simple/datainput.gms

*** substitution elasticities
Parameter 
  p36_cesdata_sigma(all_in)  "substitution elasticities in buildings"
  /
    enb    0.5
    enhb   3.0
    enhgab 5.0
  /
;
pm_cesdata_sigma(ttot,in)$p36_cesdata_sigma(in) = p36_cesdata_sigma(in);

*** increase elasticities of subsitution over time to account for ramp-up requirements of new technologies in the short-term
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enb")) = 0.1;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enb")) = 0.3;

pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) le 2025  AND sameAs(in, "enhb")) = 0.5;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2030  AND sameAs(in, "enhb")) = 0.7;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2035  AND sameAs(in, "enhb")) = 1.3;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2040  AND sameAs(in, "enhb")) = 2.0;
pm_cesdata_sigma(ttot,in)$ (pm_ttot_val(ttot) eq 2045  AND sameAs(in, "enhb")) = 2.5;

pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val le 2020) = 0.1;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2025) = 0.6;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2030) = 1.2;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2035) = 2;
pm_cesdata_sigma(ttot,"enhgab")$ (ttot.val eq 2040) = 3;


*** floor space demand for reporting
Parameter
p36_floorspace_scen(tall, all_regi, all_demScen) "floorspace, in buildings simple realization only used for reporting at the moment, not in optimization itself"
/
$ondelim
$include "./modules/36_buildings/simple/input/p36_floorspace_scen.cs4r"
$offdelim
/
;
p36_floorspace(ttot,regi) = p36_floorspace_scen(ttot,regi,"%cm_demScen%") * 1e-3; !! from million to billion m2


*** UE demand for reporting
Parameter
f36_uedemand_build(tall,all_regi,all_demScen,all_rcp_scen,all_in)   "useful energy demand in buildings"
/
$ondelim
$include "./modules/36_buildings/simple/input/f36_uedemand_build.cs4r"
$offdelim
/
;
p36_uedemand_build(ttot,regi,in) = f36_uedemand_build(ttot,regi,"%cm_demScen%","%cm_rcp_scen_build%",in);


*** scale default elasticity of substitution on enb level
$IFTHEN.cm_enb not "%cm_enb%" == "off" 
  pm_cesdata_sigma(ttot,"enb")$pm_cesdata_sigma(ttot,"enb") =
    pm_cesdata_sigma(ttot,"enb") * %cm_enb%;
  pm_cesdata_sigma(ttot,"enb")$(pm_cesdata_sigma(ttot,"enb") gt 0.8
                                AND pm_cesdata_sigma(ttot,"enb") lt 1) =
    0.8; !! If complementary factors, sigma should be below 0.8
  pm_cesdata_sigma(ttot,"enb")$(pm_cesdata_sigma(ttot,"enb") ge 1
                                AND pm_cesdata_sigma(ttot,"enb") lt 1.2) =
    1.2; !! If substitution factors, sigma should be above 1.2
$ENDIF.cm_enb


***-----------------------------------------------------------------------------
* FE Share Bounds
***-----------------------------------------------------------------------------

* intialize buildings FE share bounds as non-activated
pm_shfe_up(ttot,regi,entyFe,"build") = 0;
pm_shfe_lo(ttot,regi,entyFe,"build") = 0;
pm_shGasLiq_fe_up(ttot,regi,"build") = 0;
pm_shGasLiq_fe_lo(ttot,regi,"build") = 0;

* RR: lower bound for gases and liquids share in buildings for an incumbents scenario
$ifthen.feShareScenario "%cm_feShareLimits%" == "incumbents"
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2050) = 0.25;
  pm_shGasLiq_fe_lo(t,regi,"build")$(t.val ge 2030 AND t.val le 2045) = 
    0.15 + (0.10 / 20) * (t.val - 2030);
$endif.feShareScenario

***-----------------------------------------------------------------------------
*` CES mark-up cost buildings
***-----------------------------------------------------------------------------

*` The Mark-up cost on primary production factors (final energy) of the CES tree have two functions. 
*` (1) They represent sectoral end-use cost not captured by the energy system. 
*` (2) As they alter prices to of the CES function inputs, they affect the CES efficiency parameters during calibration 
*` and therefore influence the efficiency of different FE CES inputs. The resulting economic subsitution rates
*` are given by the marginal rate of subsitution (MRS) in the parameter o01_CESmrs.

*` There are two types of CES mark-up cost:
*` (a) Mark-up cost on inputs in ppfen_MkupCost37: Those are counted as expenses in the budget and set by the parameter p37_CESMkup. 
*` (b) Mark-up cost on other inputs: Those are budget-neutral and implemented as a tax. They are set by the parameter pm_tau_ces_tax. 

*` Mark-up cost in buildings are modeled with budget-effect (a).

*` default values of CES mark-up with budget effect:
p36_CESMkup(t,regi,in) = 0;
*` mark-up cost on heat pumps and district heating are incurred as actual cost to the budget (see option (a) above)
*` place markup cost on heat pumps electricity of 200 USD/MWh(el) to represent demand-side cost of electrification
*` and reach higher efficiency during calibration to model higher energy efficiency of heat pumps
p36_CESMkup(t,regi,"feelhpb") = 200 * sm_TWa_2_MWh * 1e-12;
*` place markup cost on district heating of 25 USD/MWh(heat) to represent additional t&d cost of expanding district heating networks for buildings
*` which makes district heating in buildings more expensive than in industry
p36_CESMkup(t,regi,"feheb") = 25 * sm_TWa_2_MWh * 1e-12;

*` overwrite or extent CES markup cost if specified by switch
$ifThen.CESMkup not "%cm_CESMkup_build%" == "standard"
  p36_CESMkup(t,regi,in)$(p36_CESMkup_input(in)
                          AND ppfen_MkupCost36(in)) =
    p36_CESMkup_input(in);
  pm_tau_ces_tax(t,regi,in)$(p36_CESMkup_input(in)
                             AND (NOT ppfen_MkupCost36(in))) =
    p36_CESMkup_input(in);
$endIf.CESMkup

display p36_CESMkup;
display pm_tau_ces_tax;

*** EOF ./modules/36_buildings/simple/datainput.gms
