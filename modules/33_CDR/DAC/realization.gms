*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/33_CDR/DAC.gms

*' @description 
*' In this realization, direct air capture can be used to remove CO2 from the atmosphere in addition to BECCS and afforestation. Based on Broehm et al. we assume an energy demand of 
*' 2 GJ/tCO2 electricity and 10 GJ/tCO2 heat which can be met via gas or H2. If gas is used, the resulting CO2 is captured with a capture rate of 90%.

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/33_CDR/DAC/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/33_CDR/DAC/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/33_CDR/DAC/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/33_CDR/DAC/equations.gms"
$Ifi "%phase%" == "bounds" $include "./modules/33_CDR/DAC/bounds.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/33_CDR/DAC.gms
