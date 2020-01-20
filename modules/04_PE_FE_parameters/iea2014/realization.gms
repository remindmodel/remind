*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de


*' @description This realization used IEA data from 2014.
*' The realization iea2014 serves to caliibrate the conversion efficiencies 
*' to be consistent with predefined dataset (here iea2014, but it is flexible for up-dates). 
*' The module realization starts with the final energy demands and then derives backwards
*' what the secondary and primary energy demands have been. 
*' The file datainput.gms reads in the energy data related to each process. The process related inputs are
*' contained in input/f04_IO_input.cs4r and the output are contained in input/f04_IO_output.cs4r.
*' These files also contain all information about existing and statistically reported joint production processes.
*' Based on these energy flows the corresponding conversion efficiencies that replicate these energy flows.
*' The efficiencies are assigned to the parameter pm_data(*,"eta",*).

*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/04_PE_FE_parameters/iea2014/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/04_PE_FE_parameters/iea2014/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/04_PE_FE_parameters/iea2014/datainput.gms"
*######################## R SECTION END (PHASES) ###############################
