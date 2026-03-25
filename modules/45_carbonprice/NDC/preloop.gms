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
*#'     share of emissions covered by NDC in particular region * REMIND NPI emissions in 2015 * (country-aggregated) relative NDC emissions target with respect to 2015
*#'  2. Contribution of countries within REMIND region without NDC target:
*#'     (1 - share of emissions covered by NDC in particular region) *  REMIND NPI  emissions in target year
p45_CO2eqwoLU_goal(p45_NDCyearSet(t,regi)) =
          p45_shareTarget(t,regi)     * p45_BAU_reg_emi_wo_LU_wo_bunkers("2015",regi) * p45_factorTargetyear(t,regi)    !! share with NDC target
        + (1-p45_shareTarget(t,regi)) * p45_BAU_reg_emi_wo_LU_wo_bunkers(t,regi);                                       !! baseline for share of countries without NDC target

display pm_taxCO2eq,p45_CO2eqwoLU_goal;

*** EOF ./modules/45_carbonprice/NDC/preloop.gms
