*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/preloop.gms


*** Adjustment of final energy subsidies to avoid neg. implicit 2005 prices that result in huge demand increases in 2010 and 2015
*** Maximum final energy subsidy levels (in $/Gj) from REMIND version prior to rev. 5429
p21_tau_fe_sub(ttot,regi,sector,entyFe)$p21_max_fe_sub(ttot,regi,entyFe) = max(p21_tau_fe_sub(ttot,regi,sector,entyFe),-p21_max_fe_sub(ttot,regi,entyFe));
*** Subsidy proportional cap to avoid liquids increasing dramatically
p21_tau_fe_sub(ttot,regi,sector,entyFe)$p21_prop_fe_sub(ttot,regi,entyFe) = p21_tau_fe_sub(ttot,regi,sector,entyFe) * p21_prop_fe_sub(ttot,regi,entyFe);
*** Maximum primary energy subsidy levels (in $/Gj) to provide plausible upper bound: 40$/barrel ~ 8 $/GJ"
p21_tau_fuEx_sub(ttot,regi,enty)$f21_max_pe_sub(ttot,regi,enty) = max(p21_tau_fuEx_sub(ttot,regi,enty),-f21_max_pe_sub(ttot,regi,enty)*0.001/sm_EJ_2_TWa);

*** ------------------------- Temporal development of final energy TAXES and SUBSIDIES, depending on cm_fetaxscen
*** Set time path for:
***   - final energy taxes (p21_tau_fe_tax, p21_tau_pe2se_tax)
***   - subsidies (p21_tau_fe_sub, p21_tau_fuEx_sub)

***----- TAXES  ----------------------------------
if(cm_fetaxscen eq 0, !! no FE tax, constant PE2SE tax
    p21_tau_fe_tax(ttot,all_regi,emi_sectors,entyFe) = 0;
  elseif (cm_fetaxscen eq 1) or (cm_fetaxscen eq 3) or (cm_fetaxscen eq 4), !! constant FE and PE2SE tax
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(ttot.val gt 2005) = p21_tau_fe_tax("2005",regi,sector,entyFe);
  elseif cm_fetaxscen eq 2, !! converging FE tax (-2050), constant PE2SE tax
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(ttot.val gt 2005) = p21_tau_fe_tax("2005",regi,sector,entyFe);
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence("2050",regi,entyFe) AND ttot.val gt 2025 AND ttot.val le 2050)
	  = p21_tau_fe_tax("2025",regi,sector,entyFe) 
      + ( f21_tax_convergence("2050",regi,entyFe) * 0.001 / sm_EJ_2_TWa - p21_tau_fe_tax("2025",regi,sector,entyFe) ) * ( ( ttot.val - 2025 ) / ( 2050 - 2025 ) );
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence("2050",regi,entyFe) AND ttot.val gt 2050) = f21_tax_convergence("2050",regi,entyFe) * 0.001 / sm_EJ_2_TWa;
  elseif cm_fetaxscen eq 5, !! rollback FE tax (-2035), no PE2SE tax
    p21_tau_pe2se_tax(tall,regi,te) = 0;
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(ttot.val gt 2005) = p21_tau_fe_tax("2005",regi,sector,entyFe);
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence_rollback("2035",regi,entyFe) AND ttot.val gt 2025 AND ttot.val le 2035 )
	   = p21_tau_fe_tax("2025",regi,sector,entyFe) 
       + ( f21_tax_convergence_rollback("2035",regi,entyFe) * 0.001 / sm_EJ_2_TWa - p21_tau_fe_tax("2025",regi,sector,entyFe) ) * ( (ttot.val - 2025) / (2035 - 2025) );
    p21_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence_rollback("2035",regi,entyFe) AND ttot.val  gt 2035) = f21_tax_convergence_rollback("2035",regi,entyFe) * 0.001 / sm_EJ_2_TWa;
);

***----- SUBSIDIES  ----------------------------------
if (cm_fetaxscen eq 0, !! no FE and ResEx sub
    p21_tau_fe_sub(ttot,all_regi,emi_sectors,entyFe) = 0;
    p21_tau_fuEx_sub(ttot,regi,all_enty) = 0;
  elseif (cm_fetaxscen eq 1) or (cm_fetaxscen eq 5), !! constant FE and ResEx sub, in case of 5 (i.e. rollback) some reduction in tax levels to avoid absurd results
    p21_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val gt 2005) = p21_tau_fe_sub("2005",regi,sector,entyFe);
    p21_tau_fuEx_sub(ttot,regi,entyPe)$(ttot.val gt 2005) = p21_tau_fuEx_sub("2005",regi,entyPe);
    if ( (cm_fetaxscen eq 5),
      p21_tau_fe_sub(ttot,regi,sector,entyFe)$(f21_sub_convergence_rollback("2035",regi,sector,entyFe) gt 0 AND ttot.val gt 2025 AND ttot.val le 2035 )
   	      = p21_tau_fe_sub("2025",regi,sector,entyFe) 
         + ( f21_sub_convergence_rollback("2035",regi,sector,entyFe) * 0.001 / sm_EJ_2_TWa - p21_tau_fe_sub("2025",regi,sector,entyFe) ) * ( (ttot.val - 2025) / (2035 - 2025) );
      p21_tau_fe_sub(ttot,regi,sector,entyFe)$(f21_sub_convergence_rollback("2035",regi,sector,entyFe) gt 0 AND ttot.val  gt 2035) = f21_sub_convergence_rollback("2035",regi,sector,entyFe) * 0.001 / sm_EJ_2_TWa;
    );
*** Limit subsidy feelt and feels maximum value at 2050 onward to 0.2 [$/TWa] to avoid negative electricity prices. Linearly reduce values from 2035.
    p21_tau_fe_sub(ttot,regi,sector,entyFe)$((ttot.val gt 2035) AND (ttot.val le 2050) AND (p21_tau_fe_sub("2050",regi,sector,entyFe) lt -0.2) AND (sameas(entyFe,"feelt") OR sameas(entyFe,"feels"))) = 
      p21_tau_fe_sub("2035",regi,sector,entyFe) - 
      (p21_tau_fe_sub("2050",regi,sector,entyFe) - (-0.2)) * (ttot.val - 2035) / (2050 - 2035);
    p21_tau_fe_sub(ttot,regi,sector,entyFe)$((ttot.val gt 2050)) = p21_tau_fe_sub("2050",regi,sector,entyFe);
  elseif(cm_fetaxscen eq 2) or (cm_fetaxscen eq 3) or (cm_fetaxscen eq 4), 
    p21_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val gt 2005)=p21_tau_fe_sub("2005",regi,sector,entyFe);
    p21_tau_fuEx_sub(ttot,regi,entyPe)$(ttot.val gt 2005)=p21_tau_fuEx_sub("2005",regi,entyPe);
    if ( (cm_fetaxscen eq 2) or (cm_fetaxscen eq 4), !! phased out FE and ResEx sub (-2035)
        s21_tax_time = 2035;
      elseif cm_fetaxscen eq 3, !! phased out FE and ResEx sub (-2050)
        s21_tax_time = 2050;
    );
    s21_tax_value = 0;
    p21_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val gt 2025 AND ttot.val le s21_tax_time)
      = p21_tau_fe_sub("2025",regi,sector,entyFe)
        + ( ( s21_tax_value - p21_tau_fe_sub("2025",regi,sector,entyFe) ) * (ttot.val - 2025 ) / (s21_tax_time - 2025));
      p21_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val gt s21_tax_time) = s21_tax_value;

      p21_tau_fuEx_sub(ttot,regi,entyPe)$(ttot.val gt 2025 AND ttot.val le s21_tax_time)
      = p21_tau_fuEx_sub("2025",regi,entyPe)
        + ((s21_tax_value - p21_tau_fuEx_sub("2025",regi,entyPe) ) * (ttot.val - 2025) / (s21_tax_time - 2025));
      p21_tau_fuEx_sub(ttot,regi,entyPe)$(ttot.val gt  s21_tax_time) = s21_tax_value;
);


*** FS: switch cm_FEtax_trajectory to explicitly control tax level trajectory (overwrites cm_fetaxscen settings for the respective taxes affected), 
$ifthen.fetax not "%cm_FEtax_trajectory_abs%" == "off" 
*** from year given in cm_FEtax_trajectory_abs, set FE tax to level specified by cm_FEtax_trajectory_abs, cm_FEtax_trajectory_abs in USD/MWh -> convert to trUSD/TWa
  loop((ttot,sector,entyFe)$p21_FEtax_trajectory_abs(ttot,sector,entyFe),
*** set FE tax to cm_FEtax_trajectory_abs to year given in cm_FEtax_trajectory_abs and after
    loop(ttot2$(ttot2.val ge ttot.val),
    p21_tau_fe_tax(ttot2,regi,sector,entyFe) = p21_FEtax_trajectory_abs(ttot,sector,entyFe) * sm_TWa_2_MWh * 1e-12;
    );
*** phase-in(out) FE tax linearly before from startyear to year given in cm_FEtax_trajectory_abs
    loop(ttot2$(ttot2.val eq cm_startyear),
    p21_tau_fe_tax(t,regi,sector,entyFe)$(t.val lt ttot.val and t.val ge cm_startyear)  = (p21_tau_fe_tax(ttot,regi,sector,entyFe) - p21_tau_fe_tax(ttot2,regi,sector,entyFe))/(ttot.val - ttot2.val) * (t.val - ttot2.val) + p21_tau_fe_tax(ttot2,regi,sector,entyFe);
    );
  );
$endif.fetax


*** FS: switch cm_FEtax_trajectory_rel to scale tax trajectory relative to tax in cm_startyear (overwrites cm_fetaxscen settings for the respective taxes affected), 
$ifthen.fetaxRel not "%cm_FEtax_trajectory_rel%" == "off" 
  loop((ttot,sector,entyFe)$p21_FEtax_trajectory_rel(ttot,sector,entyFe),
    loop(ttot2$(ttot2.val eq cm_startyear),
*** set FE tax to cm_FEtax_trajectory_rel * FE tax level of cm_startyear in year given in cm_FEtax_trajectory_rel and after
      loop(ttot3$(ttot3.val ge ttot.val),
        p21_tau_fe_tax(ttot3,regi,sector,entyFe) = p21_FEtax_trajectory_rel(ttot,sector,entyFe) * p21_tau_fe_tax(ttot2,regi,sector,entyFe);
      );
*** increase or decrease FE tax level linearily before
    p21_tau_fe_tax(t,regi,sector,entyFe)$(t.val lt ttot.val and t.val ge cm_startyear)  = (p21_tau_fe_tax(ttot,regi,sector,entyFe) - p21_tau_fe_tax(ttot2,regi,sector,entyFe))/(ttot.val - ttot2.val) * (t.val - ttot2.val) + p21_tau_fe_tax(ttot2,regi,sector,entyFe);
    );
  );
$endif.fetaxRel

display p21_tau_fe_sub; 
display p21_tau_fe_tax;
display p21_tau_fuEx_sub;
display p21_tau_pe2se_tax;

*** SE Tax
p21_tau_SE_tax(t,regi,te) = 0;
$ifThen.SEtaxRampUpParam not "%cm_SEtaxRampUpParam%" == "off" 
*** SE tax is currently used to tax electricity going into electrolysis. There is a maximum tax rate that is assumed
*** to be the sum of the industry electricity FE tax and the investment cost per unit electricity of the grid (grid fee). 
*** There is a ramp up of the SE electricity tax for electrolysis depending on the share of electrolysis in total electricity demand
*** described by a logistic function. This results in low taxes for electrolysis at low shares of electrolysis in the power system
*** as the technology has system benefits in this domain. At higher shares this rapidly increases and converges towards the maximum tax rate.
*** See the equations file of the tax module for more information on the SE tax.
*** Parameter datainput needs to happen here because pm_tau_fe_tax, the final energy tax rate, is set in this file and not in the datainput file.
  p21_tau_SE_tax(t,regi,"elh2") = p21_tau_fe_tax(t,regi,"indst","feels")
*** calculate grid fees as levelized cost of CAPEX from tdels, the electricity transmission and distribution grid
*** by annualising the CAPEX and dividing by the capacity factor
                                  + pm_inco0_t(t,regi,"tdels") 
                                  * pm_teAnnuity("tdels")
                                  / pm_cf(t,regi,"tdels");
$endif.SEtaxRampUpParam

*LB* initialization of vm_emiMac
vm_emiMac.l(ttot,regi,enty) = 0;
*** initialization of vm_emiAllco2neg and v21_emiAllco2neg_acrossIterations
vm_emiAllco2neg.l(ttot,regi) =0;
v21_emiAllco2neg_acrossIterations.l(ttot,regi) =0;

*** initialization of p21_grossEmissions
p21_grossEmissions(iteration,t,regi) = 0;

*DK initialize bioenergy tax
v21_tau_bio.l(ttot) = 0;

*** FS: initialize flexibility tax
vm_flexAdj.l(ttot,all_regi,all_te) = 0;

*** FS: set market price of good to non-zero to avoid division by zero in first iteration
pm_pvp(ttot,"good")$(pm_pvp(ttot,"good") = 0) = sm_eps;

*** initialize taxrevImport
v21_taxrevImport.l(t,regi,tradePe) = 0;

*** initialize taxrevImport
v21_taxrevChProdStartYear.l(t,regi) = 0;

*** initialize SE tax rate
v21_tau_SE_tax.l(t,regi,te)=0;

*** EOF ./modules/21_tax/on/preloop.gms
