*** |  (C) 2006-2024 Potsdam Institute for Climate Impact Research (PIK)
*** |  authors, and contributors see CITATION.cff file. This file is part
*** |  of REMIND and licensed under AGPL-3.0-or-later. Under Section 7 of
*** |  AGPL-3.0, you are granted additional permissions described in the
*** |  REMIND License Exception, version 1.0 (see LICENSE file).
*** |  Contact: remind@pik-potsdam.de
*** SOF ./modules/25_WACC/standard/sets.gms

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
        tdsynpet,tdbiosos,tdfossos,tdhes,
        gridspv,gridcsp,gridwindon,gridwindoff,
        pipe_gas,termX_lng,termM_lng,vess_lng
/
;

*** EOF ./modules/25_WACC/standard/sets.gms