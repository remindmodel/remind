*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/capacity/preloop.gms

***-------------------------------------------------------------------------------
***                  INITIALISATION OF PARAMETERS AND VARAIBLES
***-------------------------------------------------------------------------------
*** trade variables
***vm_Mport.l(ttot,regi,tradeSe) = 0;
***vm_Xport.l(ttot,regi,tradeSe)  = 0;

*** trade parameters
pm_MPortsPrice(ttot,regi,tradeSe) = 0;
pm_XPortsPrice(ttot,regi,tradeSe) = 0;
pm_PEPrice(ttot,regi,entySe) = 0;
pm_SEPrice(ttot,regi,entySe) = 0;

*** iteration variables
p24_Xport_iter(iteration,ttot,all_regi,all_enty) = 0;
p24_Mport_iter(iteration,ttot,all_regi,all_enty) = 0;
p24_shipment_quan_iter(iteration,ttot,all_regi,all_regi,tradeModes) = 0;
***p24_XPortsPrice_iter(iteration,ttot,all_regi,all_enty) = 0;

*** EOF ./modules/24_trade/capacity/preloop.gms
