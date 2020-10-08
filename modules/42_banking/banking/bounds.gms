*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/42_banking/banking/bounds.gms
*mlb* avoid to accumulate permit stock in pre-trading periods
vm_banking.fx(ttot,all_regi)$(ttot.val le 2010) = 0;

*** EOF ./modules/42_banking/banking/bounds.gms
