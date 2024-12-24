*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/24_trade/standard/equations.gms

*' @equations

*** ---------------------------------------------------------------------------
***        Trade Constraints
*** ---------------------------------------------------------------------------

***------------------------------------------------------
*' Imports constrained by demand side of import country
***------------------------------------------------------

*Coal used in steel making is imported due to minimum quality requiremend (that is India)
* active only after 2020; otherwise potential interference with constrained historic vm_Mport()
* The constraint avoids Indian coal imports to drop to zero immediately

q24_peimport_demandside(t,regi,enty,tradeConst)$(t.val gt 2020 AND p24_trade_constraints(regi,enty,tradeConst) ne 0)..
   vm_Mport(t,regi,enty) 
   =g= 
   p24_trade_constraints(regi,enty,tradeConst)*
      sum((secInd37_tePrc("steel",tePrc),
        tePrc2opmoPrc(tePrc,opmoPrc)),
           pm_specFeDem(t,regi,"fesos",tePrc,opmoPrc) *
           vm_outflowPrc(t,regi,tePrc,opmoPrc)
   )
;


*' @stop
*** EOF ./modules/24_trade/standard/equations.gms


