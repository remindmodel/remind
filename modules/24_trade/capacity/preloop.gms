*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/preloop.gms

***-------------------------------------------------------------------------------
***                             INITIALISATION OF PARAMETERS AND VARAIBLES
***-------------------------------------------------------------------------------
*** trade variables
vm_Mport.l(t,regi,tradeSe) = 0;
vm_Xport.l(t,regi,tradeSe)  = 0;

*** trade parameters
pm_MPortsPrice(t,regi,tradeSe) = 0;
pm_XPortsPrice(t,regi,tradeSe) = 0;
pm_PEPrice(t,regi,entySe) = 0;
pm_SEPrice(t,regi,entySe) = 0;

*** iteration variables
p24_Xport_iter(iteration,tall,all_regi,all_enty) = 0;
p24_Mport_iter(iteration,tall,all_regi,all_enty) = 0;
p24_shipment_quan_iter(iteration,ttot,all_regi,all_regi,tradeModes) = 0;

***-------------------------------------------------------------------------------
***                                   TRADE MODEL
***-------------------------------------------------------------------------------
MODEL m24_tradeTransp
/
  q24_tradeFromMports

  q24_limitCapTradeBilat
  q24_limitCapTradeXport
  q24_limitCapTradeMport

  q24_capTrade
  q24_limitDeltaCap
  q24_prohibitMX

  q24_costTradePrice
  q24_costTradeCap
  q24_budgetTradeX
  q24_budgetTradeM

  v24_objFunc
/
;

*** EOF ./modules/24_trade/capacity/preloop.gms
