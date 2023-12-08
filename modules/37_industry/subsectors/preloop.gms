*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/preloop.gms

*** initialize captured CO2 parameter
pm_IndstCO2Captured(t,regi,entySe,entyFe,secInd37,emiMkt) = 0;

$ifthen.process_based_steel "%cm_process_based_steel%" == "on"             !! cm_process_based_steel
* TODO:
* - Add idr historic capacities
* - make this a loop to not require additional code for new materials
if (cm_startyear eq 2005,
  v37_outflowPrc.fx('2005',regi,'bof','unheated') = pm_fedemand('2005',regi,'ue_steel_primary');
  v37_outflowPrc.fx('2005',regi,'bf','standard') = p37_specMatDem("pigiron","bof","unheated") * v37_outflowPrc.l('2005',regi,'bof','unheated');
  v37_outflowPrc.fx('2005',regi,'eaf','sec') = pm_fedemand('2005',regi,'ue_steel_secondary');
  v37_outflowPrc.fx('2005',regi,'eaf','pri') = 0.;
  v37_outflowPrc.fx('2005',regi,'idr','ng') = 0.;
  v37_outflowPrc.fx('2005',regi,'idr','h2') = 0.;

  !! TODO: get outflow by route and read in in mrremind
  loop(ttot$(ttot.val ge 2005 AND ttot.val le 2020),
    p37_specFeDem(ttot,regi,"feh2s","idr","h2") = p37_specFeDemTarget("feh2s","idr","h2");
    p37_specFeDem(ttot,regi,"feels","idr","h2") = p37_specFeDemTarget("feels","idr","h2");

    p37_specFeDem(ttot,regi,"fegas","idr","ng") = p37_specFeDemTarget("fegas","idr","ng");
    p37_specFeDem(ttot,regi,"feels","idr","ng") = p37_specFeDemTarget("feels","idr","ng");

    p37_specFeDem(ttot,regi,"fesos","bf","standard") = pm_fedemand(ttot,regi,'feso_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    p37_specFeDem(ttot,regi,"fehos","bf","standard") = pm_fedemand(ttot,regi,'feli_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    p37_specFeDem(ttot,regi,"fegas","bf","standard") = pm_fedemand(ttot,regi,'fega_steel')         * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );
    p37_specFeDem(ttot,regi,"feels","bf","standard") = pm_fedemand(ttot,regi,'feel_steel_primary') * sm_EJ_2_TWa / ( p37_specMatDem("pigiron","bof","unheated") * pm_fedemand(ttot,regi,'ue_steel_primary') );

    p37_specFeDem(ttot,regi,"feels","eaf","sec") = pm_fedemand(ttot,regi,'feel_steel_secondary') * sm_EJ_2_TWa / pm_fedemand(ttot,regi,'ue_steel_secondary');
    p37_specFeDem(ttot,regi,"feels","eaf","pri") = p37_specFeDem(ttot,regi,"feels","eaf","sec");
  );

  !! loop over other years and blend
  loop(entyFeStat(all_enty),
    loop(tePrc(all_te),
      loop(opmoPrc,
        if( (p37_specFeDemTarget(all_enty,all_te,opmoPrc) gt 0.),
          loop(ttot$(ttot.val > 2020),
            !! fedemand in excess of BAT halves until 2055
            !! gams cannot handle float exponents, so pre-compute 0.5^(1/(2055-2020)) = 0.9804
            p37_specFeDem(ttot,regi,all_enty,all_te,opmoPrc) = p37_specFeDemTarget(all_enty,all_te,opmoPrc) + (p37_specFeDem("2020",regi,all_enty,all_te,opmoPrc) - p37_specFeDemTarget(all_enty,all_te,opmoPrc)) * power(0.9804, ttot.val - 2020) ;
          );
        );
      );
    );
  );
);

if (cm_startyear gt 2005,
  Execute_Loadpoint 'input_ref' p37_specFeDem = p37_specFeDem;
);
$endif.process_based_steel

*** EOF ./modules/37_industry/subsectors/preloop.gms
