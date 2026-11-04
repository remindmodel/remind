*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/10_emissions/SectorAggregates/sets.gms

Sets

*** ==================================================================
*** ==================================================================
*' ### Non-CO2 emissions plus LUC MACCs
*** ==================================================================
*** ==================================================================

*' Sets for non-CO2 emissions types, land-use change (LUC) CO2 and their marginal
*' abatement cost curves (MACCs): emission types and MAC sectors, the mappings between them
*' and to emission markets and sectors, and the iterators for MAC steps.
*' Air pollutants are not part of this module (see 11_aerosols).

***   1. MAC emission types (and fugitive emissions)
***   2. Mappings of MAC sectors to emission markets, of emission sources to MACs and sectors
***   3. Iterators: MAC steps and the parameter index for waste emissions


*** ==================================================================
*' #### 1. Emission types with MACs (and fugitive emissions)
*** ==================================================================

emiMac(all_enty)  "sum over sub-emissions from emiMacSector"
/
    co2
    n2o
    ch4
/
emiMacSector(all_enty)  "types of climate-relevant non-energy emissions with mac curve. Emissions in this set HAVE to be in emiMac2mac as well - if no MAC is available it will be set to zero automatically."
/
    ch4coal    "fugitive emissions from coal mining"
    ch4gas     "fugitive emissions from gas production"
    ch4oil     "fugitive emissions from oil production"
    ch4wstl    "ch4 emissions from solid waste disposal on land"
    ch4wsts    "ch4 emissions from waste water"
    ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
    ch4peatland "ch4 emissions from peatlands (no MAC available)"
    ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
    ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"
    ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"
    ch4forest  "ch4 emissions from forest burning (no MAC available)"
    ch4savan   "ch4 emissions from savannah burning (no MAC available)"
    n2oforest  "n2o emissions from forest burning (no MAC available)"
    n2osavan   "n2o emissions from savannah burning (no MAC available)"
    n2otrans   "n2o emissions from transport"
    n2oadac    "n2o emissions from adipic acid production"
    n2onitac   "n2o emissions from nitric acid production"
    n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
    n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
    n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
    n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"
    n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
    n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
    n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"
    n2opeatland "n2o emissions from peatlands (no MAC available)"
    n2owaste   "n2o emissions from waste (domestic sewage)"
    co2luc     "co2 emissions from land use change"
    co2cement_process  "co2 from cement production (only process emissions)"
/

MacSector(all_enty)  "sectors for which mac curves exist. Some MACs are used for several emission sectors in emiMacSector."
/
    ch4coal    "coal mining"
    ch4gas     "gas production"
    ch4oil     "oil production"
    ch4wstl    "solid waste disposal on land"
    ch4wsts    "waste water"
    ch4rice    "rice cultivation"
    ch4animals "enteric fermentation of ruminants"
    ch4anmlwst "animal waste management"
    n2otrans   "transport"
    n2oadac    "adipic acid production"
    n2onitac   "nitric acid production"
    n2ofert    "Inorganic fertilizers"
    n2oanwst   "manure applied to croplands"
    n2owaste   "waste (domestic sewage)"
    co2luc     "land use change"
    co2cement  "cement production (only process emissions)"
    co2chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    co2steel
$endif.cm_subsec_model_steel
/

MacSectorMagpie(all_enty)  "land-use sectors for which mac curves exist in REMIND and in MAgPIE"
/
    ch4rice    "rice cultivation"
    ch4animals "enteric fermentation of ruminants"
    ch4anmlwst "animal waste management"
    ch4peatland "ch4 emissions from peatlands (no MAC available)"
    n2ofert    "Inorganic fertilizers"
    n2oanwst   "manure applied to croplands"
    n2opeatland "n2o emissions from peatlands (no MAC available)"
    co2luc     "land use change"
/

emiMacMagpie(all_enty)  "types of climate-relevant non-energy emissions with mac curve where baseline emissions come from MAgPIE only"
emiMacMagpieN2O(all_enty)  "types of climate-relevant non-energy N2O emissions with mac curve where baseline emissions come from MAgPIE only"
/
    n2ofertin  "n2o emissions from Inorganic fertilizers (inorg_fert_n2o)"
    n2ofertcr  "n2o emissions from decay of crop residues (resid_n2o)"
    n2ofertsom "n2o emissions from soil organic matter loss (som_n2o)"
    n2oanwstc  "n2o emissions from manure applied to croplands (man_crop_n2o)"
    n2oanwstm  "n2o emissions from animal waste management (awms_n2o)"
    n2opeatland "n2o emissions from peatlands (no MAC available)"
    n2oanwstp  "n2o emissions from manure excreted on pasture (man_past_n2o)"
/
emiMacMagpieCH4(all_enty)  "types of climate-relevant non-energy CH4 emissions with mac curve where baseline emissions come from MAgPIE only"
/
    ch4rice    "ch4 emissions from rice cultivation (rice_ch4)"
    ch4animals "ch4 emissions from enteric fermentation of ruminants (ent_ferm_ch4)"
    ch4anmlwst "ch4 emissions from animal waste management(awms_ch4)"
    ch4peatland "ch4 emissions from peatlands (no MAC available)"
/
emiMacMagpieCO2(all_enty)  "types of climate-relevant non-energy CO2 emissions with mac curve where baseline emissions come from MAgPIE only"
/
    co2luc     "co2 emissions from land use change"
/

emiMacMagpieCO2Sub(all_enty)  "subtypes of co2luc that add up to co2luc, coming from MAgPIE, passed through REMIND for reporting, not used anywhere, remain unchanged"
/
    co2lucPos                    "Emi|CO2|Land-Use Change|+|Positive"
    co2lucNegUnintent            "Emi|CO2|Land-Use Change|Negative|+|Unintentional"
    co2lucNegIntentAR            "Emi|CO2|Land-Use Change|Negative|Intentional|+|Reforestation"
    co2lucNegIntentAgroforestry  "Emi|CO2|Land-Use Change|Negative|Intentional|+|Agroforestry"
    co2lucNegIntentTimber        "Emi|CO2|Land-Use Change|Negative|Intentional|+|Timber"
    co2lucNegIntentSCM           "Emi|CO2|Land-Use Change|Negative|Intentional|+|Soil Carbon Management"
    co2lucNegIntentPeat          "Emi|CO2|Land-Use Change|Negative|Intentional|+|Peatland"
/

emiMacExo(all_enty)  "types of climate-relevant non-energy emissions with mac curve where baseline emissions are exogenous"
emiMacExoN2O(all_enty) "types of climate-relevant non-energy N2O emissions with mac curve where baseline emissions are exogenous"
/
    n2oforest  "n2o emissions from forest burning (no MAC available)"
    n2osavan   "n2o emissions from savannah burning (no MAC available)"
    n2oagwaste "n2o emissions from agricultural waste burning (no MAC available)"
/
emiMacExoCH4(all_enty)  "types of climate-relevant non-energy CH4 emissions with mac curve where baseline emissions are exogenous"
/
    ch4agwaste "ch4 emissions from agricultural waste burning (no MAC available)"
    ch4forest  "ch4 emissions from forest burning (no MAC available)"
    ch4savan   "ch4 emissions from savannah burning (no MAC available)"
/

emiFuEx(all_enty)   "fugitive emissions"
/
    ch4coal    "fugitive emissions from coal mining"
    ch4gas     "fugitive emissions from gas production"
    ch4oil     "fugitive emissions from oil production"
/


*** ==================================================================
*' #### 2. Mappings of MAC sectors to emission markets, emission sources and sectors
*** ==================================================================

macSector2emiMkt(all_enty,all_emiMkt)  "mapping mac sectors to emission markets"
/
    ch4coal.ETS
    ch4gas.ETS
    ch4oil.ETS
    ch4wstl.ES
    ch4wsts.ES
    ch4rice.ES
    ch4animals.ES
    ch4anmlwst.ES
    ch4agwaste.ES
    ch4peatland.other
    ch4forest.other
    ch4savan.other
    n2oforest.other
    n2osavan.other
    n2otrans.ES
    n2oadac.ETS
    n2onitac.ETS
    n2ofertin.ES
    n2ofertcr.ES
    n2ofertsom.ES
    n2oanwstc.ES
    n2oanwstm.ES
    n2oanwstp.ES
    n2oagwaste.ES
    n2owaste.ES
    n2opeatland.other
    co2luc.other
    co2cement_process.ETS
/

emiMacSector2emiMac(all_enty,all_enty)   "mapping of sub-emissions to their sum"
/
    (co2luc,co2cement_process)                          .co2
    (n2otrans,n2oadac,n2onitac,n2ofertin,n2ofertcr, n2ofertsom, n2oanwstc,n2oanwstm,n2opeatland,n2oanwstp,n2oagwaste,n2oforest,n2osavan,n2owaste).n2o
    (ch4coal,ch4gas,ch4oil,ch4rice,ch4animals,ch4anmlwst,ch4agwaste,ch4peatland,ch4forest,ch4savan,ch4wstl,ch4wsts).ch4
/
emiMac2mac(all_enty,all_enty)            "mapping of emission sources to MACs - caution: not all MACs exist, in that case they are zero"
/
    ch4coal.ch4coal
    ch4gas.ch4gas
    ch4oil.ch4oil
    ch4wstl.ch4wstl
    ch4wsts.ch4wsts
    ch4rice.ch4rice
    ch4animals.ch4animals
    ch4anmlwst.ch4anmlwst
    ch4agwaste.ch4agwaste
    ch4peatland.ch4peatland
    ch4forest.ch4forest
    ch4savan.ch4savan
    n2otrans.n2otrans
    n2oadac.n2oadac
    n2onitac.n2onitac
    (n2ofertin, n2ofertcr, n2ofertsom).n2ofert
    (n2oanwstc, n2oanwstm, n2oanwstp).n2oanwst
    n2oagwaste.n2oagwaste
    n2opeatland.n2opeatland
    n2owaste.n2owaste
    n2osavan.n2osavan
    n2oforest.n2oforest
    co2luc.co2luc
    co2cement_process. co2cement   "process emissions are captured by kiln CCS too"
    co2cement    . co2cement
    co2chemicals . co2chemicals
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    co2steel     . co2steel
$endif.cm_subsec_model_steel
/

emiMac2sector(all_enty,emi_sectors,sector_types,all_enty)            "mapping of emission sources from MACs to sectors (and emissions)"
/
    (ch4coal, ch4gas, ch4oil).extraction.process.ch4
    (ch4wstl, ch4wsts).waste.process.ch4
    (ch4rice, ch4animals, ch4anmlwst, ch4agwaste).agriculture.process.ch4
    (ch4forest, ch4savan, ch4peatland).lulucf.process.ch4

    (n2otrans).trans.process.n2o
    (n2oadac, n2onitac).indst.process.n2o
    (n2owaste).waste.process.n2o
    (n2ofertin, n2ofertcr, n2ofertsom, n2oanwstc, n2oanwstm, n2oanwstp, n2oagwaste).agriculture.process.n2o
    (n2oforest, n2osavan, n2opeatland).lulucf.process.n2o

    (co2cement_process,co2cement,co2chemicals).indst.process.co2
$ifthen.cm_subsec_model_steel "%cm_subsec_model_steel%" == "ces"
    co2steel.indst.process.co2
$endif.cm_subsec_model_steel
    (co2luc).lulucf.process.co2
/


*** ==================================================================
*' #### 3. Iterators: MAC steps and parameter index for waste emissions
*** ==================================================================

steps         "iterator for MAC steps"
/
    1*801
/
p                "parameter for ch4 and n2o waste emissions and co2 cement emissions"
/
    p1
    p2
    p3
    p4
/
;


alias(steps,steps2);

*** Sets calculated from the sets above (moved from core/sets_calculations.gms)
emiMacMagpie(enty)   = emiMacMagpieCH4(enty) + emiMacMagpieN2O(enty) + emiMacMagpieCO2(enty);
emiMacExo(enty)      = emiMacExoCH4(enty) + emiMacExoN2O(enty);

*** EOF ./modules/10_emissions/SectorAggregates/sets.gms
