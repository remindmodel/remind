*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/equations.gms
***--------------------------------------------------------------------------
*** JeS: factor 0.000001 converts units from M$ to T$: e.g. for sulfur units are [TgS/TWa]*[TWa]*[$/pm_ts]

q11_costpollution(t,regi)..
vm_costpollution(t,regi)=e=sum(emi2te(enty,enty2,te,emiAll),
    0.000001*pm_ts(t)
  * (
      ( (p11_EF_uncontr(enty,enty2,te,regi,emiAll,"indst")-pm_emifac(t,regi,enty,enty2,te,emiAll))
      * vm_demPe(t,regi,enty,enty2,te)
      * p11_share_sector(t,enty,enty2,te,"indst",regi)
      * p11_costpollution(te,emiAll,"indst")
      )$( sectorEndoEmi2te(enty,enty2,te,"indst") AND pe2se(enty,enty2,te) )
    + ( (p11_EF_uncontr(enty,enty2,te,regi,emiAll,"res")-pm_emifac(t,regi,enty,enty2,te,emiAll))
      * vm_demPe(t,regi,enty,enty2,te)
      * p11_share_sector(t,enty,enty2,te,"res",regi)
      * p11_costpollution(te,emiAll,"res")
      )$(sectorEndoEmi2te(enty,enty2,te,"res") AND pe2se(enty,enty2,te) )
    + ( (p11_EF_uncontr(enty,enty2,te,regi,emiAll,"trans")-pm_emifac(t,regi,enty,enty2,te,emiAll))
      * vm_prodFe(t,regi,enty,enty2,te)
      * p11_share_sector(t,enty,enty2,te,"trans",regi)
      * p11_costpollution(te,emiAll,"trans")
      )$(sectorEndoEmi2te(enty,enty2,te,"trans") AND se2fe(enty,enty2,te) )
    + ( (p11_EF_mean(enty,enty2,te,emiAll)-pm_emifac(t,regi,enty,enty2,te,emiAll) )
      * vm_demPe(t,regi,enty,enty2,te)
      * p11_share_sector(t,enty,enty2,te,"power",regi)
      * p11_costpollution(te,emiAll,"power")
      )$(sectorEndoEmi2te(enty,enty2,te,"power") AND pe2se(enty,enty2,te) )
    + ( (p11_EF_uncontr("peoil","seel","dot",regi,emiAll,"power")-p11_EF_mean("peoil","seel","dot",emiAll))
      * vm_demPe(t,regi,"peoil","seel","dot")
      * p11_costpollution("dot",emiAll,"power")
      )$( sameas(enty,"peoil") AND sameas(enty2,"seel") AND sameas(te,"dot") )
    + ( (p11_EF_mean(enty,enty2,te,emiAll)-pm_emifac(t,regi,enty,enty2,te,emiAll))
      * vm_demPe(t,regi,enty,enty2,te)
      * p11_share_sector(t,enty,enty2,te,"trans",regi)
      * p11_costpollution(te,emiAll,"trans")
      )$(sectorEndoEmi2te(enty,enty2,te,"trans") AND pe2se(enty,enty2,te) )
   )
                             );

*** EOF ./modules/11_aerosols/exoGAINS/equations.gms
