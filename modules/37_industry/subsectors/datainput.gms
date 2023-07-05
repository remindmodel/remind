*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/datainput.gms

vm_macBaseInd.l(ttot,regi,entyFE,secInd37) = 0;

***-------------------------------------------------------------------------------
***                         MATERIAL-FLOW IMPLEMENTATION
***-------------------------------------------------------------------------------
$ifthen.process_based_steel "%cm_process_based_steel%" == "on"              !! cm_process_based_steel
PARAMETERS
  p37_specMatsDem(mats,teMats,opModes)                                      "Specific materials demand of a production technology and operation mode [t_input/t_output]"
  /
    ironore.idr.(ng,h2)     1.5                                             !! Iron ore demand of iron direct-reduction (independent of fuel source)
    
    dri.eaf.pri             1.0                                             !! DRI demand of EAF
    scrap.eaf.sec           1.0                                             !! Scrap demand of EAF
    dri.eaf.sec             0.0
    scrap.eaf.pri           0.0
    
    ironore.bfbof.pri       1.5                                             !! Iron ore demand of BF-BOF
    scrap.bfbof.sec         1.0                                             !! Scrap demand of BF-BOF
    scrap.bfbof.pri         0.0
    ironore.bfbof.sec       0.0
  /

  p37_specFeDem(entyFe,teMats,opModes)                                      "Specific final-energy demand of a production technology and operation mode [MWh/t_output]"
  /
    feels.idr.(ng,h2)       0.33                                            !! Specific electric demand for both H2 and NG operation.
    fegas.idr.ng            2.94                                            !! Specific natural gas demand when operating with NG.
    feh2s.idr.h2            1.91                                            !! Specific hydrogen demand when operating with H2.
    
    feels.eaf.pri           0.91                                            !! Specific electricy demand of EAF when operating with DRI.
    feels.eaf.sec           0.67                                            !! Specific electricy demand of EAF when operating with scrap.
    
    fesos.bfbof.pri         2.0                                             !! Specific coal demand of BF-BOF when operating with DRI -- this number is just a guess
    fesos.bfbof.sec         0.5                                             !! Specific coal demand of BF-BOF when operating with scrap -- this number is just a guess
  /
;
$endif.process_based_steel


***-------------------------------------------------------------------------------
***                     REST OF SUBSECTOR INDUSTRY MODULE
***-------------------------------------------------------------------------------
*** substitution elasticities
Parameter
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
        ue_steel_primary             1.7   !! energy, capital
          en_steel_primary           0.3   !! furnace, electricity
            en_steel_furnace         2.0   !! solids, liquids, gases, hydrogen
        ue_steel_secondary           1.7   !! energy, capital

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

pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val le 2025) = 0.5;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2030) = 0.7;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2035) = 1.3;
pm_cesdata_sigma(ttot,"en_steel_furnace")$ (ttot.val eq 2040) = 2.0;

pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val le 2025) = 0.7;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2030) = 1.3;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2035) = 1.7;
pm_cesdata_sigma(ttot,"en_otherInd_hth")$ (ttot.val eq 2040) = 2.0;

*** abatement parameters for industry CCS MACs
$include "./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms";

$IFTHEN.Industry_CCS_markup NOT "%cm_Industry_CCS_markup%" == "off" 
pm_abatparam_Ind(ttot,regi,all_enty,steps)$(
                                    pm_abatparam_Ind(ttot,regi,all_enty,steps) )
  = pm_abatparam_Ind(ttot,regi,all_enty,steps);
  / %cm_Industry_CCS_markup%);
$ENDIF.Industry_CCS_markup

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

* Specific energy demand cannot fall below a curve described by an exponential
* function passing through the 2015 value and a point defined by an "efficiency
* gain" (e.g. 75 %) between baseline value and thermodynamic limit at a given
* year (e.g. 2050).
$ifthen.no_calibration "%CES_parameters%" == "load"   !! CES_parameters
if (cm_emiscen eq 1,
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

  if (cm_CCS_steel eq 1,
    emiMacSector("co2steel") = YES;
    pm_macSwitch("co2steel") = YES;
    emiMac2mac("co2steel","co2steel") = YES;
  );
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

*** FIXME calibration debug
Parameter
  p37_arcane_FE_limits(all_in,all_in)   "minimum ratio of feelhth/feelwlth and feh2/fega (may be needed for calibration)"
  /
    feh2_cement       . fega_cement          1e-5
    feh2_chemicals    . fega_chemicals       1e-5
    feh2_steel        . fega_steel           1e-5
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
pm_calibrate_eff_scale("feh2_steel","fega_steel","level")                = 1.1;
pm_calibrate_eff_scale("feh2_steel","fega_steel","midperiod")            = 2050;
pm_calibrate_eff_scale("feh2_steel","fega_steel","width")                = 22;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","level")          = 1.1;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","midperiod")      = 2050;
pm_calibrate_eff_scale("feh2_otherInd","fega_otherInd","width")          = 22;

pm_ue_eff_target("ue_cement")           = 0.00475;
pm_ue_eff_target("ue_chemicals")        = 0.008;
pm_ue_eff_target("ue_steel_primary")    = 0.0015;
pm_ue_eff_target("ue_steel_secondary")  = 0.0015;
pm_ue_eff_target("ue_otherInd")         = 0.008;



*` CES mark-up cost industry

*` The Mark-up cost on primary production factors (final energy) of the CES tree have two functions. 
*` (1) They represent sectoral end-use cost not captured by the energy system. 
*` (2) As they alter prices to of the CES function inputs, they affect the CES efficiency parameters during calibration 
*` and therefore influence the efficiency of different FE CES inputs. The resulting economic subsitution rates
*` are given by the marginal rate of subsitution (MRS) in the parameter o01_CESmrs.
*` Mark-up cost were tuned as to obtain similar or slightly higher marginal rate of substitution (MRS) to gas/liquids than technical subsitution rates and 
*` obtain similar specific energy consumption per value added in chemicals and other industry across high and low electrification scenarios. 


*` There are two ways in which mark-up cost can be set:
*` (a) Mark-up cost on inputs in ppfen_MkupCost37: Those are counted as expenses in the budget and set by the parameter p37_CESMkup. 
*` (b) Mark-up cost on other inputs: Those are budget-neutral and implemented as a tax. They are set by the parameter pm_tau_ces_tax. 

*` Mark-up cost in industry are modeled without budget-effect (b).

*` Default industry mark-up cost with budget effect:
p37_CESMkup(t,regi,in) = 0;

*` Default industry mark-up cost without budget effect:
*` mark-up cost on electrification (hth_electricity inputs), to reach >1 MRS to gas/liquids as technical efficiency gains from electrification
pm_tau_ces_tax(t,regi,"feelhth_chemicals") = 100* sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feelhth_otherInd") = 300* sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feel_steel_secondary") = 100* sm_TWa_2_MWh * 1e-12;

*` mark-up cost on H2 inputs, to reach MRS around 1 to gas/liquids as similar technical efficiency
pm_tau_ces_tax(t,regi,"feh2_chemicals") = 100* sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feh2_otherInd") = 50* sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feh2_steel") = 50* sm_TWa_2_MWh * 1e-12;
pm_tau_ces_tax(t,regi,"feh2_cement") = 100* sm_TWa_2_MWh * 1e-12;


*` overwrite or extent CES markup cost if specified by switch
$ifThen.CESMkup not "%cm_CESMkup_ind%" == "standard"
  p37_CESMkup(t,regi,in)$(p37_CESMkup_input(in) AND ppfen_MkupCost37(in)) = p37_CESMkup_input(in);
  pm_tau_ces_tax(t,regi,in)$(p37_CESMkup_input(in) AND (NOT ppfen_MkupCost37(in))) = p37_CESMkup_input(in);
$endIf.CESMkup

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

*' load baseline industry ETS solids demand
if (cm_emiscen ne 1,   !! not a BAU scenario
execute_load "input_ref.gdx", vm_demFEsector;
  p37_BAU_industry_ETS_solids(t,regi)
  = sum(se2fe(entySE,"fesos",te),
      vm_demFEsector.l(t,regi,entySE,"fesos","indst","ETS")
    );
);

*** EOF ./modules/37_industry/subsectors/datainput.gms
