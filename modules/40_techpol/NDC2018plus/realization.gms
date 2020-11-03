*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


*' @description Technology policy components of nationally determined contributions as submitted to UNFCCC between 2015-2017. 
*' Soft-coded, with some semi-hardcoded constraints (for EU, USA, Japan, India and China, 
*' only active if "EUR", "USA", "JPN", "IND", "CHN" or "CHA" is a native region).
*' 
*' @limitations so far only includes capacity targets in power sector, a few share-constraints for native regions (see above), but no representation of efficiency targets in transport sector


*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "declarations" $include "./modules/40_techpol/NDC2018plus/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/40_techpol/NDC2018plus/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/40_techpol/NDC2018plus/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/40_techpol/NDC2018plus/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
