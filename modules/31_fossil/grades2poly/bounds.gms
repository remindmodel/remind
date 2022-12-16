*** |  (C) 2006-2022 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/31_fossil/grades2poly/bounds.gms

vm_fuExtr.lo(t,regi,peFos(enty),"1")$(pm_ffPolyCumEx(regi,enty,"max")>1e-6) = 1e-6;

*AJS* prevent the model from using the "higher grades", these are just dummy variables
loop(rlf$(NOT sameas(rlf,"1")),
	vm_fuExtr.fx(t,regi,peFos(enty),rlf) = 0;
);

v31_fuExtrCum.lo(t,regi,peFos(enty),"1")$((t.val ge 2010) AND (pm_ffPolyCumEx(regi,enty,"max"))) = 1e-9;

vm_costFuEx.up(t,regi,peFos) = 10.0;

*NB* assign the sensitivity values from default.cfg/main.gms to the parameter
p31_rentdisc("peoil")   = cm_rentdiscoil;
p31_rentdisc2("peoil")  = cm_rentdiscoil2;
p31_rentconv("peoil")   = cm_rentconvoil;
p31_rentdisc("pecoal")  = cm_rentdisccoal;
p31_rentdisc2("pecoal") = cm_rentdisccoal2;
p31_rentconv("pecoal")  = cm_rentconvcoal;
p31_rentdisc("pegas")   = cm_rentdiscgas;
p31_rentdisc2("pegas")  = cm_rentdiscgas2;
p31_rentconv("pegas")   = cm_rentconvgas;

s31_fuEx_startyr = 2005;  !! The fossil cost curves and rent discounting should always begin in the initial period.
p31_rentdisctot(ttot, enty)$(p31_rentconv(enty) gt 0) =  (p31_rentdisc(enty) + (pm_ttot_val(ttot) - s31_fuEx_startyr) * (p31_rentdisc2(enty)-p31_rentdisc(enty))/p31_rentconv(enty));
p31_rentdisctot(ttot, enty)$(ttot.val gt 2010 + p31_rentconv(enty)) = p31_rentdisc2(enty);

display
cm_rentdisccoal,cm_rentdiscgas,p31_rentdisc, p31_rentdisctot;

v31_fuExtrCum.up(ttot,regi,peFos(enty),"1") = pm_ffPolyCumEx(regi,enty,"max");
display pm_ffPolyCumEx;
display v31_fuExtrCum.up;

*------------------------------------
*** Regionalised upper bound on uranium extraction
*------------------------------------
v31_fuExtrCum.up(ttot,regi,"peur", "1") = p31_fuExtrCumMaxBound(regi,"peur", "1");


*** EOF ./modules/31_fossil/grades2poly/bounds.gms
