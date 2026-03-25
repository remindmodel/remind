*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/11_aerosols/exoGAINS2025/sets.gms
sets
emisForEmiFac11(all_enty)  "types of emissions that are only calculated in a post-processing routine after the optimization"
/
        NOx
        CO
        VOC
        SO2
        BC
        OC
        NH3
/

all_sectorEmi11 "all sectors with emissions"
/   indst        "emissions from industry sector"
    res          "emissions from residential sector"
    trans        "emissions from transport sector"
    power        "emissions from power sector"
    solvents     "emissions from solvents"
    extraction   "emissions from fuel extraction"
    indprocess   "process emissions from industry"
    waste        "emissions from waste"
/

sectorEndoEmi11(all_sectorEmi11)   "sectors with endogenous emissions"
/
    indst    "industry"
    res      "residential"
    trans    "transport"
    power    "power"
/

sectorEndoEmi2te11(all_enty,all_enty,all_te,sectorEndoEmi11)   "map sectors to technologies"
/
    pegas.seel.ngcc.power
    pegas.seel.ngt.power
    seh2.seel.h2turb.power
    pegas.seel.gaschp.power
    pegas.sehe.gashp.power
    pegas.segafos.gastr.indst
    pegas.segafos.gastr.res
    pecoal.seel.pc.power
    pecoal.seel.coalchp.power
    pecoal.sehe.coalhp.power
    pecoal.sesofos.coaltr.indst
    pecoal.sesofos.coaltr.res
    peoil.seliqfos.refliq.trans
    peoil.seliqfos.refliq.indst
    peoil.seliqfos.refliq.res
    peoil.seel.dot.power
    pebiolc.seel.biochp.power
    pebiolc.sehe.biohp.power
    pebiolc.sesobio.biotr.indst
    pebiolc.sesobio.biotr.res
    pebiolc.sesobio.biotrmod.indst
    seliqbio.fehos.tdbiohos.indst
    seliqfos.fehos.tdfoshos.indst
    seliqsyn.fehos.tdsynhos.indst
    seliqbio.fehos.tdbiohos.res
    seliqfos.fehos.tdfoshos.res
    seliqsyn.fehos.tdsynhos.res
    seliqbio.fedie.tdbiodie.trans
    seliqfos.fedie.tdfosdie.trans
    seliqsyn.fedie.tdsyndie.trans
    seliqbio.fepet.tdbiopet.trans
    seliqfos.fepet.tdfospet.trans
    seliqsyn.fepet.tdsynpet.trans
/

sectorEndoEmi2te_dyn11(all_enty,all_enty,all_te,sectorEndoEmi11)  "map sectors to technologies"
/
pecoal.seel.igcc.power
pecoal.seel.igccc.power
pecoal.segafos.coalgas.power
pebiolc.seel.bioigcc.power
pebiolc.seel.bioigccc.power
pebiolc.segabio.biogas.power
/
;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
sectorEndoEmi2te11(sectorEndoEmi2te_dyn11) = YES;

*** EOF ./modules/11_aerosols/exoGAINS2025/sets.gms
