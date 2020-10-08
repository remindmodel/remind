*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/20_growth/spillover/bounds.gms
* mlb 20130830 * to avoid numerical errors, initialize efficiency growth variable
*   vm_effGr.l(t,regi,in)=1;
   vm_effGr.fx("2005",regi,inRD20(in)) = pm_cesdata("2005",regi,in,"effgr");

* ML 20150304 * maintain pattern of efficiency improvement of final energy use in lower CES nests
   p20_dataeffscal_avg(t,regi) = sum(ppfEn, pm_cesdata(t,regi,ppfEn,"effgr"))/card(ppfEn);
   pm_cesdata(t,regi,ppfEn,"effgr") = pm_cesdata(t,regi,ppfEn,"effgr")/(p20_dataeffscal_avg(t,regi)+ 0.00001);
display pm_cesdata;

   vm_effGr.fx(t,regi,noRD(in)) = pm_cesdata(t,regi,in,"effgr");

   vm_effGr.fx(t,regi,"feelt") = 1;
   vm_effGR.lo(t,regi,inRD20(in)) = 1;    
   vm_invRD.fx(t,regi,in) = 0; 

*** EOF ./modules/20_growth/spillover/bounds.gms
