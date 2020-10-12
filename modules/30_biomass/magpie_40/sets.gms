*** |  (C) 2006-2019 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie_4/sets.gms

sets
all_charScen                 "coefficients of the emulator formulas"   
/ a,b,c /

peren2rlf30(all_enty,rlf)    "map biomass energy to grades"
/
        pebios.(5)            
        pebioil.(5)
        pebiolc.2            "residues from agriculture and forestry"
/

peren2cont30(all_enty,rlf)   "map biomass energy to grades with continous supplycurve"
/
        pebiolc.1         "purpose grown"
/

;

*LM* Define set with regions that do not import lignocellulosic biomass (only if switch is activated)
$ifThen.regiNoBioImport not "%cm_regiNoBioImport%" == "none"
Set regiNoBioImport30(all_regi)     "Set of regions that do not import biomass" / %cm_regiNoBioImport% /;
$endIf.regiNoBioImport

*** EOF ./modules/30_biomass/magpie_4/sets.gms
