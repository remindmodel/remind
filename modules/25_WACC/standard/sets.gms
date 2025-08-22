*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/sets.gms

*** No new sets are directly related to this module.

***Sets
***tewacc(all_te)       "technologies with WACC data"
***/
***        pc,
***        igcc,
***        igccc,
***        coalchp,
***        ngccc,
***        ngt,
***        ngcc,
***        fnrs,
***        tnrs,
***        hydro,
***       bioigcc,
***        biochp,
***        csp,
***        spv,
***        windon,
***        windoff
***        storspv
***        storwindon
***        storwindoff
***        storcsp
***        h2turb      
***/
***;


Sets
tewacc(all_te)       "technologies with WACC data"
/
        pc, igcc, igccc, coalchp, ngccc,
        ngt,ngcc,fnrs,dot,tnrs,hydro,
        bioigcc,bioigccc,biochp,csp,
        spv,windon,windoff,storspv,
        storwindon,storwindoff,storcsp,
        h2turb,geohdr,gastr,gaschp,gashp,
        gash2,gash2c,gasftrec,gasftcrec,
        refliq,coalhp,coaltr,coalgas,
        coalftrec,coalftcrec,coalh2,coalh2c,
        biotr,biotrmod,biohp,biogas,biogasc,
        bioftrec,bioftcrec,bioh2,bioh2c,bioethl,
        bioeths,biodiesel,geohe,solhe,elh2,
        h2curt,tdels,tdelt,tdbiogas,tdfosgas,
        tdsyngas,tdbiogat,tdfosgat,tdsyngat,
        tdbiohos,tdfoshos,tdsynhos,tdh2s,tdh2t,
        tdbiodie,tdfosdie,tdsyndie,tdbiopet,tdfospet,
        tdsynpet,tdbiosos,tdfossos,tdhes,ccsinje,
        gridspv,gridcsp,gridwindon,gridwindoff,
        pipe_gas,termX_lng,termM_lng,vess_lng
/
;

***tprev(tall)    
*** This set represents the periods that can be used in REMIND model equations. ttot is a subset of tall and contains only elements defined in tall.
*** It includes both historical (1900-2000) and modeled years (2005-2150). Time steps are:
***      5-year intervals from 1990 to 2060,
***     10-year intervals from 2060 to 2110,
***     20-year intervals from 2110 to 2150.
***/
***        1900, 1905, 1910, 1915, 1920, 1925, 1930, 1935, 1940, 1945, 1950, 1955, 1960, 1965, 1970, 1975, 1980, 1985, 1990, 1995, 2000, 
***        2005, 2010, 2015, 2020, 2025, 2030, 2035, 2040, 2045, 2050, 2055,
***        2060, 2070, 2080, 2090, 2100,
***        2110, 2130, 2150
***/
***;

*** EOF ./modules/25_WACC/standard/sets.gms