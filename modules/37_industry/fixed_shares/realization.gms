*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/37_industry/fixed_shares/realization.gms

*' @description The region-specific shares of final energy use in industry 
*' subsectors (cement, chemicals, and steel production, as well as all other 
*' industry production) are kept constant on the 2005 level.  This potentially 
*' overestimates the potential for electrification and thus underestimates the 
*' emissions, especially from coal in the steel and cement sectors. 
*'
*' Subsector-specific MAC curves for CCS are applied to emissions calculated 
*' from energy use and emission factors.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/37_industry/fixed_shares/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/37_industry/fixed_shares/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/37_industry/fixed_shares/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/37_industry/fixed_shares/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/37_industry/fixed_shares/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/37_industry/fixed_shares/presolve.gms"
$Ifi "%phase%" == "postsolve" $include "./modules/37_industry/fixed_shares/postsolve.gms"
$Ifi "%phase%" == "output" $include "./modules/37_industry/fixed_shares/output.gms"
*######################## R SECTION END (PHASES) ###############################

*** EOF ./modules/37_industry/fixed_shares/realization.gms

