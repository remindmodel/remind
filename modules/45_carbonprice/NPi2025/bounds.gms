*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/45_carbonprice/NPi2025/bounds.gms

*' Add limitation to novel CDR in EUR-region. Note that in case of a different region-resolution
*' The 2040 value should not far exceed ~75 Mt CO2 to reflect the current proposals for EU-ETS (max 48 Mt in 2040)
*' and the 2021 UK Net zero strategy, assuming policy updates soon. Due to upscaling dynamics, the upper value is set to 120 Mt CO2 
*' (the sum of EU 2040 announcement and UK 2050 announcement) for the entire time horizon.
*' For EUR sub-regions, the total target is distributed across subregions weighted by gdp.
vm_emiCdrNovel.up(t,regi)$regi_group("EUR_regi",regi) = 
    120 * sm_MtCO2_2_GtC * pm_gdp("2025",regi)
        / sum(regi2$regi_group("EUR_regi",regi2),
            pm_gdp("2025",regi2));

*** EOF ./modules/45_carbonprice/NPi2025/bounds.gms
