*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/bounds.gms

$ifthen.CES_parameters "%CES_parameters%" == "calibrate"
  vm_cesIO.scale(t,regi_dyn29(regi),in_industry_dyn37(in))
  = pm_cesdata(t,regi,in,"quantity");
$endif.CES_parameters

*** Include upper bounds on secondary steel production, due to scarcity of
*** steel scrap.
$ifthen.CES_parameters NOT "%CES_parameters%" == "calibrate"   !! CES_parameters
$ifthen.secondary_steel_bound "%cm_secondary_steel_bound%" == "yearly"
vm_cesIO.up(ttot,regi,"ue_steel_secondary")
  = min(
      vm_cesIO.up(ttot,regi,"ue_steel_secondary"),
      p37_cesIO_up_steel_secondary(ttot,regi,"%cm_GDPscen%")
    );
$elseif.secondary_steel_bound "%cm_secondary_steel_bound%" == "scenario"
if (1 eq cm_emiscen,
  !! In no-policy scenarios, tight bounds representing usual scrap recycling
  !! rates apply.  Only 10% of the difference between projected secondary
  !! steel production and the upper bound with increased recycling rates are
  !! available for increased production.
  vm_cesIO.up(t,regi,"ue_steel_secondary")
    = ( ( p37_cesIO_up_steel_secondary(t,regi,"%cm_GDPscen%")
        / pm_fedemand(t,regi,"ue_steel_secondary")
        - 1
        )
      / 10
      + 1
      )
    * pm_fedemand(t,regi,"ue_steel_secondary");
else
  !! In policy scenarios, secondary steel production can be increased up to the
  !! limit of theoretical scrap availability.
  vm_cesIO.up(t,regi,"ue_steel_secondary")
    = p37_cesIO_up_steel_secondary(t,regi,"%cm_GDPscen%");
);
$endif.secondary_steel_bound
$endif.CES_parameters

vm_cesIO.fx("2005",regi,ppfkap_industry_dyn37(in))
  = pm_cesdata("2005",regi,in,"quantity");

vm_cesIO.lo(t,regi_dyn29(regi),in_industry_dyn37(in))$( 
                                                  0 eq vm_cesIO.lo(t,regi,in) )
  = sm_eps;

*' Limit biomass solids use in industry to 25% (or historic shares, if they are higher)
*' of baseline solids
*' Cement CCS might otherwise become a compelling BioCCS option under very high
*' carbon prices due to missing adjustment costs.
if (cm_emiscen ne 1,   !! not a BAU scenario
  vm_demFEsector.up(t,regi,"sesobio","fesos","indst","ETS")
  = max(0.25 , smax(t2, pm_secBioShare(t2,regi,"fesos","indst") ) )
    * p37_BAU_industry_ETS_solids(t,regi);
);

!! Fix industry output for Bal and EnSec scenario
$if "%cm_indstExogScen%" == "forecast_bal"   $set cm_indstExogScen_set "YES"
$if "%cm_indstExogScen%" == "forecast_ensec" $set cm_indstExogScen_set "YES"
$ifthen.policy_scenario "%cm_indstExogScen_set%" == "YES"
  vm_cesIO.fx(t,regi,in)$( p37_industry_quantity_targets(t,regi,in) )
  = p37_industry_quantity_targets(t,regi,in);
$endif.policy_scenario
$drop cm_indstExogScen_set

*** EOF ./modules/37_industry/subsectors/bounds.gms
