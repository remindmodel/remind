*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/bounds.gms

*** $include "./modules/37_industry/subsectors/input/vm_cesIO_scales.inc";
$ontext
vm_cesIO.scale(ttot(t2),regi,in_industry_dyn37(in))$(
                                        NOT tsu(t2) AND vm_cesIO.l(t2,regi,in) )
  = sum(tttot(t)$( NOT tsu(t) ), vm_cesIO.l(t,regi,in))
  / (card(ttot) - card(tsu));
$offtext
$ifthen.CES_parameters "%CES_parameters%" eq "calibrate"
  vm_cesIO.scale(t,regi_dyn29(regi),in_industry_dyn37(in))
  = pm_cesdata(t,regi,in,"quantity");
$endif.CES_parameters

*** Include upper bounds on secondary steel production, due to scarcity of
*** steel scrap.
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

$ontext
loop ((t,in_industry_dyn37(in))$( 
                      NOT (t0(t) OR industry_ue_calibration_target_dyn37(in)) ),
  vm_cesIO.lo(t,regi,in)$(    vm_cesIO.lo(t,regi,in) ne 0 
                          AND vm_cesIO.lo(t,regi,in) ne vm_cesIO.up(t,regi,in) )
  = 1e-12$( NOT pm_cesdata(t,regi,in,"offset_quantity") )
  - pm_cesdata(t,regi,in,"offset_quantity")$(
                                      pm_cesdata(t,regi,in,"offset_quantity") );
);
$offtext

vm_cesIO.lo(t,regi,in_industry_dyn37(in))$( 
               NOT (t0(t) OR vm_cesIO.lo(t,regi,in) eq vm_cesIO.up(t,regi,in)) )
  = 1e-12$( NOT pm_cesdata(t,regi,in,"offset_quantity") )
  - pm_cesdata(t,regi,in,"offset_quantity");

vm_cesIO.fx("2005",regi,ppfkap_industry_dyn37(in))
  = pm_cesdata("2005",regi,in,"quantity");

$ifthen.calibration "%CES_parameters%" == "calibrate" !! CES_parameters
$ifthen.FE_target "%c_CES_calibration_industry_FE_target%" == "1" !! c_CES_calibration_industry_FE_target
$ifthen.first_iteration "%c_CES_calibration_iteration%" == "1" !! c_CES_calibration_iteration
!! vm_cesIO.fx(t_29(t),regi,ppf_industry_dyn37(in))
!!   = pm_cesdata(t,regi,in,"quantity");

loop (t0,
  vm_cesIO.lo(t_29(t),regi_dyn29(regi),ppf_industry_dyn37(in))$( NOT t0(t) )
    = pm_cesdata(t,regi,in,"quantity")
    * 0.9;
  
  vm_cesIO.up(t_29(t),regi_dyn29(regi),ppf_industry_dyn37(in))$( NOT t0(t) )
    = pm_cesdata(t,regi,in,"quantity")
    * 1.1;
);
$endif.first_iteration
$endif.FE_target
$endif.calibration

*** EOF ./modules/37_industry/subsectors/bounds.gms

