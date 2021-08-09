*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/edge_esm/sets.gms

sets

teEs_dyn35(all_teEs)  "technologies - transport module additions"
/
    te_espet_pass_sm "short-to-medium distance passenger transport CES node"
    te_esdie_pass_sm "short-to-medium distance passenger transport CES node"
    te_eselt_pass_sm "short-to-medium distance passenger transport CES node"
    te_esh2t_pass_sm "short-to-medium distance passenger transport CES node"
    te_esgat_pass_sm "short-to-medium distance passenger transport CES node"
    te_esdie_pass_lo "long distance passenger transport (aviation) CES node"
    te_esdie_frgt_sm "short-to-medium distance freight transport CES node"
    te_eselt_frgt_sm "short-to-medium distance freight transport CES node"
    te_esh2t_frgt_sm "short-to-medium distance freight transport CES node"
    te_esgat_frgt_sm "short-to-medium distance freight transport CES node"
    te_esdie_frgt_lo "long distance freight transport CES node"    
/    
    
in_dyn35(all_in)          "all inputs and outputs of the CES function - transport module additions"
/
    entrp "transport CES node"
    entrp_pass "passenger transport CES node"
    entrp_frgt "freight transport CES node"
    entrp_pass_sm "short-to-medium distance passenger transport CES node"
    entrp_pass_lo "long distance passenger transport (aviation) CES node"
    entrp_frgt_sm "short-to-medium distance freight transport CES node"
    entrp_frgt_lo "long distance freight transport CES node"
/

esty_dyn35(all_esty)            "Energy service types"
/
    espet_pass_sm
    esdie_pass_sm
    esdie_pass_lo
    eselt_pass_sm
    esh2t_pass_sm
    esgat_pass_sm
    esdie_frgt_lo
    esdie_frgt_sm
    esh2t_frgt_sm
    eselt_frgt_sm
    esgat_frgt_sm
/

ppfen_dyn35(all_in)   "all energy input nodes - transport module additions"
/
    entrp_pass_sm "short-to-medium distance passenger transport CES node"
    entrp_pass_lo "long distance passenger transport (aviation) CES node"
    entrp_frgt_sm "short-to-medium distance freight transport CES node"
    entrp_frgt_lo "long distance freight transport CES node"
/

es2ppfen_dyn35(all_esty,all_in)      "matching ES to ppfEn in MACRO"
/
    espet_pass_sm.entrp_pass_sm
    esdie_pass_sm.entrp_pass_sm
    esdie_pass_lo.entrp_pass_lo
    eselt_pass_sm.entrp_pass_sm
    esh2t_pass_sm.entrp_pass_sm
    esgat_pass_sm.entrp_pass_sm
    esdie_frgt_lo.entrp_frgt_lo
    esdie_frgt_sm.entrp_frgt_sm
    esh2t_frgt_sm.entrp_frgt_sm
    eselt_frgt_sm.entrp_frgt_sm
    esgat_frgt_sm.entrp_frgt_sm
/

fe2es_dyn35(all_enty,all_esty,all_teEs)    "map FE carriers to ES via appliances"
/
    fepet.espet_pass_sm.te_espet_pass_sm
    fedie.esdie_pass_sm.te_esdie_pass_sm
    feh2t.esh2t_pass_sm.te_esh2t_pass_sm
    fegat.esgat_pass_sm.te_esgat_pass_sm
    feelt.eselt_pass_sm.te_eselt_pass_sm
    fedie.esdie_pass_lo.te_esdie_pass_lo
    fedie.esdie_frgt_lo.te_esdie_frgt_lo
    fedie.esdie_frgt_sm.te_esdie_frgt_sm
    feelt.eselt_frgt_sm.te_eselt_frgt_sm
    feh2t.esh2t_frgt_sm.te_esh2t_frgt_sm
    fegat.esgat_frgt_sm.te_esgat_frgt_sm
/

es_lo35(all_esty) "energy services long distance (bunkers)"
/
    esdie_pass_lo
    esdie_frgt_lo
/

fe2ces_dyn35(all_enty,all_in,all_teEs)    "map FE carriers to CES nodes via appliances"
/
    fepet.entrp_pass_sm.te_espet_pass_sm
    fedie.entrp_pass_sm.te_esdie_pass_sm
    feh2t.entrp_pass_sm.te_esh2t_pass_sm
    fegat.entrp_pass_sm.te_esgat_pass_sm
    feelt.entrp_pass_sm.te_eselt_pass_sm
    fedie.entrp_pass_lo.te_esdie_pass_lo
    fedie.entrp_frgt_lo.te_esdie_frgt_lo
    fedie.entrp_frgt_sm.te_esdie_frgt_sm
    feelt.entrp_frgt_sm.te_eselt_frgt_sm
    feh2t.entrp_frgt_sm.te_esh2t_frgt_sm
    fegat.entrp_frgt_sm.te_esgat_frgt_sm
/

ces_transport_dyn35(all_in,all_in)   "CES tree structure - edge transport"
/
   en    . entrp
   entrp . (entrp_pass, entrp_frgt)
   entrp_pass  . (entrp_pass_sm, entrp_pass_lo)
   entrp_frgt  . (entrp_frgt_sm, entrp_frgt_lo)
/

EDGE_scenario_all    "EDGE-T scenarios"
/
ConvCase
ConvCaseWise
ElecEra
ElecEraWise
HydrHype
HydrHypeWise
/

EDGE_scenario(EDGE_scenario_all) "Selected EDGE-T scenario"

*** sets for the reporting, to be consistent with *complex* realisation
FE_Transp_fety35(all_enty) "FEs used in the transport module"  / fepet, fedie, feh2t, feelt, fegat/
FE_Elec_fety35(all_enty)   "FE electricity sets (should be moved to core/sets asap)"  / feels, feelt /

*** nat. gas is not used in complex, that's why these elements have to be defined here and not in core
se2fe_dyn35(all_enty,all_enty,all_te) "nat. gas techs for transport, missing in se2fe in core/sets"
/
segabio.fegat.tdbiogat
segafos.fegat.tdfosgat
segasyn.fegat.tdsyngat
/

enty_dyn35(all_enty) "nat. gas FE used for transport, see comment above"
/
fegat        "final energy gas transport"
/

entyFeTrans_dyn35(all_enty) "nat. gas FE used for transport, see comment above"
/
fegat        "FE nat. gas transport"
/

fe_transport_liquids_dyn35(all_enty) "liquids used by the transport module"
/
fepet
fedie
/

emi2te_dyn35(all_enty,all_enty,all_te,all_enty) "add. emission pathways: CH4 from nat. gas"
/
segabio.fegat.tdbiogat.ch4
segafos.fegat.tdfosgat.ch4
/

entyFe2Sector_dyn35(all_enty,emi_sectors)   "mapping final energy to transport sector"
/
    fegat.trans
/
;

alias(teEs_dyn35,teEs_dyn35_2);
teEs(teEs_dyn35)         = YES;
in(in_dyn35)             = YES;

esty(esty_dyn35)     = YES;

fe2es(fe2es_dyn35)       = YES;
es2ppfen(es2ppfen_dyn35) = YES;
ppfEn(ppfen_dyn35)       = YES;

*** compatibility set overwrites
se2fe(se2fe_dyn35) = YES;
enty(enty_dyn35) = YES;
entyFeTrans(entyFeTrans_dyn35) = YES;
emi2te(emi2te_dyn35) = YES;
entyFe2Sector(entyFe2Sector_dyn35) = YES;

cesOut2cesIn(ces_transport_dyn35)            = YES;


EDGE_scenario("%cm_EDGEtr_scen%") = YES;

*** EOF ./modules/35_transport/edge_esm/sets.gms
