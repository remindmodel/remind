*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/presolve.gms

vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 )
  = ( pm_pop(ttot,regi)
    * ( (1 - p_switch_cement(ttot,regi))
      * p_emineg_econometric(regi,"co2cement_process","p1")
      * ( (1000
          * p_inv_gdx(ttot,regi)
          / ( pm_pop(ttot,regi)
            * pm_shPPPMER(regi)
            )
          ) ** p_emineg_econometric(regi,"co2cement_process","p2")
         )
      + ( p_switch_cement(ttot,regi)
        * p_emineg_econometric(regi,"co2cement_process","p3")
        )
       )
    )$(p_inv_gdx(ttot,regi) ne 0)
;

vm_emiIndBase.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
= vm_macBase.lo(ttot,regi,"co2cement_process");

*** adjust CO2 cement process emissions
if (cm_IndCCSscen eq 1 AND cm_CCS_cement eq 1,

  !! lowest price for which abatement equals current abatement
  p37_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = max(0,
        smin(steps$(   pm_abatparam_Ind(ttot,regi,"co2cement",steps)
                    ge pm_macAbatLev(ttot,regi,"co2cement") ),
          steps.val - 1.5 !! average upper and lower step
        )
    )
  * sm_dmac;

  display "Marginal cost of Cement Demand Reduction [$/tC]",
          p37_CementAbatementPrice;

  !! mix prices of residual and abated emissions
  p37_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = ( (1 - pm_macAbatLev(ttot,regi,"co2cement")) * pm_priceCO2forMAC(ttot,regi,"co2cement")
    + ( pm_macAbatLev(ttot,regi,"co2cement")
      * p37_CementAbatementPrice(ttot,regi)
      )
    )
  / sm_c_2_co2;

  display "Mixed price of CO2 for Cement Demand Reduction [$/tCO2]",
          p37_CementAbatementPrice;

  p37_ResidualCementDemand("2005",regi) = 1;
  p37_ResidualCementDemand(ttot,regi)$( ttot.val gt 2005 )
  = 160 / (p37_CementAbatementPrice(ttot,regi) + 200) + 0.2;

  display "Cement Demand Reduction as computed", p37_ResidualCementDemand;

  !! Demand can only be reduced by 1% p.a.
  loop (ttot$( ttot.val gt 2005 ),
    p37_ResidualCementDemand(ttot,regi)
    = max(p37_ResidualCementDemand(ttot,regi),
          ( p37_ResidualCementDemand(ttot-1,regi)
          - 0.01 * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
          )
      );
  );

  display "Cement Demand Reduction, limited to 1% p.a.",
          p37_ResidualCementDemand;

  p37_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = 160 / (p37_ResidualCementDemand(ttot,regi) - 0.2) - 200;

  display "Cement Demand Reduction, price of limited reduction",
          p37_CementAbatementPrice;

  pm_CementDemandReductionCost(ttot,regi)$( ttot.val ge 2005 )
  = ( 160 * log(p37_CementAbatementPrice(ttot,regi) + 200)
    + 0.2 * p37_CementAbatementPrice(ttot,regi)
    - 160 * log(200)
    - p37_ResidualCementDemand(ttot,regi) * p37_CementAbatementPrice(ttot,regi)
    )$( p37_CementAbatementPrice(ttot,regi) gt 0 )
  / 1000
  * vm_macBase.lo(ttot,regi,"co2cement_process");

  display "Cement Demand Reduction cost", pm_CementDemandReductionCost;

  vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process")
  * p37_ResidualCementDemand(ttot,regi);

  vm_emiIndBase.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process");


else

*** Cement (clinker) production causes process emissions of the order of
*** 0.5 t CO2/t Cement. As cement prices are of the magnitude of 100 $/t, CO2
*** pricing leads to significant price markups.

  p37_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = pm_priceCO2forMAC(ttot,regi,"co2cement") / sm_c_2_co2;

  display "CO2 price for computing Cement Demand Reduction [$/tC]",
          p37_CementAbatementPrice;

  !! The demand reduction function a = 160 / (p + 200) + 0.2 assumes that demand
  !!  for cement is reduced by 40% if the price doubles (CO2 price of $200) and
  !!  that demand reductions of 80% can be achieved in the limit.
  p37_ResidualCementDemand("2005",regi) = 1;
  p37_ResidualCementDemand(ttot,regi)$( ttot.val gt 2005 )
  = 160 / (p37_CementAbatementPrice(ttot,regi) + 200) + 0.2;

  display "Cement Demand Reduction as computed", p37_ResidualCementDemand;

  !! Demand can only be reduced by 1% p.a.
  loop (ttot$( ttot.val gt 2005 ),
    p37_ResidualCementDemand(ttot,regi)
    = max(p37_ResidualCementDemand(ttot,regi),
          ( p37_ResidualCementDemand(ttot-1,regi)
          - 0.01 * (pm_ttot_val(ttot) - pm_ttot_val(ttot-1))
          )
      );
  );

  display "Cement Demand Reduction, limited to 1% p.a.",
          p37_ResidualCementDemand;

  p37_CementAbatementPrice(ttot,regi)$( ttot.val ge 2005 )
  = 160 / (p37_ResidualCementDemand(ttot,regi) - 0.2) - 200;

  display "Cement Demand Reduction, price of limited reduction",
          p37_CementAbatementPrice;

  !! Costs of cement demand reduction are the integral under the activity
  !! reduction curve times baseline emissions.
  !! a = 160 / (p + 200) + 0.2
  !! A = 160 ln(p + 200) + 0.2p
  !! A_MAC(p*) = A(p*) - A(0) - a(p*)p*
  pm_CementDemandReductionCost(ttot,regi)$( ttot.val ge 2005 )
  = ( 160 * log(p37_CementAbatementPrice(ttot,regi) + 200)
    + 0.2 * p37_CementAbatementPrice(ttot,regi)
    - 160 * log(200)
    - p37_ResidualCementDemand(ttot,regi) * p37_CementAbatementPrice(ttot,regi)
    )$( p37_CementAbatementPrice(ttot,regi) gt 0 )
  / 1000
  * vm_macBase.lo(ttot,regi,"co2cement_process");

  display "Cement Demand Reduction cost", pm_CementDemandReductionCost;

  vm_macBase.fx(ttot,regi,"co2cement_process")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process")
  * p37_ResidualCementDemand(ttot,regi);

  vm_emiIndBase.fx(ttot,regi,"co2cement_process","cement")$( ttot.val ge 2005 )
  = vm_macBase.lo(ttot,regi,"co2cement_process");
);

*** EOF ./modules/37_industry/fixed_shares/presolve.gms

