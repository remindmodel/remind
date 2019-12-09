*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/all.gms

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/33_CDR/all/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/33_CDR/all/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/33_CDR/all/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/33_CDR/all/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/33_CDR/all/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/33_CDR/all.gms
