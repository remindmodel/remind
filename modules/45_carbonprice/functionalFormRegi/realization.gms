*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/functionalFormRegi/realization.gms

*' @description Carbon price trajectory follows a prescribed functional form (linear/exponential) - either until peak year or until end-of-century.
*'               It is endogenously adjusted to meet regional end-of-century CO2 budget targets.
*'
*' Switches to set:
*'
*' *Budget allocation and tolerance:*
*' - cm_budgetCO2from2020: the budget to be distributed across regions (Gt CO2 eq) (analogous to functionalForm)
*' - c_budgetscen: chose the emission types included in the budget calculation that determines the carbon price. 
*'    For GHG budgets, remember to adjust the value for cm_budgetCO2from2020#
*' - cm_budgetCO2from2020RegiShare: the share of the global carbon budget allocated to each region
*' - cm_budgetCO2_absDevTol: the absolute deviation tolerance for budget convergence for *each region* individually. 
*'    I.e. precision is different from the application in functionalForm!
*'
*' *Carbon price shape settings:*
*' - cm_taxCO2_functionalForm: shape of the carbon price trajectory (linear/exponential) (analogous to functionalForm)
*' - cm_CPslopeAdjustment: for linear carbon price, determines whether the slope is of the carbon price is adjusted or whether the line is just shifted up/donw
*' - cm_taxCO2_Shape: 1 if the carbon price peaks in 2100, 2 if it peaks in a specified year (analogous to functionalForm for EoC Budgets)
*'
*' To *exogenously* set a peak carbon price year(s):  (cm_taxCO2_Shape eq 2)
*' - cm_peakBudgYrRegi: prescribe a specific peak year for each region
*' - cm_peakBudgYr:  prescribe a global peak year, which is then applied to all regions. Used if cm_peakBudgYrRegi == "off"
*' - cm_taxCO2_IncAfterPeakBudgYr: set the increase of the carbon price after the peak
*'
*' *Other relevant switches:*
*' - cm_useInputGdxForCarbonPrice: if 1, carbon price is read from input GDX.
*'    If 0, carbon price is calculated as in the functional form approach.
*'    Set to 1 e.g. in case of convergence issues when using the input.gdx from a previous run.
*' - cm_frac_NetNegEmi: Need to decide whether the net negative emissions tax should be turned off depending on the specific scenario configuration.
*'
*' *Comments:*
*' - Runs with very relaxed budgets for some regions may not converge if cm_taxCO2_lowerBound_path_gdx_ref = 1 because the carbon price cannot decrease sufficiently.
*'   However, if the carbon price drops below 1 USD/tCO2 in 2100 and the budget is still underachieved, region will appear converged (see 80_optimization/nash/postsolve.gms)
*' - Regional carbon price adjustments sometimes oscillate. Try another input GDX, or adjust the iteration number after which carbon price rescaling is allowed only in one direction.
*' - Regions sometimes get carbon prices <1 USD/tCO2, which sometimes causes convergence issues because the multiplying rescaling factors do not
*'       increase the carbon price sufficiently anymore.


*' This realization was originally introduced with PR#2222.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/45_carbonprice/functionalFormRegi/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/45_carbonprice/functionalFormRegi/datainput.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/45_carbonprice/functionalFormRegi/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/45_carbonprice/functionalFormRegi/realization.gms
