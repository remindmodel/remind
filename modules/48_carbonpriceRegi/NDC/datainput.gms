*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/48_carbonpriceRegi/NDC/datainput.gms

*** parameters for exponential increase after NDC targets
Scalar p48_taxCO2eq_convergence_year "year until which CO2eq taxes have converged globally" /2100/;
Scalar p48_taxCO2eq_global2030 "startprice in 2030 (unit TDpGtC) of global CO2eq taxes towards which countries converge";
p48_taxCO2eq_global2030 = 0 * sm_DptCO2_2_TDpGtC;
Scalar p48_taxCO2eq_yearly_increase "yearly multiplicative increase of co2 tax, write 3% as 1.03" /1/;

*** load NDC data
Table f48_factor_targetyear(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/f45_factor_targetyear.cs3r"
$offdelim
$onlisting
;

Parameter p48_factor_targetyear(ttot,all_regi) "Multiplier for target year emissions vs 2005 emissions, as weighted average for all countries with quantifyable emissions under NDC in particular region";
p48_factor_targetyear(ttot,all_regi) = f48_factor_targetyear(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p48_factor_targetyear;

Table f48_2005share_target(ttot,all_regi,NDC_version,all_GDPscen) "Table for all NDC versions with 2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/f45_2005share_target.cs3r"
$offdelim
$onlisting
;

Parameter p48_2005share_target(ttot,all_regi) "2005 GHG emission share of countries with quantifyable emissions under NDC in particular region, time dimension specifies alternative future target years";
p48_2005share_target(ttot,all_regi) = f48_2005share_target(ttot,all_regi,"%cm_NDC_version%","%cm_GDPscen%");

display p48_2005share_target;

Table f48_hist_share(tall,all_regi,NDC_version) "Table for all NDC versions with GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record"
$offlisting
$ondelim
$include "./modules/48_carbonpriceRegi/NDC/input/f45_hist_share.cs3r"
$offdelim
$onlisting
;

Parameter p48_hist_share(tall,all_regi) "GHG emissions share of countries with quantifyable 2030 target, time dimension specifies historic record";
p48_hist_share(tall,all_regi) = f48_hist_share(tall,all_regi,"%cm_NDC_version%");

display p48_hist_share;

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
    p48_factor_targetyear(ttot,regi)$(sameas(regi,"LAM") AND sameas(ttot,"2030")) = p48_factor_targetyear(ttot,regi) + 0.2;
);

*** add 2060 net zero target for China, not yet in the UNFCCC_NDC database
p48_factor_targetyear(ttot,regi)$(sameas(regi,"CHA") AND sameas(ttot,"2060")) = 0;
p48_2005share_target(ttot,regi)$(sameas(regi,"CHA") AND sameas(ttot,"2060")) = 1;


*** parameters for selecting NDC years
Scalar p48_ignore_NDC_before             "NDC targets before this years are ignored, for example to exclude 2030 targets" /2050/;
Scalar p48_ignore_NDC_after              "NDC targets after  this years are ignored, for example to exclude 2050 net zero targets" /2070/;
Scalar p48_min_ratio_of_coverage_to_max  "only targets whose coverage is this times p48_best_NDC_coverage are considered. Use 1 for only best." /1.0/;
Scalar p48_use_single_year_close_to      "if 0: use all. If > 0: use only one single NDC target per country closest to this year (use 2030.4 to prefer 2030 over 2035 over 2025)" /2050.4/;

Set p48_NDC_year_set(ttot,all_regi)               "YES for years whose NDC targets is used";
Parameter p48_best_NDC_coverage(all_regi)         "highest coverage of NDC targets within region";
Parameter p48_distance_to_optyear(ttot,all_regi)  "distance to p48_use_single_year_close_to to favor years in case of multiple equally good targets";
Parameter p48_min_distance_to_optyear(all_regi)   "minimal distance to p48_use_single_year_close_to per region";

p48_best_NDC_coverage(regi) = smax(ttot$(ttot.val <= p48_ignore_NDC_after AND ttot.val >= p48_ignore_NDC_before), p48_2005share_target(ttot,regi));
display p48_best_NDC_coverage;

p48_NDC_year_set(ttot,regi)$(ttot.val <= p48_ignore_NDC_after AND ttot.val >= p48_ignore_NDC_before) = p48_2005share_target(ttot,regi) >= p48_min_ratio_of_coverage_to_max * p48_best_NDC_coverage(regi);

if(p48_use_single_year_close_to > 0,
  p48_distance_to_optyear(p48_NDC_year_set(ttot,regi)) = abs(ttot.val - p48_use_single_year_close_to);
  p48_min_distance_to_optyear(regi) = smin(ttot$(p48_NDC_year_set(ttot,regi)), p48_distance_to_optyear(ttot,regi));
  p48_NDC_year_set(ttot,regi) = p48_distance_to_optyear(ttot,regi) = p48_min_distance_to_optyear(regi);
);

*** first and last NDC year as a number
Parameter p48_first_NDC_year(all_regi) "last year with NDC coverage within region";
p48_first_NDC_year(regi) = smin( p48_NDC_year_set(ttot, regi), ttot.val );
Parameter p48_last_NDC_year(all_regi)  "last year with NDC coverage within region";
p48_last_NDC_year(regi)  = smax( p48_NDC_year_set(ttot, regi), ttot.val );

display p48_NDC_year_set,p48_first_NDC_year,p48_last_NDC_year;

*** EOF ./modules/48_carbonpriceRegi/NDC/datainput.gms
