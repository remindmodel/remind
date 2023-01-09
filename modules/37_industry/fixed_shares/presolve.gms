*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/presolve.gms

*** zero out a ghost
vm_macBase.fx(ttot,regi,emiInd37_fuel) = 0;

*** adjust CO2 cement process emissions
if (cm_IndCCSscen eq 1 AND cm_CCS_cement eq 1,

  !! lowest price for which abatement equals current abatement
  pm_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = max(0,
        smin(steps$(   pm_abatparam_Ind(ttot,regi,"co2cement",steps)
                    ge pm_macAbatLev(ttot,regi,"co2cement") ),
          steps.val - 1.5 !! average upper and lower step
        )
    )
  * sm_dMAC;

  display "Marginal cost of Cement Demand Reduction [$/tC]",
          pm_CementAbatementPrice;

  !! mix prices of residual and abated emissions
  pm_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = ( (1 - pm_macAbatLev(ttot,regi,"co2cement")) * pm_priceCO2forMAC(ttot,regi,"co2cement")
    + ( pm_macAbatLev(ttot,regi,"co2cement")
      * pm_CementAbatementPrice(ttot,regi)
      )
    )
  / sm_C_2_CO2;

  display "Mixed price of CO2 for Cement Demand Reduction [$/tCO2]",
          pm_CementAbatementPrice;

  pm_ResidualCementDemand("2005",regi) = 1;
  pm_ResidualCementDemand(ttot,regi)$( ttot.val gt 2005 )
  = 160 / (pm_CementAbatementPrice(ttot,regi) + 200) + 0.2;

  display "Cement Demand Reduction as computed", pm_ResidualCementDemand;
  
  !! Demand can only be reduced by 1% p.a.
  loop (ttot$( ttot.val gt 2005 ),
    pm_ResidualCementDemand(ttot,regi)
    = max(pm_ResidualCementDemand(ttot,regi),
          ( pm_ResidualCementDemand(ttot-1,regi)
          - 0.01 * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
          )
      );
  );

  display "Cement Demand Reduction, limited to 1% p.a.",
          pm_ResidualCementDemand;

  pm_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = 160 / (pm_ResidualCementDemand(ttot,regi) - 0.2) - 200;

  display "Cement Demand Reduction, price of limited reduction",
          pm_CementAbatementPrice;

  pm_CementDemandReductionCost(ttot,regi)$( ttot.val ge 2005 )
  = ( 160 * log(pm_CementAbatementPrice(ttot,regi) + 200) 
    + 0.2 * pm_CementAbatementPrice(ttot,regi)
    - 160 * log(200)
    - pm_ResidualCementDemand(ttot,regi) * pm_CementAbatementPrice(ttot,regi)
    )$( pm_CementAbatementPrice(ttot,regi) gt 0 )
  / 1000
  * vm_macBase.lo(ttot,regi,"co2cement_process");

  display "Cement Demand Reduction cost", pm_CementDemandReductionCost;

  vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process")
  * pm_ResidualCementDemand(ttot,regi);

  vm_macBaseInd.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process");
);


*** EOF ./modules/37_industry/fixed_shares/presolve.gms

