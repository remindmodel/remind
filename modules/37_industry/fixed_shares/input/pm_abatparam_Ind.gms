*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

loop ((ttot,steps)$( ttot.val ge 2005 ),

  sm_tmp = steps.val * sm_dmac / sm_c_2_co2;   !! CO2 price at MAC step [$/tCO2] 

$ifthen NOT "%cm_Industry_CCS_markup%" == "off"
  sm_tmp = sm_tmp / %cm_Industry_CCS_markup%;
$endif

  !! short-term (until 2025)
  if (ttot.val le 2025,

    pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge  sm_D2005_2_D2017 * 95 ) = 0.63;
    pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge sm_D2005_2_D2017 *133 ) = 0.756;

    pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge sm_D2005_2_D2017 *78 ) = 0.121;
    pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge sm_D2005_2_D2017 *80 ) = 0.572;

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge sm_D2005_2_D2017 *59 ) = 0.117;
    pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge sm_D2005_2_D2017 *82 ) = 0.234;
$endif.cm_subsec_model_steel

  !! long-term (from 2030 on)
  else

    if (cm_optimisticMAC eq 1,

      !! logarithmic curve through 0.75 @ $50 and 0.9 @ $150, limited to 0.95
      pm_abatparam_Ind(ttot,regi,emiInd37,steps)$( 
                                              YES
        $$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
                                          AND NOT sameas(emiInd37,"co2steel")
        $$endif.cm_subsec_model_steel
                                                                              )
      = max(0, min(0.95, 0.2159 + 0.1365 * log(sm_tmp)));

    else
      pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge  sm_D2005_2_D2017 * 54 ) = 0.702;
      pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge sm_D2005_2_D2017 * 133 ) = 0.756;

      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge sm_D2005_2_D2017 * 46 ) = 0.363;
      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge sm_D2005_2_D2017 * 78 ) = 0.484;
      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge sm_D2005_2_D2017 *80 )  = 0.572;

$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
      pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge sm_D2005_2_D2017 *48 ) = 0.117;
      pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge sm_D2005_2_D2017 *62 ) = 0.275;
$endif.cm_subsec_model_steel
    );
  );
);

*** EOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

