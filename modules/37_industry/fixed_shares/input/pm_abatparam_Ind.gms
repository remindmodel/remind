*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

loop ((ttot,steps)$( ttot.val ge 2005 ),

  sm_tmp = steps.val * sm_dmac / sm_C_2_CO2;   !! CO2 price at MAC step [$/tCO2] 

  !! short-term (until 2025)
  if (ttot.val le 2025,

    pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge  95 ) = 0.63;
    pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge 133 ) = 0.756;

    pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge 78 ) = 0.121;
    pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge 80 ) = 0.572;

    pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge 59 ) = 0.117;
    pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge 82 ) = 0.234;

  !! long-term (from 2030 on)
  else

    if (cm_optimisticMAC eq 1,

      !! logarithmic curve through 0.75 @ $50 and 0.9 @ $150, limited to 0.95
      pm_abatparam_Ind(ttot,regi,emiInd37,steps)
      = max(0, min(0.95, 0.2159 + 0.1365 * log(sm_tmp)));

    else
      pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge  54 ) = 0.702;
      pm_abatparam_Ind(ttot,regi,"co2cement",steps)$( sm_tmp ge 133 ) = 0.756;

      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge 46 ) = 0.363;
      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge 78 ) = 0.484;
      pm_abatparam_Ind(ttot,regi,"co2chemicals",steps)$( sm_tmp ge 80 ) = 0.572;

      pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge 48 ) = 0.117;
      pm_abatparam_Ind(ttot,regi,"co2steel",steps)$( sm_tmp ge 62 ) = 0.275;
    );
  );
);

*** EOF ./modules/37_industry/fixed_shares/input/pm_abatparam_Ind.gms

