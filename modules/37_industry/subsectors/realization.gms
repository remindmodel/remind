*** |  (C) 2006-2023 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/subsectors/realization.gms


*' @description subsectors models industry subsectors explicitly with individual
*' models for cement, chemicals, steel, and otherInd production.
*'
*' In the original formulation, each of the subsectors is modeled with its own CES nest.
*' Extensive documentation for this CES-based version can be found in the preprint
*' https://gmd.copernicus.org/preprints/gmd-2023-153/
*'
*'
*'
*' Apart from that, there is a process-based subsector model implementation, which is currently
*' implemented for primary and secondary steel. For this subsector, the switch
*' cm_subsec_model_steel allows to switch between both implementations.
*' Extending this process-based model to other subsectors is planned.
*'
*' The process-based implementation removes the CES tree below the ue_ (subsector output) level.
*' It introduces technologies as in the ESM/core, however with some differences.
*'
*' Characteristics of these technologies are:
*' - Vintage tracking, CAPEX & OPEX are implemented via the core equations q_cap, q_costInv and
*'   q_costOM; techno-economic data is input via generisdata_tech.prn
*' - Specific FE demands (arbitrary number of inputs) are used instead of one efficiency eta
*'   - For historically exisitng tech, specific energy demand follows exogenous convergence from
*'     historical values (via pm_fedemand) to the best available technology (BAT)
*'   - For "new" tech, temporally constant BAT values are assumed for energy efficiency
*' - Technologies have specific material demands. Materials can be model-external (e.g. iron ore)
*'   or outputs of other processes (e.g. DRI); This allows to have process routes consiting of
*'   several production steps. Their production volume is linked via these input and output
*'   materials. For example, the bf tech produces as much pigiron as the bof needs as input
*' - Each technology has one output material (may be extended to several);
*'   Specific tech inputs are normalized with this output quantity; i.e. idr specific demands
*'   are per Gt of DRI.
*' - Technologies can have several operation modes with different material and FE demands;
*'   This allows, for example, to switch from ng-based idr to h2-based with now additional
*'   capacity and CAPEX
*' - Emissions are accounted via FE demand and pm_emifac, which happens outside of the industry
*'   module and is independent of its implementation.
*' - Currently, production can be lower than capacity * capFac (arbitrary early retirement)
*' - Currently, there is no learning and no regionalized costs for industry tech
*' - CCS: the process-based implementation has a different CCS implementation. Instead of a MAC
*'   curve, point-source carbon capture (CC) is an additional tech. There is an own CC retrofit
*'   tech for each applicable baseline tech, which can be placed "on top of it"; These remove
*'   a part of the local emissions according to their capture rate.


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/37_industry/subsectors/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/37_industry/subsectors/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/37_industry/subsectors/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/37_industry/subsectors/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/37_industry/subsectors/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/37_industry/subsectors/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/37_industry/subsectors/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/37_industry/subsectors/postsolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/37_industry/subsectors/realization.gms
