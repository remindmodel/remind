*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/exogenous/declarations.gms
*JH/TAC Declaring exogenous parameters for fixing fuel extraction quantities
*       and costs

parameter

p31_fix_costfu_ex(tall,all_regi,all_enty)          "exogenous data for vm_costFuEx"
p31_fix_fuelex(tall,all_regi,all_enty,rlf)         "exogenous data for vm_fuExtr"
*LB* preliminary dummy for $ condition in core/equations.gms
p31_grades(all_regi,xirog,all_enty,rlf)            "dummy"
;
*** EOF ./modules/31_fossil/exogenous/declarations.gms
