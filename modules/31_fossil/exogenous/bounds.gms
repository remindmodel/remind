*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/exogenous/bounds.gms
*JH/TAC Fixing fuel extraction costs to predefined values
vm_costFuEx.fx(t,regi,peEx) = p31_fix_costfu_ex(t,regi,peEx);

*JH/TAC Fixing fuel extraction quantities to predefined values
vm_fuExtr.fx(t,regi,peEx,rlf) = p31_fix_fuelex(t,regi,peEx,rlf);
*** EOF ./modules/31_fossil/exogenous/bounds.gms
