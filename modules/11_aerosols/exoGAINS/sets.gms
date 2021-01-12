*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS/sets.gms
sets
emisForEmiFac(all_enty)	"types of emissions that are only calculated in a post-processing routine after the optimization"
/
        NOx
        CO
        VOC
        SO2
        BC
        OC
        NH3
/

sectorEndoEmi2te_dyn11(all_enty,all_enty,all_te,sectorEndoEmi)	 "map sectors to technologies"
/
pecoal.seel.igcc.power
pecoal.seel.igccc.power
pecoal.seel.pcc.power
pecoal.seel.pco.power
pecoal.segafos.coalgas.power		
pebiolc.seel.bioigcc.power
pebiolc.seel.bioigccc.power
pebiolc.segabio.biogas.power			
/
;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
sectorEndoEmi2te(sectorEndoEmi2te_dyn11) = YES;

*** EOF ./modules/11_aerosols/exoGAINS/sets.gms
