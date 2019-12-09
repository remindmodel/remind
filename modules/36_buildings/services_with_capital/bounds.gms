*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/36_buildings/services_with_capital/bounds.gms
if ((cm_noReboundEffect eq 1 ), !! Fix the upper bound of vm_cesIO to the level of input_ref if no rebound is allowed
vm_cesIO.up(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 + 1e-14) * p36_cesIONoRebound(t,regi,in);
vm_cesIO.lo(t,regi,in)$(sameAs(in,"esswb") OR sameAs(in,"uealb") OR sameAs(in,"uecwb")) = (1 - 1e-14) * p36_cesIONoRebound(t,regi,in);
);
***v36_beta.L(regi_dyn36(regi),inViaEs_dyn36(in)) = -1;


*** EOF ./modules/36_buildings/services_with_capital/bounds.gms
