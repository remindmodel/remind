*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/42_banking/banking/equations.gms

***---------------------------------------------------------------------------
*'  constraint on banking of emission permits: banking is allowed without constraint, but no borrowing
***---------------------------------------------------------------------------
q42_bankconst1_mp(ttot,regi)..
        sum(ttot2 $((ttot2.val ge 2005) and (ttot2.val le ttot.val)), vm_banking(ttot2,regi) * pm_ts(ttot)) =g= 0;
*** EOF ./modules/42_banking/banking/equations.gms
