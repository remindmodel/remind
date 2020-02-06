*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/47_regipol/regiCarbonPrice/bounds.gms

$IFTHEN.NucRegiPol not "%cm_NucRegiPol%" == "off" 

***Germany Nuclear phase-out
*** DEU Nuclear capacity phase out
    vm_capEarlyReti.up(ttot,regi,"tnrs")$(sameas(regi,"DEU")) = 1; !! allow early retirement for tnrs
    vm_cap.fx("2015",regi,"tnrs","1")$((cm_startyear le 2015) and (sameas(regi,"DEU"))) = 10.8/1000; 
    vm_cap.fx("2020",regi,"tnrs","1")$((cm_startyear le 2020) and (sameas(regi,"DEU"))) = 7.8/1000;
    vm_cap.up(t,regi,"tnrs","1")$((t.val ge 2025) and (t.val ge cm_startyear) and (sameas(regi,"DEU"))) = 1E-6;

*** ESC -> no new Nuclear capacity (Italy had a plebiscite for this and Greece should not have any new capacity)
    vm_deltaCap.up(t,regi,"tnrs","1")$((t.val ge 2020) and (t.val ge cm_startyear) and (sameas(regi,"ESC"))) = 0;

$ENDIF.NucRegiPol    

$IFTHEN.CCSinvestment not "%cm_CCSRegiPol%" == "off" 

* earliest investment in Europe, with one timestep split between countries currently exploring - Norway (NEN), Netherlands (EWN) and UK (UKI) - and others
deltacap.up(t,regi,teCCS,rlf)$( (t.val le %cm_CCSRegiPol%) AND (sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI"))) = 1e-6; 
deltacap.up(t,regi,teCCS,rlf)$( (t.val lt %cm_CCSRegiPol%) AND (regi_group("EUR_regi",regi)) AND (NOT(sameas(regi,"NEN") OR sameas(regi,"EWN") OR sameas(regi,"UKI")))) = 1e-6;

$ENDIF.CCSinvestment


*** EOF ./modules/47_regipol/regiCarbonPrice/bounds.gms
