*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/01_macro/singleSectorGr/bounds.gms

*nb* lower bounds on CES values
vm_cons.lo(t,regi)     = 1e-3;
vm_cesIO.lo(t,regi,in) = 1e-6;
vm_cesIOdelta.lo(t,regi,in_putty) = 1e-6;

*nb fix energy inputs to CES structure in t0 to the parameter values
vm_cesIO.fx(t0(tall),regi,in)$(ppfEn(in) OR ppfIO_putty(in)) = pm_cesdata(tall,regi,in,"quantity");
vm_cesIOdelta.fx(t0(tall),regi,in)$(ppfEn(in) OR in_putty(in)) = pm_cesdata_putty(tall,regi,in,"quantity");


*** set macro investments to bound in 2005
vm_invMacro.fx("2005",regi,"kap") = p01_boundInvMacro(regi);
*cb 2012-05-23 lower bound for capital investment to avoid "zero investment" problem for the conopt solver
vm_invMacro.lo(t,regi,"kap")$(t.val gt 2005) = 0.01 * vm_invMacro.lo("2005",regi,"kap");

v01_invMacroAdj.fx("2005",regi,ppfKap(in)) = 0;
*** EOF ./modules/01_macro/singleSectorGr/bounds.gms