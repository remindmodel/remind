*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/realization.gms

*' @description This realization corresponds to the traditional structure of emissions calculation
*' that used to be in the REMIND core. The code has simply been shifted here and rearranged but 
*' no structural refactoring was performed such that it calculates the same pipeline of emissions categories as before
*' (including vm_emiTeDetailMkt -> vm_emiTeMkt -> vm_emiAllMkt -> vm_co2eqMkt etc.).
*' Energy-related emissions factors and CO2 capture rates are read in from the generisdata_emi.prn file (PE emissions factors). 
*' FE emissions factors are hard-coded from UBA data. PE2SE emissions factors are calculated from
*' the PE emissions factors (carbon content of input), FE emissions factors (carbon content of output), 
*' and the PE2SE conversion efficiencies (output to input ratio). It also contains the implementation of 
*' carbon management flows in REMIND including balance equations to represent 
*' CO2 capture, CO2 transport and storage and CO2 utilization. 

*' @limitations: The structure of the emissions categories and calculations does not correspond well to the 
*' emissions variables to be reported to IAMC projects. This is why substantial recalculations 
*' are performed in the reporting module (remind2::reportEmi()) are required. 
*' Overall, this is a quite messy historically-grown structure and would ideally be refactored 
*' to be closer to the final reporting variables and to be more flexible and transparent in terms of
*' addressing different sectoral emissions and carbon flow categories within REMIND.



*####################### R SECTION START (PHASES) ##############################
$Ifi "%phase%" == "sets" $include "./modules/10_emissions/SectorAggregates/sets.gms"
$Ifi "%phase%" == "declarations" $include "./modules/10_emissions/SectorAggregates/declarations.gms"
$Ifi "%phase%" == "datainput" $include "./modules/10_emissions/SectorAggregates/datainput.gms"
$Ifi "%phase%" == "equations" $include "./modules/10_emissions/SectorAggregates/equations.gms"
$Ifi "%phase%" == "preloop" $include "./modules/10_emissions/SectorAggregates/preloop.gms"
$Ifi "%phase%" == "bounds" $include "./modules/10_emissions/SectorAggregates/bounds.gms"
$Ifi "%phase%" == "presolve" $include "./modules/10_emissions/SectorAggregates/presolve.gms"
*######################## R SECTION END (PHASES) ###############################
*** EOF ./modules/10_emissions/SectorAggregates/realization.gms
