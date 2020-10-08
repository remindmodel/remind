*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/05_initialCap/on/declaration.gms

Parameter
  pm_cap0(all_regi,all_te)                           "standing capacity in 2005 as calculated by the initialization routine generisinical. Unit: TWa"
  p05_emi2005_from_initialcap2(all_regi,emiTe)       "regional energy emissions 2005 resulting from the initialcap routine. Unit: GtC"
  p05_initial_capacity(all_regi,all_te)              "capacitiy at t=2005, calculated from past deltacaps"
  p05_inital_input(all_regi,all_te)                  "input in 2005, calculated from past deltacaps and initial time-variable eta"
  p05_corrected_inital_input(all_regi,all_te)        "corrected input in 2005, calculated from past deltacaps and corrected time-variable eta"
  p05_eta_correct_factor(all_regi,all_te)            "correction factor for time-variable etas to adapt the generisdataeta to external IEA calibration"
  p05_inital_eta(all_regi,all_te)                    "initial eta for technologies with time-variable etas, calculated from past deltacaps"
  p05_corrected_inital_eta(all_regi,all_te)          "corrected initial eta for technologies with time-variable etas, calculated from past deltacaps, with external IEA calibration"
  p05_inital_output(all_regi,all_te)                 "initial vm_prodSe production of technolgy te"
  p05_deltacap_res(tall,all_regi,all_te)             "deltacaps of technologies that demand pebiolc residues, needed for enhancement of residue potential"
  p05_cap_res(tall,all_regi,all_te)                  "caps of technologies that demand pebiolc residues, needed for enhancement of residue potential"
  p05_vintage(all_regi,opTimeYr,all_te)              "historical vintage structure.  Unit: arbitrary but renormalized to give a sum eq 1 when multiplied with corresponding pm_omeg"
  p05_aux_vintage_renormalization(all_regi,all_te)   "needed auxiliary parameter for renormalization"
  p05_aux_prod_thisgrade(rlf)                        "auxiliary calculation parameter for the capacities in different grades: production in this grade"
  p05_aux_cap_distr(all_regi,all_te,rlf)             "auxiliary calculation parameter for the calculation of initial capacities, distributed to grades"
  p05_aux_cap(all_regi,all_te)                       "auxiliary calculation parameter for the calculation of initial capacities"
  pm_aux_capLowerLimit(all_te,all_regi,tall)         "auxiliary calculation parameter for the calculation of the lowest possible capacities in the first time steps"
  p05_aux_calccapLowerLimitSwitch(tall)              "auxiliary calculation parameter to allow the calculation of the lowest possible capacities in the first time steps"    
;

Variables
  v05_INIdemEn0(all_regi,all_enty)   "initial energy demand - this is NOT total energy demand, but the sum of all transformation pathways that demand energy minus the co-produced amount"
  v05_INIcap0(all_regi,all_te)       "initial capacity"
;

Equations
  q05_eedemini(all_regi,all_enty)                  "calculation of initial energy demand"
  q05_ccapini(all_regi,all_enty,all_enty,all_te)   "calculation of initial capacity"
;

Scalars
  s05_inic_switch          "switch for turning off ESM calibration routine equations during optimization"
  s05_aux_tot_prod         "auxiliary calculation parameter for the capacities in different grades: total production as resulting from initialcap2"
  s05_aux_prod_remaining   "auxiliary calculation parameter for the capacities in different grades: production that still has to be distributed to a grade"
;

*** EOF ./modules/05_initalCap/on/declaration.gms

