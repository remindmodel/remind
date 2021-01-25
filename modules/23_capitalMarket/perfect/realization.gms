*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./module/23_capitalMarket/perfect.gms

*'
*' @description
*' The perfect capital market realization assumes unrestricted capital mobility and
*' investments decisions that are based on uniform savings behavior (equal time preferences and intertemporal
*' elasticities of substitution) across regions.
*'
*' @limitations
*' The resulting consumption paths and current accounta in initial periods do not fit to empirical data.
*' Energy system dynamics and mitigation costs are hardly affected.
*'

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/23_capitalMarket/perfect/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/23_capitalMarket/perfect/datainput.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./module/23_capitalMarket/perfect.gms
