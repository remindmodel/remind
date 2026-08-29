*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/module.gms

*' @title Regional Policies
*'
*' @description  The 47_regipol module includes region-specific policies and adjustments on top of the generic parts in the core and other modules.
*'
*'
*'               The `regiCarbonPrice` realization has two purposes. First, it allows to determine region specific year or budget targets for CO2 or GHG emissions.
*'               Second, it comprises region-specific adjustments that are always active in this realization and policies that can be activated by specific switches (see modules/47_regipol/regiCarbonPrice/bounds.gms).
*'               On the emissions targets: activated via `cm_emiMktTarget`, which takes one or more targets of the form
*'               `<startYear>.<targetYear>.<region>.<market>.<year|budget>.<metric> <value>`, e.g.
*'               "2020.2030.EU27_regi.all.year.netGHG_noLULUCF_noBunkers 3.16" for a 3.16 GtCO2eq/yr EU27 target in 2030 covering all
*'               emission markets. Targets may be annual or cumulative budgets, apply to a region or a region group, to all markets or to
*'               ETS/ESR/other alone, and use any of the emission metrics in the emi_type_47 set (see regiCarbonPrice/postsolve.gms).
*'               When a target is set, the carbon price of the affected regions and years is adjusted over the nash iterations until the
*'               emissions land within `cm_emiMktTarget_tolerance` of the target. Several target years per region are solved sequentially.
*'               These regional targets OVERRIDE the carbon price for their regions only - other regions keep the price they get from the
*'               global emissions target - so they come on top of it. `pm_emiMktTarget_dev_iter` is the per-iteration deviation to inspect.
*'               How the convergence algorithm works, every case it handles, all of its parameters and how to diagnose a run:
*'               tutorials/19_RegionalEmissionTargets.md
*'               On the regional bounds and adjustments: In the bounds file, there are a number of regionally hard-coded bounds to the model that aim to improve the representation of specific regions in REMIND.
*'               They come on top of the bounds in the core of REMIND. The difference is that core defines bounds for all regions, while in this module region-specific adjustments are made which have not yet been generalized to all regions
*'               and are not activated outside of the realization "regiCarbonPrice".
*'               These bounds either serve to align REMIND with historic and near-term data in specific regions or represent regional policies (like national coal phase-out plans) that can be activated via switches.
*'               Finally, there are some regional adjustments in the datainput file that modify input data for specific regions for cases which have not been generalized for all REMIND regions yet.
*'
*' @authors Renato Rodrigues, Felix Schreyer

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%regipol%" == "none" $include "./modules/47_regipol/none/realization.gms"
$Ifi "%regipol%" == "regiCarbonPrice" $include "./modules/47_regipol/regiCarbonPrice/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/47_regipol/module.gms
