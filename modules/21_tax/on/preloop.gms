*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/21_tax/on/preloop.gms

***initialize co2 market taxes
pm_taxemiMkt(t,regi,emiMkt)$(t.val ge cm_startyear) = 0;
pm_taxemiMkt_iteration(iteration,t,regi,emiMkt)$(t.val ge cm_startyear) = 0;

*LB* set CO2 tax in 2005 and 2010 to 0
pm_taxCO2eq("2005",regi)=0;
pm_taxCO2eq("2010",regi)=0;

***-------------------------------------------------------------------
***           overwrite default targets with gdx values
***-------------------------------------------------------------------
Execute_Loadpoint 'input' p21_tau_CO2_tax_gdx = pm_taxCO2eq;
if (cm_gdximport_target eq 1,
*** only if tax rates not all equal to zero
if (smax((t,regi),p21_tau_CO2_tax_gdx(t,regi)$(t.val gt 2030)) gt 0,
pm_taxCO2eq(t,regi) = p21_tau_CO2_tax_gdx(t,regi);
);
);
if (cm_emiscen ne 9,
    pm_taxCO2eq(t, regi) = 0;
);
***-------------------------------------------------------------------
***           overwrite co2 tax for delay runs with gdx values
***-------------------------------------------------------------------
if ( (cm_startyear gt 2005),
Execute_Loadpoint 'input_ref' p21_tau_CO2_tax_gdx_bau = pm_taxCO2eq;
pm_taxCO2eq(ttot,regi)$((ttot.val gt 2005) AND (ttot.val lt cm_startyear)) = p21_tau_CO2_tax_gdx_bau(ttot,regi);
);

display pm_taxCO2eq;

*** Adjustment of final energy subsidies to avoid neg. implicit 2005 prices that result in huge demand increases in 2010 and 2015
*** Maximum final energy subsidy levels (in $/Gj) from REMIND version prior to rev. 5429
pm_tau_fe_sub(ttot,regi,sector,entyFe)$p21_max_fe_sub(ttot,regi,entyFe) = max(pm_tau_fe_sub(ttot,regi,sector,entyFe),-p21_max_fe_sub(ttot,regi,entyFe));
*** Subsidy proportional cap to avoid liquids increasing dramatically
pm_tau_fe_sub(ttot,regi,sector,entyFe)$p21_prop_fe_sub(ttot,regi,entyFe) = pm_tau_fe_sub(ttot,regi,sector,entyFe) * p21_prop_fe_sub(ttot,regi,entyFe);
*** Maximum primary energy subsidy levels (in $/Gj) to provide plausible upper bound: 40$/barrel ~ 8 $/GJ"
p21_tau_fuEx_sub(ttot,regi,enty)$f21_max_pe_sub(ttot,regi,enty) = max(p21_tau_fuEx_sub(ttot,regi,enty),-f21_max_pe_sub(ttot,regi,enty)*0.001/sm_EJ_2_TWa);

*** ------------------------- Temporal development of final energy TAXES and SUBSIDIES, depending on cm_fetaxscen
*** Set time path for:
***   - final energy taxes (pm_tau_fe_tax)
***   - subsidies (p21_tau_fe_sub)
if(cm_fetaxscen ne 0,
*----- TAXES  ----------------------------------

***CASE 1: constant TAXES
  if((cm_fetaxscen eq 1) or (cm_fetaxscen eq 3) or (cm_fetaxscen eq 4),
    loop(ttot$(ttot.val ge 2005), pm_tau_fe_tax(ttot,regi,sector,entyFe) = pm_tau_fe_tax("2005",regi,sector,entyFe));
  );
***CASE 2: constant TAXES except for the final energies and regions defined at the f21_tax_convergence.cs4r file
  if(cm_fetaxscen eq 2,
	loop(ttot$(ttot.val ge 2005), pm_tau_fe_tax(ttot,regi,sector,entyFe) = pm_tau_fe_tax("2005",regi,sector,entyFe));

	s21_tax_time  = 2050;
	pm_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence("2050",regi,entyFe) AND ttot.val > 2015 AND ttot.val<(s21_tax_time + 1))
	=
    pm_tau_fe_tax("2005",regi,sector,entyFe)+((f21_tax_convergence("2050",regi,entyFe)*0.001/sm_EJ_2_TWa-pm_tau_fe_tax("2005",regi,sector,entyFe))*((ttot.val-2015)/(s21_tax_time-2015)));
    pm_tau_fe_tax(ttot,regi,sector,entyFe)$(f21_tax_convergence("2050",regi,entyFe) AND ttot.val >(s21_tax_time)) = f21_tax_convergence("2050",regi,entyFe)*0.001/sm_EJ_2_TWa;
  );

***----- SUBSIDIES  ----------------------------------
***global subsidies phase-out until 2030 for SSP1 (CASE 2) & SDP (CASE 4), until 2050 for SSP2 (CASE 3), no phaseout for SSP5 (CASE 1)
*** CASE 1: Constant subsidy (SSP5)
  if(cm_fetaxscen eq 1,
    loop(ttot$(ttot.val ge 2005), pm_tau_fe_sub(ttot,regi,sector,entyFe)=pm_tau_fe_sub("2005",regi,sector,entyFe));
    loop(ttot$(ttot.val ge 2005), p21_tau_pe2se_sub(ttot,regi,te)=p21_tau_pe2se_sub("2005",regi,te));
    loop(ttot$(ttot.val ge 2005), p21_tau_fuEx_sub(ttot,regi,entyPE)=p21_tau_fuEx_sub("2005",regi,entyPE));
  );
*** CASE 2 and 3 and 4: Global subsidies phase-out by 2030 (SSP1, SDP) and 2050 (SSP2) respectively
  if(cm_fetaxscen eq 2 OR cm_fetaxscen eq 3 OR cm_fetaxscen eq 4,
     pm_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val eq 2010 OR ttot.val eq 2015)=pm_tau_fe_sub("2005",regi,sector,entyFe);
     p21_tau_pe2se_sub(ttot,regi,te)$(ttot.val eq 2010 OR ttot.val eq 2015)=p21_tau_pe2se_sub("2005",regi,te);
     p21_tau_fuEx_sub(ttot,regi,entyPE)$(ttot.val eq 2010 OR ttot.val eq 2015)=p21_tau_fuEx_sub("2005",regi,entyPE);
    if(cm_fetaxscen eq 2 OR cm_fetaxscen eq 4, s21_tax_time = 2030);
    if(cm_fetaxscen eq 3, s21_tax_time = 2050);
    s21_tax_value = 0;
*** Calculate phase-out
    loop(ttot,
      pm_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val > 2015 AND ttot.val<(s21_tax_time + 1))
      =
      pm_tau_fe_sub("2015",regi,sector,entyFe)+((s21_tax_value-pm_tau_fe_sub("2015",regi,sector,entyFe))*(ttot.val-2015)/(s21_tax_time-2015));
      pm_tau_fe_sub(ttot,regi,sector,entyFe)$(ttot.val>(s21_tax_time)) = s21_tax_value;

      p21_tau_pe2se_sub(ttot,regi,te)$(ttot.val > 2015 AND ttot.val<(s21_tax_time + 1))
      =
      p21_tau_pe2se_sub("2015",regi,te)+((s21_tax_value-p21_tau_pe2se_sub("2015",regi,te))*(ttot.val-2015)/(s21_tax_time-2015));
      p21_tau_pe2se_sub(ttot,regi,te)$(ttot.val>(s21_tax_time)) = s21_tax_value;

      p21_tau_fuEx_sub(ttot,regi,entyPE)$(ttot.val > 2015 AND ttot.val<(s21_tax_time + 1))
      =
      p21_tau_fuEx_sub("2015",regi,entyPE)+((s21_tax_value-p21_tau_fuEx_sub("2015",regi,entyPE))*(ttot.val-2015)/(s21_tax_time-2015));
      p21_tau_fuEx_sub(ttot,regi,entyPE)$(ttot.val>(s21_tax_time)) = s21_tax_value;

    );
  );
);


*** FS: switch cm_FEtax_trajectory to explicitly control tax level trajectory (overwrites cm_fetaxscen settings for the respective taxes affected), 
$ifthen.fetax not "%cm_FEtax_trajectory_abs%" == "off" 
*** from year given in cm_FEtax_trajectory_abs, set FE tax to level specified by cm_FEtax_trajectory_abs, cm_FEtax_trajectory_abs in USD/MWh -> convert to trUSD/TWa
  loop((ttot,sector,entyFe)$p21_FEtax_trajectory_abs(ttot,sector,entyFe),
*** set FE tax to cm_FEtax_trajectory_abs to year given in cm_FEtax_trajectory_abs and after
    loop(ttot2$(ttot2.val ge ttot.val),
    pm_tau_fe_tax(ttot2,regi,sector,entyFe) = p21_FEtax_trajectory_abs(ttot,sector,entyFe) * sm_TWa_2_MWh * 1e-12;
    );
*** phase-in(out) FE tax linearly before from startyear to year given in cm_FEtax_trajectory_abs
    loop(ttot2$(ttot2.val eq cm_startyear),
    pm_tau_fe_tax(t,regi,sector,entyFe)$(t.val lt ttot.val and t.val ge cm_startyear)  = (pm_tau_fe_tax(ttot,regi,sector,entyFe) - pm_tau_fe_tax(ttot2,regi,sector,entyFe))/(ttot.val - ttot2.val) * (t.val - ttot2.val) + pm_tau_fe_tax(ttot2,regi,sector,entyFe);
    );
  );
$endif.fetax


*** FS: switch cm_FEtax_trajectory_rel to scale tax trajectory relative to tax in cm_startyear (overwrites cm_fetaxscen settings for the respective taxes affected), 
$ifthen.fetaxRel not "%cm_FEtax_trajectory_rel%" == "off" 
  loop((ttot,sector,entyFe)$p21_FEtax_trajectory_rel(ttot,sector,entyFe),
    loop(ttot2$(ttot2.val eq cm_startyear),
*** set FE tax to cm_FEtax_trajectory_rel * FE tax level of cm_startyear in year given in cm_FEtax_trajectory_rel and after
      loop(ttot3$(ttot3.val ge ttot.val),
        pm_tau_fe_tax(ttot3,regi,sector,entyFe) = p21_FEtax_trajectory_rel(ttot,sector,entyFe) * pm_tau_fe_tax(ttot2,regi,sector,entyFe);
      );
*** increase or decrease FE tax level linearily before
    pm_tau_fe_tax(t,regi,sector,entyFe)$(t.val lt ttot.val and t.val ge cm_startyear)  = (pm_tau_fe_tax(ttot,regi,sector,entyFe) - pm_tau_fe_tax(ttot2,regi,sector,entyFe))/(ttot.val - ttot2.val) * (t.val - ttot2.val) + pm_tau_fe_tax(ttot2,regi,sector,entyFe);
    );
  );
$endif.fetaxRel

display pm_tau_fe_sub; 
display pm_tau_fe_tax;
display p21_tau_pe2se_sub, p21_tau_fuEx_sub;

*LB* initialization of vm_emiMac
vm_emiMac.l(ttot,regi,enty) = 0;
*LB* initialization of v21_emiALLco2neg
v21_emiALLco2neg.l(ttot,regi) =0;

*DK initialize bioenergy tax
v21_tau_bio.l(ttot) = 0;

*** FS: initialize flexibility tax
vm_flexAdj.l(ttot,all_regi,all_te) = 0;

*** FS: set market price of good to non-zero to avoid division by zero in first iteration
pm_pvp(ttot,"good")$(pm_pvp(ttot,"good") = 0) = sm_eps;

*** initialize taxrevImport
v21_taxrevImport.l(t,regi,tradePe) = 0;

*** EOF ./modules/21_tax/on/preloop.gms
