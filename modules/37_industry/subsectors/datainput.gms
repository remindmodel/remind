*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/datainput.gms

vm_emiIndBase.l(ttot,regi,entyFe,secInd37) = 0;

Parameters

*** ---------------------------------------------------------------------------
***        1. CES-Based
*** ---------------------------------------------------------------------------
*** substitution elasticities
  p37_cesdata_sigma(all_in)  "industry substitution elasticities"
  /
    ue_industry                      0.5   !! cement - chemicals - steel - other

      ue_cement                      1.7   !! energy, capital
        en_cement                    0.3   !! non-electric, electric
          en_cement_non_electric     2.0   !! solids, liquids, gases, hydrogen

      ue_chemicals                   1.7   !! energy, capital
        en_chemicals                 0.3   !! fuels and high-temperature heat, electricity
          en_chemicals_fhth          3.0   !! solids, liquids, gases, electricity

      ue_steel                       5     !! primary steel, secondary steel
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
        ue_steel_primary             1.7   !! energy, capital
          en_steel_primary           0.3   !! furnace, electricity
            en_steel_furnace         2.0   !! solids, liquids, gases, hydrogen
        ue_steel_secondary           1.7   !! energy, capital
$endif.cm_subsec_model_steel

      ue_otherInd                    1.7   !! energy, capital
        en_otherInd                  0.3   !! high-temperature heat, electricity
          en_otherInd_hth            2.0   !! solids, liquids, gases, hydrogen, heat
  /
;
pm_cesdata_sigma(ttot,in)$( p37_cesdata_sigma(in) ) = p37_cesdata_sigma(in);


*** increase elasticities of subsitution over time to account for ramp-up requirements of new technologies in the short-term
pm_cesdata_sigma(ttot,"en_cement_non_electric")$ (ttot.val le 2025) = 0.7;
pm_cesdata_sigma(ttot,"en_cement_non_electric")$ (ttot.val eq 2030) = 1.3;
pm_cesdata_sigma(ttot,"en_cement_non_electric")$ (ttot.val eq 2035) = 1.7;
pm_cesdata_sigma(ttot,"en_cement_non_electric")$ (ttot.val eq 2040) = 2.0;

pm_cesdata_sigma(ttot,"en_chemicals_fhth")$ (ttot.val le 2025) = 0.7;
pm_cesdata_sigma(ttot,"en_chemicals_fhth")$ (ttot.val eq 2030) = 1.3;
pm_cesdata_sigma(ttot,"en_chemicals_fhth")$ (ttot.val eq 2035) = 2.0;
pm_cesdata_sigma(ttot,"en_chemicals_fhth")$ (ttot.val eq 2040) = 3.0;

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val le 2025) = 0.5;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2030) = 0.7;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2035) = 1.3;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2040) = 2.0;
$endif.cm_subsec_model_steel

pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val le 2025) = 0.7;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2030) = 1.3;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2035) = 1.7;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2040) = 2.0;

*** abatement parameters for industry CCS MACs
$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,

    emiMac2mac("co2cement_process","co2cement") = YES;
     );
   );

*** assume 50 year lifetime for industry energy efficiency capital
pm_delta_kap(regi,ppfKap_industry_dyn37) = -log(1 / 4) / 50;

* Thermodynamic limits on subsector FE demand
Parameter
  pm_energy_limit(all_in)   "thermodynamic/technical limits of subsector energy use [GJ/t product]"
  /
$ondelim
$include "./modules/37_industry/subsectors/input/pm_energy_limit.csv";
$offdelim
  /
;

pm_energy_limit(in)
  = pm_energy_limit(in)   !! GJ/t
  * 1e-3                   !! * TJ/GJ
  / (8760 * 3600)          !! * s/year
  * 1e9;                   !! * t/Gt
                           !! = TWa/Gt

* remove energy limit for process-based materials
pm_energy_limit(out)$(NOT sum(in, ces_eff_target_dyn37(out,in))) = 0.;


* Specific energy demand cannot fall below a curve described by an exponential
* function passing through the 2015 value and a point defined by an "efficiency
* gain" (e.g. 75 %) between baseline value and thermodynamic limit at a given
* year (e.g. 2050).
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
if (cm_startyear eq 2005,
  execute_loadpoint "input.gdx"     p37_cesIO_baseline = vm_cesIO.l;
else
  execute_loadpoint "input_ref.gdx" p37_cesIO_baseline = vm_cesIO.l;
);

sm_tmp2 = 0.75;   !! maximum "efficiency gain", from 2015 baseline value to
                  !! thermodynamic limit
sm_tmp  = 2050;   !! period in which closing could be achieved

*** Specific energy demand limits for steel and cement relative to thermodynamic limit from input data
loop (industry_ue_calibration_target_dyn37(out)$( pm_energy_limit(out) ),
  p37_energy_limit_slope(ttot,regi,out)$( ttot.val ge 2015 )
  = ( ( sum(ces_eff_target_dyn37(out,in), p37_cesIO_baseline("2015",regi,in))
      / p37_cesIO_baseline("2015",regi,out)
      )
    - pm_energy_limit(out)
    )
  * exp((2015 - ttot.val) / ((2015 - sm_tmp) / log(1 - sm_tmp2)))
  + pm_energy_limit(out);

  !! To account for strong 2015-20 drops due to imperfect 2020 energy data,
  !! use the lower of the calculated curve, or 95 % of the baseline specific
  !! energy demand
  p37_energy_limit_slope(ttot,regi,out)$( ttot.val ge 2015 )
  = min(
      p37_energy_limit_slope(ttot,regi,out),
      ( 0.95
      * ( sum(ces_eff_target_dyn37(out,in), p37_cesIO_baseline(ttot,regi,in))
        / p37_cesIO_baseline(ttot,regi,out)
	)
      )
    );
);

*** Specific energy demand limits for other industry and chemicals in TWa/trUSD
*** exponential decrease of minimum specific energy demand per value added up to 90% by 2100
sm_tmp2 = 0.9;   !! maximum "efficiency gain" relative to 2015 baseline value
sm_tmp  = 2100;   !! period in which closing could be achieved

loop (industry_ue_calibration_target_dyn37(out)$( sameas(out,"ue_chemicals") OR  sameas(out,"ue_otherInd")),
  p37_energy_limit_slope(ttot,regi,out)$( ttot.val ge 2015 )
  = ( ( sum(ces_eff_target_dyn37(out,in), p37_cesIO_baseline("2015",regi,in))
      / p37_cesIO_baseline("2015",regi,out)
      )
    )
  * exp((2015 - ttot.val) / ((2015 - sm_tmp) / log(1 - sm_tmp2)));

  !! To account for strong 2015-20 drops due to imperfect 2020 energy data,
  !! use the lower of the calculated curve, or 95 % of the baseline specific
  !! energy demand
  p37_energy_limit_slope(ttot,regi,out)$( ttot.val ge 2015 )
  = min(
      p37_energy_limit_slope(ttot,regi,out),
      ( 0.95
      * ( sum(ces_eff_target_dyn37(out,in), p37_cesIO_baseline(ttot,regi,in))
        / p37_cesIO_baseline(ttot,regi,out)
	)
      )
    );
);

display p37_energy_limit_slope;
$endif.no_calibration

*** CCS for industry is off by default
emiMacSector(emiInd37_fuel) = NO;
pm_macSwitch(emiInd37)      = NO;

*** turn on CCS for industry emissions
if (cm_IndCCSscen eq 1,
  if (cm_CCS_cement eq 1,
    emiMacSector("co2cement") = YES;
    pm_macSwitch("co2cement") = YES;
    pm_macSwitch("co2cement_process") = YES;
    emiMac2mac("co2cement","co2cement") = YES;
    emiMac2mac("co2cement_process","co2cement") = YES;
  );

  if (cm_CCS_chemicals eq 1,
    emiMacSector("co2chemicals") = YES;
    pm_macSwitch("co2chemicals") = YES;
    emiMac2mac("co2chemicals","co2chemicals") = YES;
  );

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
  if (cm_CCS_steel eq 1,
    emiMacSector("co2steel") = YES;
    pm_macSwitch("co2steel") = YES;
    emiMac2mac("co2steel","co2steel") = YES;
  );
$endif.cm_subsec_model_steel
);

*** CCS for other industry is off in any case
emiMacSector("co2otherInd") = NO;
pm_macSwitch("co2otherInd") = NO;
emiMac2mac("co2otherInd","co2otherInd") = NO;

*** data on maximum secondary steel production
*** The steel recycling rate limit is assumed to increase from 90 to 99 %.
  p37_cesIO_up_steel_secondary(tall,all_regi,all_GDPscen)
  = pm_fedemand(tall,all_regi,"ue_steel_secondary")
  / 0.9
  * 0.99;

s37_clinker_process_CO2 = 0.5262;

*** Clinker-to-cement ratio
Parameter
  p37_clinker_cement_ratio(ttot,all_regi)   "clinker content per unit cement used"
  /
$ondelim
$include "./modules/37_industry/subsectors/input/p37_clinker-to-cement-ratio.cs3r"
$offdelim
  /
;

*' Clinker-to-cement ratios converge to the lowest regional 2005 value by 2100.
p37_clinker_cement_ratio(t,regi)
  = p37_clinker_cement_ratio("2005",regi)
  + ( smin(regi2, p37_clinker_cement_ratio("2005",regi2))
    - p37_clinker_cement_ratio("2005",regi)
    )
  * (min(t.val, 2100) - 2005)
  / (2100             - 2005);

*** Cement demand reduction is implicit in the production function, so no extra
*** costs have to be calculated.
pm_CementDemandReductionCost(ttot,regi) = 0;

*** Exogenous share of carbon in chemical feedstock that is embeded into plastics
** calculated based on energy flows in REMIND, plastics production from (Geyer et.al., 2017) and stoichiometric calculations
** Specifically, historical production of plastics, energy demand for chemicals sector,
** and carbon content of polymers
** Regionalized calculations will require regionalized data on plastics production
** this could be extracteg from (Stegmann et.al., 2022) if a feedstock-demand-based
** approximation is desired
s37_plasticsShare = 0.629;

*** FIXME calibration debug
Parameter
  p37_arcane_FE_limits(all_in,all_in)   "minimum ratio of feelhth/feelwlth and feh2/fega (may be needed for calibration)"
  /
    feh2_cement       . fega_cement          1e-5
    feh2_chemicals    . fega_chemicals       1e-5
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    feh2_steel        . fega_steel           1e-5
$endif.cm_subsec_model_steel
    feh2_otherInd     . fega_otherInd        1e-5
    feelhth_chemicals . feelwlth_chemicals   1e-5
    feelhth_otherInd  . feelwlth_otherInd    1e-5
  /
;
*** end FIXME calibration debug

* Parameters for scaling the efficiencies of feelhth_X and feh2_X towards that
* of fega_X over time.
$ontext saved for when gms::codeCheck() can handle tables properly
Table pm_calibrate_eff_scale(all_in,all_in,eff_scale_par)   "parameters for scaling efficiencies in CES calibration"
                                         level   midperiod   width
    feelhth_chemicals . fega_chemicals   1.5     2030        15
    feelhth_otherInd  . fega_otherInd    1.5     2030        15

    feh2_cement       . fega_cement      1.1     2050        22
    feh2_chemicals    . fega_chemicals   1.1     2050        22
    feh2_steel        . fega_steel       1.1     2050        22
    feh2_otherInd     . fega_otherInd    1.1     2050        22
;
$offtext

$ifthen.bal_scenario "%cm_indstExogScen%" == "forecast_bal"   !! cm_indstExogScen
  Parameter
    p37_industry_quantity_targets(ttot,all_regi,all_in)   "quantity targets for industry in policy scenarios"
    !! from FORECAST v1.0_8Gt_Bal.xlsx
    /
      2020 . DEU . ue_cement   34.396171
      2025 . DEU . ue_cement   34.086007
      2030 . DEU . ue_cement   33.497825
      2035 . DEU . ue_cement   32.984228
      2040 . DEU . ue_cement   32.517921
      2045 . DEU . ue_cement   31.826778
      2050 . DEU . ue_cement   31.13703

      2020 . DEU . ue_steel_primary     25.07355
      2025 . DEU . ue_steel_primary     27.08212
      2030 . DEU . ue_steel_primary     24.808956
      2035 . DEU . ue_steel_primary     22.442278
      2040 . DEU . ue_steel_primary     20.219831
      2045 . DEU . ue_steel_primary     19.946714
      2050 . DEU . ue_steel_primary     19.725106

      2020 . DEU . ue_steel_secondary   10.50795
      2025 . DEU . ue_steel_secondary   14.288815
      2030 . DEU . ue_steel_secondary   16.181637
      2035 . DEU . ue_steel_secondary   18.103032
      2040 . DEU . ue_steel_secondary   20.168031
      2045 . DEU . ue_steel_secondary   19.946714
      2050 . DEU . ue_steel_secondary   19.725106
    /
  ;

  !! convert Mt to Gt
  p37_industry_quantity_targets(t,regi,in)$(
                                      p37_industry_quantity_targets(t,regi,in) )
    = p37_industry_quantity_targets(t,regi,in)
      !! Mt/yr * 1e-3 Gt/Mt = Gt/yr
    * 1e-3;

  !! extend beyond 2050
  !! FIXME: do this smarter, using something like GDPpC growth or something
  p37_industry_quantity_targets(t,regi,in)$(
                                 p37_industry_quantity_targets("2050",regi,in)
 	                     AND t.val ge 2050                                 )
    = p37_industry_quantity_targets("2050",regi,in);
$endif.bal_scenario

$ifthen.ensec_scenario "%cm_indstExogScen%" == "forecast_ensec"   !! cm_indstExogScen
  Parameter
    p37_industry_quantity_targets(ttot,all_regi,all_in)   "quantity targets for industry in policy scenarios"
    !! from Ariadne_Industrieproduktion_Harmonisierung.xlsx
    /
      2020 . DEU . ue_cement   34.396171
      2025 . DEU . ue_cement   34.086007
      2030 . DEU . ue_cement   33.497825
      2035 . DEU . ue_cement   32.984228
      2040 . DEU . ue_cement   32.517921
      2045 . DEU . ue_cement   31.826778

      2020 . DEU . ue_steel_primary     23.597700
      2025 . DEU . ue_steel_primary     25.641956
      2030 . DEU . ue_steel_primary     23.563428
      2035 . DEU . ue_steel_primary     21.597116
      2040 . DEU . ue_steel_primary     19.814551
      2045 . DEU . ue_steel_primary     17.777242

      2020 . DEU . ue_steel_secondary   11.428800
      2025 . DEU . ue_steel_secondary   15.183230
      2030 . DEU . ue_steel_secondary   16.890665
      2035 . DEU . ue_steel_secondary   18.631843
      2040 . DEU . ue_steel_secondary   20.521511
      2045 . DEU . ue_steel_secondary   22.116186
    /
  ;

  !! convert Mt to Gt
  p37_industry_quantity_targets(t,regi,in)$(
                                      p37_industry_quantity_targets(t,regi,in) )
    = p37_industry_quantity_targets(t,regi,in)
      !! Mt/yr * 1e-3 Gt/Mt = Gt/yr
    * 1e-3;

  !! extend beyond 2045
  !! FIXME: do this smarter, using something like GDPpC growth or something
  p37_industry_quantity_targets(t,regi,in)$(
                                 p37_industry_quantity_targets("2045",regi,in)
 	                     AND t.val ge 2045                                 )
    = p37_industry_quantity_targets("2045",regi,in);
$endif.ensec_scenario

pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","level")     = 1.5;
pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","midperiod") = 2030;
pm_calibrate_eff_scale("feelhth_chemicals","fega_chemicals","width")     = 15;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","level")       = 1.5;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","midperiod")   = 2030;
pm_calibrate_eff_scale("feelhth_otherInd","fega_otherInd","width")       = 15;
pm_calibrate_eff_scale("feh2_cement","fega_cement","level")              = 1.1;
pm_calibrate_eff_scale("feh2_cement","fega_cement","midperiod")          = 2050;
pm_calibrate_eff_scale("feh2_cement","fega_cement","width")              = 22;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","level")        = 1.1;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","midperiod")    = 2050;
pm_calibrate_eff_scale("feh2_chemicals","fega_chemicals","width")        = 22;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
pm_calibrate_eff_scale("feh2_steel","fega_steel","level")                = 1.1;
pm_calibrate_eff_scale("feh2_steel","fega_steel","midperiod")            = 2050;
pm_calibrate_eff_scale("feh2_steel","fega_steel","width")                = 22;
$endif.cm_subsec_model_steel
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","level")          = 1.1;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","midperiod")      = 2050;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","width")          = 22;

pm_ue_eff_target("ue_cement")           = 0.00475;
pm_ue_eff_target("ue_chemicals")        = 0.008;
pm_ue_eff_target("ue_steel_primary")    = 0.0015;
pm_ue_eff_target("ue_steel_secondary")  = 0.0015;
pm_ue_eff_target("ue_otherInd")         = 0.008;


*' CES mark-up cost industry

*' The Mark-up cost on primary production factors (final energy) of the CES tree
*' have two functions:
*'  1. They represent sectoral end-use cost not captured by the energy system.
*'  2. As they alter prices to of the CES function inputs, they affect the CES
*'     efficiency parameters during calibration and therefore influence the
*'     efficiency of different FE CES inputs. The resulting economic subsitution
*'     rates are given by the marginal rate of subsitution (MRS) in the
*'     parameter `o01_CESmrs`.
*' Mark-up cost were tuned as to obtain similar or slightly higher marginal rate
*' of substitution (MRS) to gas/liquids than technical subsitution rates and
*' obtain similar specific energy consumption per value added in chemicals and
*' other industry across high and low electrification scenarios.
*'
*' There are two ways in which mark-up cost can be set:
*'  a. Mark-up cost on inputs in `ppfen_MkupCost37`: Those are counted as
*'     expenses in the budget and set by the parameter `p37_CESMkup`.
*'  b. Mark-up cost on other inputs: Those are budget-neutral and implemented as
*'     a tax.  They are set by the parameter `pm_tau_ces_tax`.
*'
*' Mark-up cost in industry are modeled without budget-effect (b).

*' Default industry mark-up cost with budget effect:
p37_CESMkup(ttot,regi,in) = 0;

*' Default industry mark-up cost without budget effect:
*' mark-up cost on electrification (hth_electricity inputs), to reach > 1 MRS to
*' gas/liquids as technical efficiency gains from electrification
pm_tau_ces_tax(t,regi,"feelhth_chemicals")    = 100 * sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feelhth_otherInd")     = 300 * sm_TWa_2_MWh * 1e-12;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
pm_tau_ces_tax(t,regi,"feel_steel_secondary") = 100 * sm_TWa_2_MWh * 1e-12;
$endif.cm_subsec_model_steel

*' mark-up cost on H2 inputs, to reach MRS around 1 to gas/liquids as similar
*' technical efficiency
pm_tau_ces_tax(t,regi,"feh2_chemicals") = 100 * sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feh2_otherInd")  =  50 * sm_TWa_2_MWh * 1e-12;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
pm_tau_ces_tax(t,regi,"feh2_steel")     =  50 * sm_TWa_2_MWh * 1e-12;
$endif.cm_subsec_model_steel
pm_tau_ces_tax(t,regi,"feh2_cement")    = 100 * sm_TWa_2_MWh * 1e-12;


*' overwrite or extent CES markup cost if specified by switch
$ifthen.CESMkup "%cm_CESMkup_ind%" == "manual"
loop (ppfen_industry_dyn37(in)$( p37_CESMkup_input(in) ),
  p37_CESMkup(ttot,regi,in)$( ppfen_MkupCost37(in) )
  = p37_CESMkup_input(in);

  pm_tau_ces_tax(ttot,regi,in)$( NOT ppfen_MkupCost37(in) )
  = p37_CESMkup_input(in);
);
$endif.CESMkup

display p37_CESMkup;
display pm_tau_ces_tax;

* Load secondary steel share limits
Parameter
  f37_steel_secondary_max_share(tall,all_regi,all_GDPscen)   "maximum share of secondary steel production"
  /
$ondelim
$include "./modules/37_industry/subsectors/input/p37_steel_secondary_max_share.cs4r";
$offdelim
  /
;

p37_steel_secondary_max_share(t,regi)
  = f37_steel_secondary_max_share(t,regi,"%cm_GDPscen%");

Parameter p37_steel_secondary_share(tall,all_regi) "endogenous values to fix rounding issues with p37_steel_secondary_max_share";

p37_steel_secondary_share(t,regi)
  = pm_cesdata(t,regi,"ue_steel_secondary","quantity")
  / ( pm_cesdata(t,regi,"ue_steel_primary","quantity")
    + pm_cesdata(t,regi,"ue_steel_secondary","quantity")
    );

if (smax((t,regi),
      p37_steel_secondary_share(t,regi)
    - p37_steel_secondary_max_share(t,regi)
    ) gt 0,
  put logfile, ">>> Modifying maximum secondary steel share <<<" /;
  loop ((t,regi)$(   p37_steel_secondary_share(t,regi)
                  gt p37_steel_secondary_max_share(t,regi) ),
    put p37_steel_secondary_max_share.tn(t,regi), "   ",
        p37_steel_secondary_max_share(t,regi), " + ",
        ( p37_steel_secondary_share(t,regi)
        - p37_steel_secondary_max_share(t,regi)), " -> ",
        p37_steel_secondary_share(t,regi) /;

    p37_steel_secondary_max_share(t,regi) = p37_steel_secondary_share(t,regi);
  );
putclose logfile, " " /;
);

$ifthen.sec_steel_scen NOT "%cm_steel_secondary_max_share_scenario%" == "off"   !! cm_steel_secondary_max_share_scenario
* Modify secondary steel share limits by scenario assumptions

$ifthen.calibrate "%CES_parameters%" == "calibrate"   !! CES_parameters
* Abort if scenario limits are to be prescribed during calibration.
$abort "cm_steel_secondary_max_share_scenario != off is incompatible with calibration"
$endif.calibrate

* Protect against the prescription of seconday steel shares in historic/fixed
* time steps.
if (smax((t,regi)$( t.val le max(cm_startyear, 2020) ),
      p37_steel_secondary_max_share_scenario(t,regi)),
  put logfile;
  put "Error: cm_steel_secondary_max_share_scenario scaling before ",
      "cm_startyear/2020" /;
  loop ((t,regi)$(    t.val le max(cm_startyear, 2020)
                  AND p37_steel_secondary_max_share_scenario(t,regi) ),
    put p37_steel_secondary_max_share_scenario.tn(t,regi), " = ",
        p37_steel_secondary_max_share_scenario(t,regi) /;
  );
  putclose logfile " " /;

  execute_unload "abort.gdx";
  abort "Faulty cm_steel_secondary_max_share_scenario scaling. See .log file for details.";
);

* Modify limits on secondary steel shares.  Linear fade from calibration limits
* to scenario limits.
loop ((regi,t2)$( p37_steel_secondary_max_share_scenario(t2,regi) ),
  loop (t3$( t3.val eq max(cm_startyear, 2020) ),
    loop (t,
      sm_tmp = max(0, min(1, (t.val - t3.val) / (t2.val - t3.val)));

      p37_steel_secondary_max_share(t,regi)
      = (p37_steel_secondary_max_share(t,regi)           * (1 - sm_tmp))
      + (p37_steel_secondary_max_share_scenario(t2,regi) * sm_tmp      );
    );
  );
);

display "scenario limits for maximum secondary steel share",
        p37_steel_secondary_max_share;
$endif.sec_steel_scen
Parameter p37_chemicals_feedstock_share(ttot,all_regi)   "minimum share of feso/feli/fega in total chemicals FE input [0-1]"
  /
$ondelim
$include "./modules/37_industry/subsectors/input/p37_chemicals_feedstock_share.cs4r";
$offdelim
  /
;

*' load baseline industry ETS solids demand
if (cm_startyear ne 2005,   !! not a BAU scenario
execute_load "input_ref.gdx", vm_demFeSector;
  p37_BAU_industry_ETS_solids(t,regi)
  = sum(se2fe(entySe,"fesos",te),
      vm_demFeSector.l(t,regi,entySe,"fesos","indst","ETS")
    );
);

* Define carbon capture and storage share in waste incineration emissions
* capture rate increases linearly from zero in 2025 to value the set in the switch for the defined year, and it is kept constant for years afterwards
p37_regionalWasteIncinerationCCSshare(ttot,all_regi) = 0;
$ifthen.cm_wasteIncinerationCCSshare not "%cm_wasteIncinerationCCSshare%" == "off"
loop((ttot,ext_regi)$p37_wasteIncinerationCCSshare(ttot,ext_regi),
  loop(regi$regi_groupExt(ext_regi,regi),
    p37_regionalWasteIncinerationCCSshare(t,regi)$((t.val gt 2025)) = min(p37_wasteIncinerationCCSshare(ttot,ext_regi), (p37_wasteIncinerationCCSshare(ttot,ext_regi)/(ttot.val -  2025))*(t.val-2025)); 
  );
);
$endIf.cm_wasteIncinerationCCSshare

*** ---------------------------------------------------------------------------
***        2. Process-Based
*** ---------------------------------------------------------------------------

p37_specMatDem(mat,all_te,opmoPrc) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
p37_specMatDem("dripell","idr","ng")        = 1.44;                                           !! Source: POSTED / Average of Devlin2022, Otto2017, Volg2018, Rechberge2020
p37_specMatDem("dripell","idr","h2")        = 1.44;                                           !! Source: POSTED / Copy from ng opMode

p37_specMatDem("driron","eaf","pri")        = 1.065;                                          !! Source: POSTED / Average of Devlin et al 2022, Section 2.2.2 and Otto et al 2017, Figure 6
p37_specMatDem("eafscrap","eaf","sec")      = 1.09;                                           !! Source: POSTED / Ecorys 2014, Table 3.1

p37_specMatDem("ironore","bf","standard")   = 1.58;                                           !! Source: Sum of weighted average values for sinter, ore and pellets in JRC BAT, Table 6.1: 1.626 / tHM -> 1.58/tPI

!! Switch off scrap input to BOF, as BOF output is purely prsteel (for now) and scrap availability limits sesteel in current implementation
p37_specMatDem("bofscrap","bof","unheated") = sm_eps;                                         !! Source: DUMMY
p37_specMatDem("pigiron","bof","unheated")  = 1.03;                                           !! Source: Rough total of scrap and pigiron in JRC-BAT
$endif.cm_subsec_model_steel

*** --------------------------------

!!TODO: Think about accounting of integrated plants / casting & rolling
p37_specFeDemTarget(all_enty,all_te,opmoPrc) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
!! numbers are given in MWh/t and converted to Remind units TWa/Gt with the factors after that (divided by 8.76)
!! reduction: 504 m^3; heat 242 m^3; conversion: x / 11.126 m^3/kg * 0.0333 MWh/kg
p37_specFeDemTarget("feh2s","idr","h2")           = 2.23 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Rechberger et al 2020, Section 4.2 (per tDRI)
p37_specFeDemTarget("feels","idr","h2")           = 0.08 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Hölling et al 2017, Just before Table 1 (per tHBI)

p37_specFeDemTarget("fegas","idr","ng")           = 2.69 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Hölling et al 2017, Page 7 (9.7 GJ) (per tHBI)
p37_specFeDemTarget("feels","idr","ng")           = 0.08 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Hölling et al 2017, Page 7 (9.7 GJ) (per tHBI)

!! To do: Does not include casting and rolling;
!! Birat2010, p. 11: 0.97 MWh total, only 0.44 MWh of which is electrical
!! EU JRC BAT says 0.404–0.748 (only EAF, elec) / Otto et al. say 0.92
!! --> have declining curve?
p37_specFeDemTarget("feels","eaf","pri")          = 0.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Copy from secondary (Agora Energiewende, 2022 give similar values, between w and w/o reheating)
p37_specFeDemTarget("feels","eaf","sec")          = 0.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: POSTED / Vogl et al 2018, Section 3.1

!! Otto et al. Fig 3: 10.303 GJ coke (from 13.24 GJ coal, see Menendez2015 Fig 3) + 4.67 GJ coal dust -> 18 GJ
!! Birat2010, p.11 says best performers have 17 GJ, out of which 16 GJ coal
!! -> take 16 GJ / 3.6 (to MWH) / 1.03 (pigiron to steel) = 4.3
!! Optimistic value as tech will improve over time and historic BF vs BAT DRI is unfair anyways
p37_specFeDemTarget("fesos","bf","standard")      = 4.30 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: Otto et al.
!! set all others to zero to have rough approximation of power plant output
p37_specFeDemTarget("fegas","bf","standard")    = sm_eps / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: DUMMY
p37_specFeDemTarget("feels","bf","standard")    = sm_eps / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: DUMMY
p37_specFeDemTarget("fehos","bf","standard")    = sm_eps / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: DUMMY

!! per tC for cc tech!!
p37_specFeDemTarget("feels","bfcc","standard")    = 0.11 * 3.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: Tsupari2013
p37_specFeDemTarget("fegas","bfcc","standard")    = 0.92 * 3.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Source: Tsupari2013 / Yun2021

!! World Steel Factsheet says no additional equipment needed --> very cheap and no energy demand
!! IEA Steel Roadmap Fig 2.11 also shows very little additional fuel cost
p37_specFeDemTarget("feels","idrcc","ng")         = 0.11 * 3.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Copy from bfcc
p37_specFeDemTarget("fegas","idrcc","ng")         = 0.92 * 3.67 / (sm_TWa_2_MWh/sm_giga_2_non);    !! Copy from bfcc
$endif.cm_subsec_model_steel

*** --------------------------------

p37_mat2ue(all_enty,all_in) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
p37_mat2ue("sesteel","ue_steel_secondary") = 1.;
p37_mat2ue("prsteel","ue_steel_primary")   = 1.;
$endif.cm_subsec_model_steel

*** --------------------------------

p37_captureRate(all_te,opmoPrc) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
p37_captureRate("bfcc","standard") = 0.73; !! Source: Witecka 2023, Figure 18
p37_captureRate("idrcc","ng")      = 0.85; !! Source: IEA Steel Roadmap Fig. 2.11
$endif.cm_subsec_model_steel

*** --------------------------------

p37_priceMat(all_enty) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
!! IEA STeel Roadmap Fig 1.3 Caption: Scrap price 200-300 $/t
!! => take 250 $/t, inflation 2005 --> 2020 / 1.33
p37_priceMat("eafscrap") = 0.188;
p37_priceMat("bofscrap") = 0.188;
!! Agora KSV-Rechner: 114 €/tSteel / (1.4 2005$/2023€) / (tn$ /bn t)
p37_priceMat("ironore")  = 0.081;
!! Agora KSV-Rechner: 154 €/tSteel / (1.4 2005$/2023€) / (tn$ /bn t)
p37_priceMat("dripell")  = 0.110;
$endif.cm_subsec_model_steel

*** --------------------------------

pm_specFeDem(tall,all_regi,all_enty,all_te,opmoPrc) = 0.;
pm_outflowPrcIni(all_regi,all_te,opmoPrc) = 0.;
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
if (cm_startyear eq 2005,
  pm_outflowPrcIni(regi,'bof','unheated') = pm_fedemand('2005',regi,'ue_steel_primary');
  pm_outflowPrcIni(regi,'bf','standard') = p37_specMatDem("pigiron","bof","unheated") * pm_outflowPrcIni(regi,'bof','unheated');
  pm_outflowPrcIni(regi,'eaf','sec') = pm_fedemand('2005',regi,'ue_steel_secondary');
  pm_outflowPrcIni(regi,'eaf','pri') = 0.;
  pm_outflowPrcIni(regi,'idr','ng') = 0.;
  pm_outflowPrcIni(regi,'idr','h2') = 0.;
  pm_outflowPrcIni(regi,'bfcc','standard') = 0.;
  pm_outflowPrcIni(regi,'idrcc','ng') = 0.;

  loop(ttot$(ttot.val ge 2005 AND ttot.val le 2020),
    pm_specFeDem(ttot,regi,"feh2s","idr","h2") = p37_specFeDemTarget("feh2s","idr","h2");
    pm_specFeDem(ttot,regi,"feels","idr","h2") = p37_specFeDemTarget("feels","idr","h2");

    pm_specFeDem(ttot,regi,"fegas","idr","ng") = p37_specFeDemTarget("fegas","idr","ng");
    pm_specFeDem(ttot,regi,"feels","idr","ng") = p37_specFeDemTarget("feels","idr","ng");

    pm_specFeDem(ttot,regi,"fegas","bfcc","standard") = p37_specFeDemTarget("fegas","bfcc","standard");
    pm_specFeDem(ttot,regi,"feels","bfcc","standard") = p37_specFeDemTarget("feels","bfcc","standard");

    pm_specFeDem(ttot,regi,"fegas","idrcc","ng") = p37_specFeDemTarget("fegas","idrcc","ng");
    pm_specFeDem(ttot,regi,"feels","idrcc","ng") = p37_specFeDemTarget("feels","idrcc","ng");

    pm_specFeDem(ttot,regi,"fesos","bf","standard") = pm_fedemand(ttot,regi,'feso_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    pm_specFeDem(ttot,regi,"fehos","bf","standard") = pm_fedemand(ttot,regi,'feli_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    pm_specFeDem(ttot,regi,"fegas","bf","standard") = pm_fedemand(ttot,regi,'fega_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    pm_specFeDem(ttot,regi,"feels","bf","standard") = pm_fedemand(ttot,regi,'feel_steel_primary') * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );

    pm_specFeDem(ttot,regi,"feels","eaf","sec") = pm_fedemand(ttot,regi,'feel_steel_secondary') * sm_EJ_2_TWa / pm_fedemand(ttot,regi,'ue_steel_secondary');
    pm_specFeDem(ttot,regi,"feels","eaf","pri") = pm_specFeDem(ttot,regi,"feels","eaf","sec");
  );

  !! loop over other years and blend
  loop(entyFeStat(all_enty),
    loop(tePrc(all_te),
      loop(opmoPrc,
        if( (p37_specFeDemTarget(all_enty,all_te,opmoPrc) gt 0.),
          loop(ttot$(ttot.val > 2020),
            !! fedemand in excess of BAT halves until 2055
            !! gams cannot handle float exponents, so pre-compute 0.5^(1/(2055-2020)) = 0.9804
            pm_specFeDem(ttot,regi,all_enty,all_te,opmoPrc)
            = p37_specFeDemTarget(all_enty,all_te,opmoPrc)
            + (pm_specFeDem("2020",regi,all_enty,all_te,opmoPrc) - p37_specFeDemTarget(all_enty,all_te,opmoPrc))
            * power(0.9804, ttot.val - 2020) ;
          );
        );
      );
    );
  );
);

if (cm_startyear gt 2005,
  Execute_Loadpoint 'input_ref' pm_specFeDem = pm_specFeDem;
);
$endif.cm_subsec_model_steel

*** EOF ./modules/37_industry/subsectors/datainput.gms
