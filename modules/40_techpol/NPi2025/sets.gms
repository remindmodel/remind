*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/40_techpol/NPi2025/sets.gms



*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------
***                                Renewable Share Targets
*------------------------------------------------------------------------------------
*------------------------------------------------------------------------------------


*** Sets neeed for renewable share targets
Sets
RenShareTargetType     "Renewable share target types"
/
    RenElec                     "renewable share in secondary energy electricity"
    NonBioRenElec               "non-biomass renewable share in secondary energy electricity"
    NonFossilElec               "non-fossil share in secondary energy electricity"
    RenFE                       "renewable share in total final energy"
/
;

Sets
*** Mappings needed for renewable share targets (set filled with entries in sets_calculations.gms)
TargetType2ShareEnty(RenShareTargetType,all_enty)    "map renewable share target type to energy carriers used to calculate numerator of share, e.g. renewable electricity"
/
/

TargetType2TotalEnty(RenShareTargetType,all_enty)    "map renewable share target type to energy carriers used to calculate denominator of share, e.g. total electricity"
/
/
;


*** Fill TargetType2ShareEnty and TargetType2TotalEnty mappings to calculate correct renewable shares depending on target type

*** 1.  RenElec: "renewable share in secondary energy electricity"
*** For renewable electricity share targets include all electricity produced from primary energy renewables as well as electricity produced from hydrogen.
*** Hydrogen is by assumption exclusively low-carbon hydrogen in REMIND and predominantly renewable-based hydrogen. 
TargetType2ShareEnty("RenElec",enty)$( peRe(enty) OR sameas(enty,"seh2")  ) = YES;
TargetType2TotalEnty("RenElec","seel") = YES;


*** 2.  NonBioRenElec: "non-biomass renewable share in secondary energy electricity"
*** For non-biomass renewable electricity share targets include all electricity produced from primary energy renewables except bioenergy as well as electricity produced from hydrogen.
TargetType2ShareEnty("NonBioRenElec",enty)$( ( peRe(enty) OR sameas(enty,"seh2") ) AND NOT peBio(enty)  ) = YES;
TargetType2TotalEnty("NonBioRenElec","seel") = YES;

*** 3.  NonFossilElec: "non-fossil share in secondary energy electricity"
*** For non-fossil electricity share targets include all electricity produced non-fossil sources. 
TargetType2ShareEnty("NonFossilElec",enty)$( NOT peFos(enty)  ) = YES;
TargetType2TotalEnty("NonFossilElec","seel") = YES;

*** 4.  RenFE: "renewable share in total final energy"
*** For renewable share target in total final energy, use share of renewable-based secondary energy in total secondary energy as an approximation. 
*** Tracing back final energy to its primary energy origin (e.g. fossil or renewable) is more complicated.
*** Hence, this measure is not exactly the renewable share in final energy due to transmission losses between secondary energy and final energy.
TargetType2ShareEnty("RenFE",enty)$( peRe(enty) OR sameas(enty,"seh2")  ) = YES;
TargetType2TotalEnty("RenFE",entySe) = YES;


*** EOF ./modules/40_techpol/NPi2025/sets.gms