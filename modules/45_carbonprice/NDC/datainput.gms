*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/datainput.gms

*** CO2 tax level from business as usual run, serves as minimal tax in NDC
Execute_Loadpoint "input_ref" p45_taxCO2eq_bau = pm_taxCO2eq;

pm_taxCO2eq(t,regi) = p45_taxCO2eq_bau(t,regi)

*** parameters for exponential increase after NDC targets
Scalar p45_taxCO2eqGlobal2030 "startprice in 2030 of global CO2eq taxes towards which countries converge [T$/GtC]";
p45_taxCO2eqGlobal2030 = 30 * sm_D2005_2_D2017 * sm_DptCO2_2_TDpGtC;
Scalar p45_taxCO2eqYearlyIncrease "yearly multiplicative increase of co2 tax, write 3% as 1.03 [1]" /1.0125/;

Scalar p45_taxCO2eqConvergenceYear "year until which CO2eq taxes have converged globally [year]" /2100/;
*** set Years for CO2eq taxes to converge after 2030
if(cm_NDC_divergentScenario = 0,
    p45_taxCO2eqConvergenceYear = 2100;
elseif cm_NDC_divergentScenario = 1,
    p45_taxCO2eqConvergenceYear = 2150;
elseif cm_NDC_divergentScenario = 2,
    p45_taxCO2eqConvergenceYear = 3000;
);

*** load NDC data
Table f45_factorTargetyear(tall,all_regi,NDC_version,all_GDPpopScen) "Table for all NDC versions with multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region [1]"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/fm_factorTargetyear.cs3r"
$offdelim
$onlisting
;

Parameter p45_factorTargetyear(ttot,all_regi) "Multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region [1]";
p45_factorTargetyear(t,all_regi) = f45_factorTargetyear(t,all_regi,"%cm_NDC_version%","%cm_GDPpopScen%");

display p45_factorTargetyear;

Table f45_2005shareTarget(tall,all_regi,NDC_version,all_GDPpopScen) "Table for all NDC versions with 2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years [0..1]"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/fm_2005shareTarget.cs3r"
$offdelim
$onlisting
;

Parameter p45_2005shareTarget(ttot,all_regi) "2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years [0..1]";
p45_2005shareTarget(t,all_regi) = f45_2005shareTarget(t,all_regi,"%cm_NDC_version%","%cm_GDPpopScen%");

display p45_2005shareTarget;

Parameter p45_BAU_reg_emi_wo_LU_bunkers(ttot,all_regi) "regional GHG emissions (without LU and bunkers) in BAU scenario [MtCO2eq/yr]"
  /
$ondelim
$ifthen exist "./modules/45_carbonprice/NDC/input/pm_BAU_reg_emi_wo_LU_bunkers.cs4r"
$include "./modules/45_carbonprice/NDC/input/pm_BAU_reg_emi_wo_LU_bunkers.cs4r"
$endif
$offdelim
  /             ;

*** parameters for selecting NDC years
Scalar p45_ignoreNDCbefore          "NDC targets before this years are ignored, for example to exclude 2030 targets [year]" /2024/;
p45_ignoreNDCbefore = max(p45_ignoreNDCbefore, cm_startyear)
Scalar p45_ignoreNDCafter           "NDC targets after  this years are ignored, for example to exclude 2050 net zero targets [year]" /2030/;
Scalar p45_minRatioOfCoverageToMax  "only targets whose coverage is this times p45_bestNDCcoverage are considered. Use 1 for only best [0..1]" /1.0/;
Scalar p45_useSingleYearCloseTo     "if 0: use all. If > 0: use only one single NDC target per country closest to this year (use 2030.4 to prefer 2030 over 2035 over 2025) [year]" /2030.4/;

Set p45_NDCyearSet(ttot,all_regi)                 "YES for years whose NDC targets is used";
Parameter p45_bestNDCcoverage(all_regi)        "highest coverage of NDC targets within region [0..1]";
Parameter p45_distanceToOptyear(ttot,all_regi)    "distance to p45_useSingleYearCloseTo to favor years in case of multiple equally good targets [year]";
Parameter p45_minDistanceToOptyear(all_regi)   "minimal distance to p45_useSingleYearCloseTo per region [year]";

p45_bestNDCcoverage(regi) = smax(t$(t.val <= p45_ignoreNDCafter AND t.val >= p45_ignoreNDCbefore), p45_2005shareTarget(t,regi));
display p45_bestNDCcoverage;

p45_NDCyearSet(t,regi)$(t.val <= p45_ignoreNDCafter AND t.val >= p45_ignoreNDCbefore) = p45_2005shareTarget(t,regi) >= p45_minRatioOfCoverageToMax * p45_bestNDCcoverage(regi);

if(p45_useSingleYearCloseTo > 0,
  p45_distanceToOptyear(p45_NDCyearSet(t,regi)) = abs(t.val - p45_useSingleYearCloseTo);
  p45_minDistanceToOptyear(regi) = smin(t$(p45_NDCyearSet(t,regi)), p45_distanceToOptyear(t,regi));
  p45_NDCyearSet(t,regi) = p45_distanceToOptyear(t,regi) = p45_minDistanceToOptyear(regi);
);

*** first and last NDC year as a number
Parameter p45_firstNDCyear(all_regi) "last year with NDC coverage within region [year]";
p45_firstNDCyear(regi) = smin( p45_NDCyearSet(t, regi), t.val );
Parameter p45_lastNDCyear(all_regi)  "last year with NDC coverage within region [year]";
p45_lastNDCyear(regi)  = smax( p45_NDCyearSet(t, regi), t.val );

display p45_NDCyearSet,p45_firstNDCyear,p45_lastNDCyear;

*** adjust reduction value for LAM based on the assumption that Brazilian reduction targets are only from landuse, see https://climateactiontracker.org/countries/brazil/
*** the adjustment were calculated such that Brazil is assumed to maintain its 2015 non-landuse emissions, as follows:
*** Use R and the code in https://github.com/pik-piam/mrremind/blob/master/R/calcEmiTarget.R to calculate dummy1, ghgTarget, ghgfactor, then run the following code:
*** countries <- toolGetMapping("regionmappingREMIND.csv",where = "mappingfolder",type = "regional")
*** LAMCountries <- countries$CountryCode[countries$RegionCode == "LAM"]
*** shareWithinTargetCountries <- dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030",] / dimSums(dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030", ], dim=1)
*** print(shareWithinTargetCountries["BRA",,]*(as.numeric(ghg["BRA","y2015"])/as.numeric(ghg["BRA","y2005"])-as.numeric(ghgfactor["BRA","y2030","SSP2"])))
*** 0.2 is a rounded value valid for all except 2018_uncond, because Brazil had no unconditional target then.

if (not sameas("%cm_NDC_version%","2018_uncond"),
    p45_factorTargetyear(t,regi)$(sameas(regi,"LAM") AND sameas(t,"2030")) = p45_factorTargetyear(t,regi) + 0.2;
);

*** EOF ./modules/45_carbonprice/NDC/datainput.gms
