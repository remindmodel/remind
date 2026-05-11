*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NDC/preloop.gms


*#' @equations 
*#'  calculate level of emission target per REMIND region. It is componsed to two terms:
*#'  1. Contribution of countries within REMIND region with NDC target: 
*#'     Absolute NDC emissions target that was derived by summing the targets of all countries within the region that have NDC targets
*#'  2. Contribution of countries within REMIND region without NDC target:
*#'     (1 - share of emissions covered by NDC in particular region) *  REMIND NPI  emissions in target year
p45_CO2eqwoLU_goal(p45_NDCyearSet(t,regi)) =
          p45_EmiTargetAbs(t,regi)                                                  !! emissions target derived from countries with NDC target
        + (1-p45_shareTarget(t,regi)) * p45_BAU_reg_emi_wo_LU_wo_bunkers(t,regi);   !! countries without NDC target are assumed to follow NPI emissions pathway

display pm_taxCO2eq,p45_CO2eqwoLU_goal;

*** EOF ./modules/45_carbonprice/NDC/preloop.gms
