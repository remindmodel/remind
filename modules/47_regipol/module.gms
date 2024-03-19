*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
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
*'               On the emissions targets: Emissions targets can be activated via the switch cm_emiMktTarget and there are number of options that can be chosen to specify them
*'               like the type of target (annual target or budget), the target year, the regions the target should be applied to,
*'               the emissions metric (CO2, GHG, CO2 excl. bunkers/LULUCF etc.) and the emissions market (all, ETS, ESR). For example, setting cm_emiMktTarget to
*'               "2020.2030.EU27_regi.all.year.netGHG_noLULUCF_noBunkers 3.16, 2035.2050.EU27_regi.all.year.netCO2 0.001" will apply two emissions targets to the region group "EU27_regi"
*'               which consists of all model regions in the EU27 (for the definition of region groups, please see definition of the set regi_group): The first is a target of 3.16 GtCO2eq/yr annual ("year") emissions by 2030
*'               in the metric of net greenhouse gas emissions without LULUCF and bunkers ("netGHG_noLULUCF_noBunkers", for definition of emissions metrics see modules/47_regipol/regiCarbonPrice/postsolve.gms)
*'               for all emissions markets ("all"). The second defines a target of 1 Mt CO2/yr annual ("year") emissions by 2050 in the metric of net CO2 emissions ("netCO2") for all emissions markets ("all").
*'               For details on the options please see the description of the switch.
*'               When an emissions target is set via this switch, the carbon price in the target years and regions, to which it is applied, is adjusted over nash iterations in REMIND
*'               until the desired emissions target is reached within a certain margin of tolerance defined by cm_emiMktTarget_tolerance. Note that also multiple emissions targets can be specified for
*'               different years (e.g. the EU's 2030 and 2050 targets). The carbon price trajectory up to the target years are linear and the carbon price
*'               is assumed to still increase linearly at a small rate after the last target year. Please check the parameter pm_emiMktTarget_dev_iter to see the emissions target convergence over iterations.
*'               Note that these regional emissions targets of the module only overwrite the carbon price trajectory for the regions they are applied to, while the other regions keep the carbon price trajectories
*'               that are adjusted in other parts of the model, in particular, from the global emissions target adjustment.
*'               This means that these regional targets come on top of the global emissions target that REMIND aims to achieve.
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
