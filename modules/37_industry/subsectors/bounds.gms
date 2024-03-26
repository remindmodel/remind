*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
$ifthen.rcp_scen "%cm_rcp_scen%" == "none"
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
$elseif.rcp_scen "%cm_rcp_scen%" == "rcp85"
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
$elseif.rcp_scen "%cm_rcp_scen%" == "rcp60"
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
$elseif.rcp_scen "%cm_rcp_scen%" == "rcp45"
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
$else.rcp_scen
  !! In policy scenarios, secondary steel production can be increased up to the
  !! limit of theoretical scrap availability.
  vm_cesIO.up(t,regi,"ue_steel_secondary")
    = p37_cesIO_up_steel_secondary(t,regi,"%cm_GDPscen%");
$endif.rcp_scen
$endif.secondary_steel_bound
$endif.CES_parameters

vm_cesIO.fx("2005",regi,ppfKap_industry_dyn37(in))
  = max(
      pm_cesdata("2005",regi,in,"quantity"),
      abS(pm_cesdata("2005",regi,in,"offset_quantity"))
    );

*** Set lower bound for secondary steel electricity to 1 % of the lowest
*** existing lower bound (should be far above sm_eps) to avoid CONOPT getting
*** lost in the woods.
loop (in$( sameas(in,"feel_steel_secondary") ),
  vm_cesIO.lo(t,regi,in)$(    t.val ge cm_startyear
                          AND vm_cesIO.lo(t,regi,in) le sm_eps )
  = max(
      sm_eps,
      (  0.01
      * smax(ttot$( vm_cesIO.lo(ttot,regi,in) gt sm_eps),
          vm_cesIO.lo(ttot,regi,in)
        )
      ),
      abs(pm_cesdata(t,regi,in,"offset_quantity"))
    );
);

*** Default lower bounds on all industry pfs
vm_cesIO.lo(t,regi_dyn29(regi),in_industry_dyn37(in))$(
                                                  0 eq vm_cesIO.lo(t,regi,in) )
  = max(sm_eps, abs(pm_cesdata(t,regi,in,"offset_quantity")));

*' Limit biomass solids use in industry to 25% (or historic shares, if they are 
*' higher) of baseline solids
*' Cement CCS might otherwise become a compelling BioCCS option under very high
*' carbon prices due to missing adjustment costs.
if (cm_startyear gt 2005,   !! not a baeline or NPi scenario
  vm_demFeSector_afterTax.up(t,regi,"sesobio","fesos","indst","ETS")
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


$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "processes"
!! fix processes procudction in historic years
if (cm_startyear eq 2005,
  loop(regi,
    loop(tePrc2opmoPrc(tePrc,opmoPrc),
      vm_outflowPrc.fx('2005',regi,tePrc,opmoPrc) = pm_outflowPrcIni(regi,tePrc,opmoPrc);
    );
  );

  loop(regi,
    loop(ttot$(ttot.val ge 2005 AND ttot.val le 2020),
      vm_outflowPrc.fx(ttot,regi,'eaf','pri') = 0.;
      vm_outflowPrc.fx(ttot,regi,'idr','ng') = 0.;
      vm_outflowPrc.fx(ttot,regi,'idr','h2') = 0.;
      vm_outflowPrc.fx(ttot,regi,'bfcc','standard') = 0.;
      vm_outflowPrc.fx(ttot,regi,'idrcc','ng') = 0.;
    );
  );
);

!! Switch to turn off steel CCS
if (cm_CCS_steel ne 1 OR cm_IndCCSscen ne 1,
  vm_cap.fx(t,regi,teCCPrc,rlf) = 0.;
);
$endif.cm_subsec_model_steel

*** Populate values for v37_demFeIndst to ease introduction of new variale.  Can
*** be removed once the variable is established.
v37_demFeIndst.l(t,regi,entySe,entyFe,out,emiMkt) = 0;
loop ((t,regi,entySe,entyFe,out,emiMkt,secInd37,in)$(
            sefe(entySe,entyFe)
        AND sector2emiMkt("indst",emiMkt)
        AND secInd37_emiMkt(secInd37,emiMkt)
        AND secInd37_2_pf(secInd37,out)
        AND ue_industry_2_pf(out,in)
        AND fe2ppfEn37(entyFe,in)
        AND sum(se2fe(entySe,entyFe,te),
              vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,"indst",emiMkt)
            )                                                                ),
  v37_demFeIndst.l(t,regi,entySe,entyFe,out,emiMkt)
  = sum((fe2ppfEn37_2(entyFe,in),ue_industry_2_pf(out,in)),
      vm_cesIO.l(t,regi,in)
    + pm_cesdata(t,regi,in,"offset_quantity")
    )
  * vm_demFeSector_afterTax.l(t,regi,entySe,entyFe,"indst",emiMkt)
  / sum(se2fe(entySe2,entyFe,te),
      vm_demFeSector_afterTax.l(t,regi,entySe2,entyFe,"indst",emiMkt)
    );
);
*** EOF ./modules/37_industry/subsectors/bounds.gms
