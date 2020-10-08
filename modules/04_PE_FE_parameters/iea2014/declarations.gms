*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de

parameter
pm_IO_input(all_regi,all_enty,all_enty,all_te)                 "Energy input based on IEA data"
p04_IO_output(all_regi,all_enty,all_enty,all_te)                "Energy output based on IEA data"
p04_x_enty2te_dyn04(all_regi,all_enty,all_enty,all_te,all_te)   "parameter for the allocation of energy flow to technologies"
pm_prodCouple(all_regi,all_enty,all_enty,all_te,all_enty)       "own consumption"
p04_aux_data(all_regi,char, all_te)                             "auxiliary parameter to store the initial mix0 and eta values for gas electricity before splitting it to ngcc and ngt (needed as long as calibration routine sets ngt to 0)"
p04_shareNGTinGas(all_regi)                                     "Share of ngt in electricity produced from gas"
pm_fuExtrOwnCons(all_regi, all_enty, all_enty)                  "energy own consumption in the extraction sector with first enty being the output produced and the second enty being the input required"
p04_shOilGasEx(all_regi, all_enty)                              "share of oil and gas extraction in all regions"
p04_fuExtr(all_regi, all_enty)                                  "regional fuel extraction for the base year calibration"
pm_histfegrowth(all_regi,all_enty)                              "average growth rate of fe use from 1995 to 2005"
p04_prodCoupleGlob(all_enty,all_enty,all_te,all_enty)           "global couple products"
;
