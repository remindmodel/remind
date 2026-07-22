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
*'               ## Glossary of Carbon Price Rescaling Terms
*'
*'               * **Target Deviation**: The fractional difference between current iteration emissions and the specified emissions target, normalized by a reference year's emissions. The algorithm drives this deviation toward zero (within a specified tolerance band) by adjusting the carbon tax.
*'               * **Rescale Factor**: The multiplicative factor applied to the regional carbon tax at the end of each outer (Nash) iteration. A value of 1.0 means no change; > 1 raises the tax; < 1 lowers it.
*'               * **Rescale Slope**: The estimated marginal sensitivity of regional emissions to the carbon tax in a given emission market (change in emissions / change in price). Expected to be negative (higher price leads to lower emissions). Computed from the current iteration and a baseline reference iteration.
*'               * **Slope Reference Iteration**: The baseline outer iteration used to compute the Rescale Slope. It is reset when the target changes, when the slope window is exceeded, or when a degenerate slope is detected to ensure the computed slope reflects the local abatement cost curve.
*'               * **Slope Window**: The maximum allowed number of iterations between the current outer iteration and the Slope Reference Iteration. If the reference becomes older than this threshold, it is forced to reset.
*'               * **SquareDev Fallback**: A robust fallback method that bypasses the Rescale Slope entirely and computes the tax rescale factor quadratically as `(1 + target_deviation)^2`. Used when reliable slope information is unavailable or degenerate.
*'               * **Degenerate Slope**: A condition where the change in emissions (slope numerator) is negligibly small relative to the reference year's emissions (e.g., in near-net-zero scenarios). Triggers a SquareDev Fallback and resets the reference iteration.
*'               * **Positive Slope**: An anomalous scenario where the computed Rescale Slope is positive, falsely implying that a higher carbon tax increased emissions. Addressed by either repeating a valid historical slope or triggering a SquareDev Fallback.
*'               * **Slope Clamp**: Hard bounds applied to the Rescale Slope before it is used. Prevents a single iteration from making an extreme price adjustment due to noisy slope estimates.
*'               * **Upper Clamp Bound**: The maximum (least-negative) permitted value for the Rescale Slope (default: -0.3). Prevents the algorithm from over-adjusting when the slope is too flat.
*'               * **Lower Clamp Bound**: The minimum (most-negative) permitted value for the Rescale Slope (default: -5). Prevents extreme tax jumps when the slope is too steep.
*'               * **Adaptive Upper Clamp Bound**: An extension of the Upper Clamp Bound that halves the limit when the clamp triggers in consecutive outer iterations, indicating persistent flat-slope behavior. Resets to the default when the clamp is no longer triggered.
*'               * **Oscillation Dampener**: A safeguard that fires when the Rescale Factor alternates between > 1 and < 1 for three consecutive outer iterations. When triggered, the factor's adjustment distance from 1.0 is halved to dampen volatility.
*'
*' @authors Renato Rodrigues, Felix Schreyer

*###################### R SECTION START (MODULETYPES) ##########################
$Ifi "%regipol%" == "none" $include "./modules/47_regipol/none/realization.gms"
$Ifi "%regipol%" == "regiCarbonPrice" $include "./modules/47_regipol/regiCarbonPrice/realization.gms"
*###################### R SECTION END (MODULETYPES) ############################

*** EOF ./modules/47_regipol/module.gms
