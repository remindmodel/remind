*** |  (C) 2006-2020 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/35_transport/complex/sets.gms

***-----------------------------------------------------------
***                  module specific sets
***------------------------------------------------------------
Sets
    
te_dyn35(all_te)  "technologies - transport module additions"
/
  tdelt     "electricity t&d to transport users" 
  apCarPeT  "Cars using FEPET to produce UE"
  apCarDiT  "Vehicles using FEDIE to produce UEDIE."
  apCarDiEffT  "Efficient Vehicles using FEDIE & FEELT to produce UE."
  apCarDiEffH2T  "Efficient Vehicles using FEDIE & FEELT & FEH2T to produce UE."
  apCarH2T  "Cars using FEH2T to produce UEH2T."
  apCarElT  "Cars using FEELT to produce UEELT."
  apTrnElT  "Trains using FEELT to produce UEELT."
***  appCarGaT  "Cars using FEGAT to produce UEGAT."
/

adjte_dyn35(all_te)    "technologies with adjustment costs on capacity additions  - transport module additions"
/ 
  tdelt     "electricity t&d to transport users"
  apCarPeT  "Cars using FEPET to produce UEPET"
  apCarDiT  "Vehicles using FEDIE to produce UE."
  apCarDiEffT  "Efficient Vehicles using FEDIE & FEELT to produce UE."
  apCarDiEffH2T  "Efficient Vehicles using FEDIE & FEELT & FEH2T to produce UE."
  apCarH2T  "Cars using FEH2T to produce UEH2T."
  apCarElT  "Cars using FEELT to produce UEELT."
  apTrnElT  "Trains using FEELT to produce UEELT."
*** appCarGaT  "Cars using FEGAT to produce UEGAT."
/

learnte_dyn35(all_te)     "technologies with endogenous learning-by-doing - transport module additions"
/
    apCarElT
    apCarH2T
/

LDV35(all_te) "all technologies describing light duty vehicles"
/
    apCarPeT
    apCarElT
    apCarH2T
/

enty_dyn35(all_enty)        "all types of quantities - transport module additions"
/
  uedit   "Energy Service: DIesel for Transport. Unit: TWa (currently 1:1 transfer from FE)"
  uepet   "Energy Service: PEtrol for Transport. Unit: TWa (currently 1:1 transfer from FE)"
  ueelt   "Energy Service: ELectricity for Transport. Unit: TWa (currently 1:1 transfer from FE)"
*** esGaT   "Energy Service: GAs for Transport. "
*** esH2T   "Energy Service: H2 for Transport.  "
    feelt
/

entyFeTrans_dyn35(all_enty)      "final energy types - transport module additions"
/
    feelt
/

entyUe_dyn35(all_enty)            "Energy service types"
/
  uedit   "Energy Service: DIesel for Transport. Unit: TWa (currently 1:1 transfer from FE)"
  uepet   "Energy Service: PEtrol for Transport. Unit: TWa (currently 1:1 transfer from FE)"
  ueelt   "Energy Service: ELectricity for Transport. Unit: TWa (currently 1:1 transfer from FE)"
*** esGaT   "Energy Service: GAs for Transport."
*** esH2T   "Energy Service: H2 for Transport. "
/

in_dyn35(all_in)          "all inputs and outputs of the CES function - transport module additions"
/
    entrp   "transport energy use"
    fetf    "transport fuel use"
    ueLDVt   "transport gas use"
    ueHDVt   "transport diesel fuel use"
***    feh2t   "transport hydrogen use"
    ueelTt   "transport electricity use"
/

ppfen_dyn35(all_in)   "all energy inputs because of unit conversion - transport module additions"
  / ueLDVt, ueHDVt, ueelTt / !! feh2t, 
  
  
ces_transport_dyn38(all_in,all_in)   "CES tree structure - transport"
/
   en    . entrp
   entrp . (fetf, ueelTt)
   fetf  . (ueLDVt, ueHDVt) !! , feh2t)
/
  
*LB* sets for the reporting
FE_Transp_fety35(all_enty)  "set for reporting"
 / fepet, fedie, feh2t, feelt /
FE_Elec_fety35(all_enty)    "set for reporting"  
/ feels, feelt /

char35 "characteristics of transport technologies"
/
  share_Pass_nonLDV
  Eff_Pass_nonLDV
  Eff_Pass_LDV
  Eff_Freight
/

EDGE_scenario_all    "EDGE-T scenarios, used to get the bunkers share on total liquids demand."
/
ConvCase
ConvCaseWise
ElecEra
ElecEraWise
HydrHype
HydrHypeWise
/
;

***-----------------------------------------------------------
***                  module specific mappings
***------------------------------------------------------------
sets
se2fe_dyn35(all_enty,all_enty,all_te)   "map secondary energy to end-use energy using a technology - transport module additions"
/
   seel.feelt.tdelt
/

fe2ue_dyn35(all_enty,all_enty,all_te)    "map FE carriers to ES via appliances"
/
    fepet.uepet.apCarPeT
    fedie.uedit.apCarDiT
	fedie.uedit.apCarDiEffT
	fedie.uedit.apCarDiEffH2T
    feh2t.uepet.apCarH2T
    feelt.uepet.apCarElT
    feelt.ueelt.apTrnElT
/

teFe2rlf_dyn35(all_te,rlf)      "mapping for final energy to grades - transport module additions"
/
    tdelt.1
/

teue2rlf_dyn35(all_te,rlf)     "mapping for ES production technologies to grades"
/
    apCarPeT.1
    apCarDiT.1
	apCarDiEffT.1
    apCarDiEffH2T.1
    apCarH2T.1
    apCarElT.1
    apTrnElT.1
*** appCarGaT .1
/

ue2ppfen_dyn35(all_enty,all_in)      "matching ES in ESM to ppfEn in MACRO"
/
    uedit.ueHDVt
    uepet.ueLDVt
    ueelt.ueelTt
/
;

sets
 bound_type    "auxiliar set to allow different values for upper and lower bound defined in a single switch"
  /
  upper
  lower
  /
 ;

***-------------------------------------------------------------------------
***  add module specific sets and mappings to the global sets and mappings
***-------------------------------------------------------------------------
te(te_dyn35)             = YES;
teAdj(adjte_dyn35)       = YES;
teLearn(learnte_dyn35)   = YES;
se2fe(se2fe_dyn35)       = YES;
fe2ue(fe2ue_dyn35)       = YES;
teFe2rlf(teFe2rlf_dyn35) = YES;

enty(enty_dyn35)                = YES;
entyFeTrans(entyFeTrans_dyn35)  = YES;
entyUe(entyUe_dyn35)            = YES;

in(in_dyn35)             = YES;
ppfEn(ppfen_dyn35)       = YES;
cesOut2cesIn(ces_transport_dyn38)            = YES;
ue2ppfen(ue2ppfen_dyn35) = YES;
teue2rlf(teue2rlf_dyn35) = YES;

*** EOF ./modules/35_transport/complex/sets.gms
