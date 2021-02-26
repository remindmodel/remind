*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/equations.gms

*'  Transportation Final Energy Balance
q35_demFeTrans(ttot,regi,entyFe,emiMkt)$((ttot.val ge cm_startyear) AND (entyFe2Sector(entyFe,"trans"))) ..
  sum((entySe,te)$se2fe(entySe,entyFe,te), 
    vm_demFeSector(ttot,regi,entySe,entyFe,"trans",emiMkt)
  ) 
  =e=
  (
    sum(fe2ue(entyFe,entyUe,te), v35_demFe(ttot,regi,entyFe,entyUe,te) )
    - 
    sum(pc2te(entyFE2,entyUe,te,entyFE),                        !! couple production from FE to ES for heavy duty vehicles
		  pm_prodCouple(regi,entyFE2,entyUe,te,entyFE) * vm_prodUe(ttot,regi,entyFE2,entyUe,te)
    )
  ) * ( !! splitting heavy dutty final energy demand between "other" (bunkers) and "ES" emission markets
    1$(sameas(emiMkt,"ES") AND (NOT(sameas(entyFe,"fedie")))) + !! do nothing for non heavy dutty FE demand
    (
      pm_bunker_share_in_nonldv_fe(ttot,regi)$(sameas(emiMkt,"other"))  !! asign heavy dutty bunkers to "other" emiMkt
      +
      (1-pm_bunker_share_in_nonldv_fe(ttot,regi))$(sameas(emiMkt,"ES")) !! Effort Sharing does not include bunkers
    )$((sameas(entyFe,"fedie")))
  )
;

*** Transformation from final energy to useful energy
q35_transFe2Ue(t,regi,fe2ue(entyFe,entyUe,te))..
    pm_eta_conv(t,regi,te) * v35_demFe(t,regi,entyFe,entyUe,te)
    =e=
    vm_prodUe(t,regi,entyFe,entyUe,te);

*** Hand-over to CES
q35_esm2macro(t,regi,in)$ppfenFromUe(in)..
    vm_cesIO(t,regi,in) + pm_cesdata(t,regi,in,"offset_quantity")
    =e=
    sum(fe2ue(entyFe,entyUe,te)$ue2ppfen(entyUe,in), vm_prodUe(t,regi,entyFe,entyUe,te))  !! all entyFe that are first transformed into entyUe and then fed into the CES production function
;

*** Definition of capacity constraints for FE to ES transformation:
q35_limitCapUe(t,regi,fe2ue(entyFe,entyUe,te))..
    vm_prodUe(t,regi,entyFe,entyUe,te)
    =l=
    sum(teue2rlf(te,rlf),
        vm_capFac(t,regi,te) * vm_cap(t,regi,te,rlf)
    )
;

q35_shUePeT(t,regi,te)$LDV35(te) ..       !! calculate the share of different LDV types in total LDV usage
  sum(fe2ue(entyFe,"uepet",te2)$LDV35(te2), vm_prodUe(t,regi,entyFe,"uepet",te2) )
  * vm_shUePeT(t,regi,te) / 100
  =e=
  sum(fe2ue(entyFe,"uepet",te), vm_prodUe(t,regi,entyFe,"uepet",te) )
;


q35_shUePeTbal(t,regi) ..       
  sum(fe2ue(entyFe,"uepet",te)$LDV35(te), vm_shUePeT(t,regi,te))
  =e=
  100
;

*** EOF ./modules/35_transport/complex/equations.gms

