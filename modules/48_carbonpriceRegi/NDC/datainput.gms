*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/datainput.gms

*** parameters for exponential increase after NDC targets
Scalar p48_taxCO2eqConvergenceYear "year until which CO2eq taxes have converged globally" /2100/;
Scalar p48_taxCO2eqGlobal2030 "startprice in 2030 (unit TDpGtC) of global CO2eq taxes towards which countries converge";
p48_taxCO2eqGlobal2030 = 0 * sm_DptCO2_2_TDpGtC;
Scalar p48_taxCO2eqYearlyIncrease "yearly multiplicative increase of co2 tax, write 3% as 1.03" /1/;

*** load NDC data
Table f48_factorTargetyear(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/fm_factorTargetyear.cs3r"
$offdelim
$onlisting
;

Parameter p48_factorTargetyear(ttot,all_regi) "Multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region";
p48_factorTargetyear(ttot,all_regi) = f48_factorTargetyear(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p48_factorTargetyear;

Table f48_2005shareTarget(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with 2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/fm_2005shareTarget.cs3r"
$offdelim
$onlisting
;

Parameter p48_2005shareTarget(ttot,all_regi) "2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years";
p48_2005shareTarget(ttot,all_regi) = f48_2005shareTarget(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p48_2005shareTarget;

Table f48_histShare(tall,all_regi,NDC_version) "Table for all NDC versions with GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/fm_histShare.cs3r"
$offdelim
$onlisting
;

Parameter p48_histShare(tall,all_regi) "GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record";
p48_histShare(tall,all_regi) = f48_histShare(tall,all_regi,"%cm_NDC_version%");

display p48_histShare;

Parameter p48_BAU_reg_emi_wo_LU_bunkers(ttot,all_regi) "regional GHG emissions (without LU and bunkers) in BAU scenario"
  /
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/pm_BAU_reg_emi_wo_LU_bunkers.cs4r"
$offdelim
  /             ;

*** adjust reduction value for LAM based on the assumption that Brazilian reduction targets are only from landuse, see https://climateactiontracker.org/countries/brazil/
*** the adjustment were calculated such that Brazil is assumed to maintain its 2015 non-landuse emissions, as follows:
*** Use R and the code in https://github.com/pik-piam/mrremind/blob/master/R/calcEmiTarget.R to calculate dummy1, ghgTarget, ghgfactor, then run the following code:
*** countries <- toolGetMapping("regionmappingREMIND.csv",where = "mappingfolder",type = "regional")
*** LAMCountries <- countries$CountryCode[countries$RegionCode == "LAM"]
*** shareWithinTargetCountries <- dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030",] / dimSums(dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030", ], dim=1)
*** print(shareWithinTargetCountries["BRA",,]*(as.numeric(ghg["BRA","y2015"])/as.numeric(ghg["BRA","y2005"])-as.numeric(ghgfactor["BRA","y2030","gdp_SSP2"])))
*** 0.2 is a rounded value valid for all except 2018_uncond, because Brazil had no unconditional target then.

if (not sameas("%cm_NDC_version%","2018_uncond"),
    p48_factorTargetyear(ttot,regi)$(sameas(regi,"LAM") AND sameas(ttot,"2030")) = p48_factorTargetyear(ttot,regi) + 0.2;
);

*** add 2060 net zero target for China, not yet in the UNFCCC_NDC database
p48_factorTargetyear(ttot,regi)$(sameas(regi,"CHA") AND sameas(ttot,"2060")) = 0;
p48_2005shareTarget(ttot,regi)$(sameas(regi,"CHA") AND sameas(ttot,"2060")) = 1;


*** parameters for selecting NDC years
Scalar p48_ignoreNDCbefore          "NDC targets before this years are ignored, for example to exclude 2030 targets" /2028/;
Scalar p48_ignoreNDCafter           "NDC targets after  this years are ignored, for example to exclude 2050 net zero targets" /2070/;
Scalar p48_minRatioOfCoverageToMax  "only targets whose coverage is this times p48_bestNDCcoverage are considered. Use 1 for only best." /0.2/;
Scalar p48_useSingleYearCloseTo     "if 0: use all. If > 0: use only one single NDC target per country closest to this year (use 2030.4 to prefer 2030 over 2035 over 2025)" /0/;

Set p48_NDCyearSet(ttot,all_regi)               "YES for years whose NDC targets is used";
Parameter p48_bestNDCcoverage(all_regi)         "highest coverage of NDC targets within region";
Parameter p48_distanceToOptyear(ttot,all_regi)  "distance to p48_useSingleYearCloseTo to favor years in case of multiple equally good targets";
Parameter p48_minDistanceToOptyear(all_regi)    "minimal distance to p48_useSingleYearCloseTo per region";

p48_bestNDCcoverage(regi) = smax(ttot$(ttot.val <= p48_ignoreNDCafter AND ttot.val >= p48_ignoreNDCbefore), p48_2005shareTarget(ttot,regi));
display p48_bestNDCcoverage;

p48_NDCyearSet(ttot,regi)$(ttot.val <= p48_ignoreNDCafter AND ttot.val >= p48_ignoreNDCbefore) = p48_2005shareTarget(ttot,regi) >= p48_minRatioOfCoverageToMax * p48_bestNDCcoverage(regi);

if(p48_useSingleYearCloseTo > 0,
  p48_distanceToOptyear(p48_NDCyearSet(ttot,regi)) = abs(ttot.val - p48_useSingleYearCloseTo);
  p48_minDistanceToOptyear(regi) = smin(ttot$(p48_NDCyearSet(ttot,regi)), p48_distanceToOptyear(ttot,regi));
  p48_NDCyearSet(ttot,regi) = p48_distanceToOptyear(ttot,regi) = p48_minDistanceToOptyear(regi);
);

*** first and last NDC year as a number
Parameter p48_firstNDCyear(all_regi) "last year with NDC coverage within region";
p48_firstNDCyear(regi) = smin( p48_NDCyearSet(ttot, regi), ttot.val );
Parameter p48_lastNDCyear(all_regi)  "last year with NDC coverage within region";
p48_lastNDCyear(regi)  = smax( p48_NDCyearSet(ttot, regi), ttot.val );

display p48_NDCyearSet,p48_firstNDCyear,p48_lastNDCyear;

***initialize parameter
p48_taxCO2eqLast(t,regi) = 0;

*** EOF ./modules/48_carbonpriceRegi/NDC/datainput.gms
