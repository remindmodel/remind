*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/datainput.gms

*** CO2 tax level is calculated at a 5% exponential increase from the 2020 tax level exogenously defined until 2030, then a linear tax, plus regional convergence
pm_taxCO2eq("2020",regi) = 5;

*** convert tax value from $/t CO2eq to T$/GtC
pm_taxCO2eq("2020",regi)= pm_taxCO2eq("2020",regi) * sm_DptCO2_2_TDpGtC;

*** set ETS price in 2015 for EUR
pm_taxCO2eq("2015",regi)= 0;
pm_taxCO2eq("2015",regi)$regi_group("EUR_regi",regi)= 5 * sm_DptCO2_2_TDpGtC;

*** parameters for exponential increase after NDC targets
Scalar p45_taxCO2eq_convergence_year "year until which CO2eq taxes have converged globally" /2100/;
Scalar p45_taxCO2eq_global2030 "startprice in 2030 (unit TDpGtC) of global CO2eq taxes towards which countries converge";
p45_taxCO2eq_global2030 = 30 * sm_DptCO2_2_TDpGtC;

*** load NDC data
Table f45_factor_targetyear(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/f45_factor_targetyear.cs3r"
$offdelim
$onlisting
;

Parameter p45_factor_targetyear(ttot,all_regi) "Multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region";
p45_factor_targetyear(ttot,all_regi) = f45_factor_targetyear(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p45_factor_targetyear;

Table f45_2005share_target(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with 2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/f45_2005share_target.cs3r"
$offdelim
$onlisting
;

Parameter p45_2005share_target(ttot,all_regi) "2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years";
p45_2005share_target(ttot,all_regi) = f45_2005share_target(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p45_2005share_target;

Table f45_hist_share(tall,all_regi,NDC_version) "Table for all NDC versions with GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record"
$offlisting
$ondelim
$include "./modules/45_carbonprice/NDC/input/f45_hist_share.cs3r"
$offdelim
$onlisting
;

Parameter p45_hist_share(tall,all_regi) "GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record";
p45_hist_share(tall,all_regi) = f45_hist_share(tall,all_regi,"%cm_NDC_version%");

display p45_hist_share;

Parameter p45_BAU_reg_emi_wo_LU_bunkers(ttot,all_regi) "regional GHG emissions (without LU and bunkers) in BAU scenario"
  /
$ondelim
$include "./modules/45_carbonprice/NDC/input/p45_BAU_reg_emi_wo_LU_bunkers.cs4r"
$offdelim
  /             ;

*** parameters for selecting NDC years
Scalar p45_ignore_NDC_before             "NDC targets before this years are ignored, for example to exclude 2030 targets" /2020/;
Scalar p45_ignore_NDC_after              "NDC targets after  this years are ignored, for example to exclude 2050 net zero targets" /2030/;
Scalar p45_min_ratio_of_coverage_to_max  "only targets whose coverage is this times p45_best_NDC_coverage are considered. Use 1 for only best." /1.0/;
Scalar p45_use_single_year_close_to      "if 0: use all. If > 0: use only one single NDC target per country closest to this year (use 2030.4 to prefer 2030 over 2035 over 2025)" /2030.4/;

Set p45_NDC_year_set(ttot,all_regi)               "YES for years whose NDC targets is used";
Parameter p45_best_NDC_coverage(all_regi)         "highest coverage of NDC targets within region";
Parameter p45_distance_to_optyear(ttot,all_regi)  "distance to p45_use_single_year_close_to to favor years in case of multiple equally good targets";
Parameter p45_min_distance_to_optyear(all_regi)   "minimal distance to p45_use_single_year_close_to per region";

p45_best_NDC_coverage(regi) = smax(ttot$(ttot.val <= p45_ignore_NDC_after AND ttot.val >= p45_ignore_NDC_before), p45_2005share_target(ttot,regi));
display p45_best_NDC_coverage;

p45_NDC_year_set(ttot,regi)$(ttot.val <= p45_ignore_NDC_after AND ttot.val >= p45_ignore_NDC_before) = p45_2005share_target(ttot,regi) >= p45_min_ratio_of_coverage_to_max * p45_best_NDC_coverage(regi);

if(p45_use_single_year_close_to > 0,
  p45_distance_to_optyear(p45_NDC_year_set(ttot,regi)) = abs(ttot.val - p45_use_single_year_close_to);
  p45_min_distance_to_optyear(regi) = smin(ttot$(p45_NDC_year_set(ttot,regi)), p45_distance_to_optyear(ttot,regi));
  p45_NDC_year_set(ttot,regi) = p45_distance_to_optyear(ttot,regi) = p45_min_distance_to_optyear(regi);
);

*** first and last NDC year as a number
Parameter p45_first_NDC_year(all_regi) "last year with NDC coverage within region";
p45_first_NDC_year(regi) = smin( p45_NDC_year_set(ttot, regi), ttot.val );
Parameter p45_last_NDC_year(all_regi)  "last year with NDC coverage within region";
p45_last_NDC_year(regi)  = smax( p45_NDC_year_set(ttot, regi), ttot.val );

display p45_NDC_year_set,p45_first_NDC_year,p45_last_NDC_year;

*** adjust reduction value for LAM based on the assumption that Brazilian reduction targets are only from landuse, see https://climateactiontracker.org/countries/brazil/
*** the adjustment were calculated such that Brazil is assumed to maintain its 2015 non-landuse emissions, as follows:
*** Use R and the code in https://github.com/pik-piam/mrremind/blob/master/R/calcEmiTarget.R to calculate dummy1, ghgTarget, ghgfactor, then run the following code:
*** countries <- toolGetMapping("regionmappingREMIND.csv",where = "mappingfolder",type = "regional")
*** LAMCountries <- countries$CountryCode[countries$RegionCode == "LAM"]
*** shareWithinTargetCountries <- dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030",] / dimSums(dummy1[LAMCountries,"y2030",] * ghgTarget[LAMCountries,"y2030", ], dim=1)
*** print(shareWithinTargetCountries["BRA",,]*(as.numeric(ghg["BRA","y2015"])/as.numeric(ghg["BRA","y2005"])-as.numeric(ghgfactor["BRA","y2030","gdp_SSP2"])))
*** 0.2 is a rounded value valid for all except 2018_uncond, because Brazil had no unconditional target then.

if (not sameas("%cm_NDC_version%","2018_uncond"),
    p45_factor_targetyear(ttot,regi)$(sameas(regi,"LAM") AND sameas(ttot,"2030")) = p45_factor_targetyear(ttot,regi) + 0.2;
);

*** EOF ./modules/45_carbonprice/NDC/datainput.gms
