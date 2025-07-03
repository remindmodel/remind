*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/30_biomass/magpie/preloop.gms


*** load values of v30_BioPEProdTotal from input GDX as this is required for switch cm_bioprod_regi_lim 
$IFTHEN.bioprod_regi_lim not "%cm_bioprod_regi_lim%" == "off"
Execute_Loadpoint 'input' v30_BioPEProdTotal.l = v30_BioPEProdTotal.l;
$ENDIF.bioprod_regi_lim


*** EOF ./modules/30_biomass/magpie/preloop.gms

