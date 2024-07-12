*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/se_trade/declarations.gms
***-------------------------------------------------------------------------------
***                                   PARAMETERS
***-------------------------------------------------------------------------------
parameters
pm_tradecostgood(all_regi)                  "Trade costs (final good)."
pm_Xport0(tall,all_regi,all_enty)           "Reference level value of export." 
pm_IO_trade(tall,all_regi,all_enty,char)    "Energy trade bounds based on IEA data."
p24_Mport2005correct(all_regi,all_enty)     "Correction factor to match fossil supply and internal region energy demand in the initial year"

p24_seTradeCapacity(tall,all_regi,all_regi,all_enty) "Secondary energy international yearly trade capacity potential from regi to regi2 [TWa]"
p24_seTrade_Quantity(all_regi,all_regi,all_enty)      "Maximum import quantity in import scenarios with fixed quantities [TWa]"

$IFTHEN.trade_SE_exog not "%cm_trade_SE_exog%" == "off"
  p24_trade_exog(ttot,ttot,ext_regi,ext_regi,all_enty)   "parameter to define exogenous SE trade trajectories [EJ/yr]" / %cm_trade_SE_exog% /
$ENDIF.trade_SE_exog

p24_MportsRegi(tall,all_regi,all_regi,all_enty)      "Mports to regi from regi2, assuming that trade is distributed uniformetly according existent capacities defined at p24_seTradeCapacity [TWa]"
p24_XportsRegi(tall,all_regi,all_regi,all_enty)      "Exports from regi to regi2. Defined in the postsolve as a result of p24_MportsRegi calculation [TWa]"
pm_MPortsPrice(tall,all_regi,all_enty)              "Secondary energy import price for region. Calculated in the postsolve and assuming that trade is distributed uniformetly according existent capacities defined at p24_seTradeCapacity [T$/TWa]"
pm_XPortsPrice(tall,all_regi,all_enty)              "Secondary energy export price for region. Calculated in the postsolve and corresponding to the region secondary energy price [T$/TWa]"

*** parameters used in cm_import_EU scenarios nzero, nzero_bio and high_bio
p24_seAggReference(ttot,all_regi,seAgg)                                        "Secondary energy per carrier (seAgg) in the reference run [TWa]"
p24_FEregiShareInRegiGroup(ttot,ext_regi,all_regi,seAgg)                       "Region share of total final energy demand per carrier (seAgg) within the region group (ext_regi) [%]"
p24_demFeForEsReference(ttot,all_regi,all_enty,all_esty,all_teEs)              "Final energy which will be used in the ES layer in the reference run [TWa]"
p24_demFeIndSubReference(ttot,all_regi,all_enty,all_enty,secInd37,all_emiMkt)  "Final energy demand per industry subsector, FE carrier, SE carrier, emissions market in the reference run [TWa]"
p24_aviationAndChemicalsFE(ttot,all_regi)                                      "Final energy of aviation and chemicals liquids demand [TWa]"
p24_aviationAndChemicalsFEShareInRegion(ttot,ext_regi,all_regi)                "Region share of total final energy aviation and chemicals liquids demand within the region group (ext_regi) [%]"
;

***-------------------------------------------------------------------------------
***                                   VARIABLES
***-------------------------------------------------------------------------------
positive VARIABLES
vm_Xport(tall,all_regi,all_enty)            "Export of traded commodity."
vm_Mport(tall,all_regi,all_enty)            "Import of traded commodity."
vm_costTradeCap(ttot,all_regi,all_enty)     "Trade technology and transportation cost"
vm_capacityTradeBalance(tall,all_regi)      "Capacity trade balance term"
;

*** EOF ./modules/24_trade/se_trade/declarations.gms
