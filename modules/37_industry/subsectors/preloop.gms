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
if (cm_startyear eq 2005,
  !! TODO: get prodVol by route and read in in mrremind
  p37_specFeDem("2005",regi,"feh2s","idr","h2") = p37_specFeDemTarget("feh2s","idr","h2");
  p37_specFeDem("2005",regi,"feels","idr","h2") = p37_specFeDemTarget("feels","idr","h2");

  p37_specFeDem("2005",regi,"fegas","idr","ng") = p37_specFeDemTarget("fegas","idr","ng");
  p37_specFeDem("2005",regi,"feels","idr","ng") = p37_specFeDemTarget("feels","idr","ng");

  p37_specFeDem("2005",regi,"fesos","bf","standard") = pm_fedemand('2005',regi,'feso_steel')         * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'bf','standard');
  p37_specFeDem("2005",regi,"fehos","bf","standard") = pm_fedemand('2005',regi,'feli_steel')         * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'bf','standard');
  p37_specFeDem("2005",regi,"fegas","bf","standard") = pm_fedemand('2005',regi,'fega_steel')         * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'bf','standard');
  !!p37_specFeDem("2005",regi,"feh2s","bf","standard") = pm_fedemand('2005',regi,'feh2_steel')         * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'bf','standard');
  p37_specFeDem("2005",regi,"feels","bf","standard") = pm_fedemand('2005',regi,'feel_steel_primary') * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'bf','standard');

  p37_specFeDem("2005",regi,"feels","eaf","sec") = pm_fedemand('2005',regi,'feel_steel_secondary') * sm_EJ_2_TWa / v37_prodVolPrc.l('2005',regi,'eaf','sec');
  p37_specFeDem("2005",regi,"feels","eaf","pri") = p37_specFeDem("2005",regi,"feels","eaf","sec");

  !! loop over other years and blend
  loop(entyFeStat(all_enty),
    loop(tePrc(all_te),
      loop(opmoPrc,
        if( (p37_specFeDemTarget(all_enty,all_te,opmoPrc) gt 0.),
          loop(ttot$((ttot.val > 2005)),
            !! fedemand in excess of BAT halves until 2040
            !! gams cannot handle float exponents, so pre-compute 0.5^(1/(2040-2005)) = 0.9804
            p37_specFeDem(ttot,regi,all_enty,all_te,opmoPrc) = p37_specFeDemTarget(all_enty,all_te,opmoPrc) + (p37_specFeDem("2005",regi,all_enty,all_te,opmoPrc) - p37_specFeDemTarget(all_enty,all_te,opmoPrc)) * power(0.9804, ttot.val - 2005) ;
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
